# frozen_string_literal: true

require 'rails_helper'

# Mock the Vessel::Cargo class for testing
module Vessel
  class Cargo
    class << self
      attr_accessor :domain_value, :start_urls_value, :delay_value, :headers_value

      def domain(value = nil)
        @domain_value = value if value
        @domain_value
      end

      def start_urls(value = nil)
        @start_urls_value = value if value
        @start_urls_value
      end

      def delay(value = nil)
        @delay_value = value if value
        @delay_value
      end

      def headers(value = nil)
        @headers_value = value if value
        @headers_value
      end
    end
  end
end

require Rails.root.join('lib', 'spiders', 'fire_mountain_gems_spider')

RSpec.describe FireMountainGemsSpider do
  # Note: We're not using Vessel::TestHelpers because the API has changed
  # and we need to adapt our tests to the new Vessel::Cargo approach

  describe 'crawling behavior' do
    it 'is configured with the correct domain and start URLs' do
      expect(FireMountainGemsSpider.domain).to eq('firemountaingems.com')
      expect(FireMountainGemsSpider.start_urls).to eq('https://www.firemountaingems.com/shop/miyuki-delica-beads')
    end

    it 'has a parse method that handles the main page' do
      expect(FireMountainGemsSpider.instance_methods(false)).to include(:parse)
    end

    it 'has a parse_product_listings method that handles product pages' do
      expect(FireMountainGemsSpider.instance_methods(false)).to include(:parse_product_listings)
    end
  end

  describe 'database interactions' do
    let!(:brand) { create(:bead_brand, name: 'Miyuki', website: 'https://www.miyuki-beads.co.jp/english/') }
    let!(:bead_type) do
      Catalog::BeadType.create!(
        name: 'Delica Beads',
        brand: brand
      )
    end
    let!(:bead_size) do
      Catalog::BeadSize.create!(
        size: '11/0',
        brand: brand,
        type: bead_type
      )
    end
    let!(:color) { Catalog::BeadColor.create!(name: 'Crystal') }
    let!(:finish) { Catalog::BeadFinish.create!(name: 'Silver-Lined') }
    let!(:bead) do
      Catalog::Bead.create!(
        brand_product_code: 'DB001',
        name: 'Silver-Lined Crystal',
        brand: brand,
        type: bead_type,
        size: bead_size,
        image: 'https://www.firemountaingems.com/images/beads/db001.jpg'
      )
    end

    before do
      bead.bead_color_links.create!(color: color)
      bead.bead_finish_links.create!(finish: finish)
    end

    it 'associates beads with the correct brand' do
      expect(bead.brand).to eq(brand)
    end

    it 'associates beads with the correct type' do
      expect(bead.type).to eq(bead_type)
    end

    it 'associates beads with the correct size' do
      expect(bead.size).to eq(bead_size)
    end

    it 'associates beads with the correct colors' do
      expect(bead.colors).to include(color)
    end

    it 'associates beads with the correct finishes' do
      expect(bead.finishes).to include(finish)
    end
  end

  describe 'helper methods' do
    let(:spider) { FireMountainGemsSpider.new }

    describe '#extract_color_from_name' do
      it 'extracts color from product name' do
        expect(spider.send(:extract_color_from_name, 'Miyuki Delica DB123 Crystal')).to eq('Crystal')
        expect(spider.send(:extract_color_from_name, 'DB123 Silver-Lined Crystal')).to eq('Crystal')
        expect(spider.send(:extract_color_from_name, 'Miyuki Delica Seed Bead 11/0 Transparent Red DB123')).to eq('Transparent Red')
      end
    end

    describe '#extract_finish_from_name' do
      it 'extracts finish from product name' do
        expect(spider.send(:extract_finish_from_name, 'Silver Lined Crystal')).to eq('Silver Lined')
        expect(spider.send(:extract_finish_from_name, 'Matte Blue')).to eq('Matte')
        expect(spider.send(:extract_finish_from_name, 'Transparent Red')).to eq('Transparent')
        expect(spider.send(:extract_finish_from_name, 'Galvanized Gold')).to eq('Galvanized')
      end
    end
  end
end