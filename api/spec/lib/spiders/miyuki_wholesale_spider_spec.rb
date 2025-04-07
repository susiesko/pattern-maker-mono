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

require Rails.root.join('lib', 'spiders', 'miyuki_wholesale_spider')

RSpec.describe MiyukiWholesaleSpider do
  # Note: We're not using Vessel::TestHelpers because the API has changed
  # and we need to adapt our tests to the new Vessel::Cargo approach

  describe 'crawling behavior' do
    it 'is configured with the correct domain and start URLs' do
      expect(MiyukiWholesaleSpider.domain).to eq('miyukiwholesale.com')
      expect(MiyukiWholesaleSpider.start_urls).to eq('https://www.miyukiwholesale.com/miyuki/')
    end

    it 'has a parse method that handles the main page' do
      expect(MiyukiWholesaleSpider.instance_methods(false)).to include(:parse)
    end

    it 'has a parse_category method that handles category pages' do
      expect(MiyukiWholesaleSpider.instance_methods(false)).to include(:parse_category)
    end
  end

  describe 'database interactions' do
    let!(:brand) { create(:bead_brand, name: 'Miyuki', website: 'https://www.miyukiwholesale.com/') }
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
        image: 'https://www.miyukiwholesale.com/images/beads/db001.jpg'
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
end
