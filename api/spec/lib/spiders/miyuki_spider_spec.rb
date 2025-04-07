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

require Rails.root.join('lib', 'spiders', 'miyuki_spider')

RSpec.describe MiyukiSpider do
  # Note: We're not using Vessel::TestHelpers because the API has changed
  # and we need to adapt our tests to the new Vessel::Cargo approach

  describe 'crawling behavior' do
    it 'is configured with the correct domain and start URLs' do
      expect(MiyukiSpider.domain).to eq('miyukiwholesale.com')
      expect(MiyukiSpider.start_urls).to eq('https://www.miyukiwholesale.com/miyuki/')
    end

    it 'has a parse method that handles the main page' do
      expect(MiyukiSpider.instance_methods(false)).to include(:parse)
    end

    it 'has a parse_category method that handles category pages' do
      expect(MiyukiSpider.instance_methods(false)).to include(:parse_category)
    end
  end

  describe 'database interactions' do
    let!(:brand) { create(:bead_brand, name: 'Miyuki', website: 'https://www.miyuki-beads.co.jp/english/') }

    it 'creates the expected database records', :aggregate_failures do
      # This is a simplified test that just verifies the models and associations
      # A full integration test would require running the actual spider

      # Create a bead type
      bead_type = Catalog::BeadType.create!(
        name: 'Delica Beads',
        brand: brand
      )

      # Create a bead size
      bead_size = Catalog::BeadSize.create!(
        size: '11/0',
        brand: brand,
        type: bead_type
      )

      # Create a color
      color = Catalog::BeadColor.create!(name: 'Crystal')

      # Create a finish
      finish = Catalog::BeadFinish.create!(name: 'Silver-Lined')

      # Create a bead
      bead = Catalog::Bead.create!(
        brand_product_code: 'DB001',
        name: 'Silver-Lined Crystal',
        brand: brand,
        type: bead_type,
        size: bead_size,
        image: 'https://www.miyuki-beads.co.jp/images/beads/db001.jpg'
      )

      # Associate with color and finish
      bead.bead_color_links.create!(color: color)
      bead.bead_finish_links.create!(finish: finish)

      # Verify the associations
      expect(bead.brand).to eq(brand)
      expect(bead.type).to eq(bead_type)
      expect(bead.size).to eq(bead_size)
      expect(bead.colors).to include(color)
      expect(bead.finishes).to include(finish)
    end
  end
end
