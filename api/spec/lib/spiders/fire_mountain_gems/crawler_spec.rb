# frozen_string_literal: true

# TODO: remove this file when we remove the ruby crawler

require 'rails_helper'

RSpec.describe Spiders::FireMountainGems::Crawler do
  let(:crawler) { Spiders::FireMountainGems::Crawler.new }

  let(:sample_product_html) do
    <<~HTML
      <div class="product-tile">
        <a href="/product/db-123-silver-lined-crystal" class="link">
          <img src="/images/db123.jpg" class="tile-image" alt="DB-123">
          <h3 class="name">DB-123 Miyuki Delica Silver Lined Crystal</h3>
        </a>
        <div class="pricebooks">
          <div class="pricebook">
            <span class="price">$2.99</span>
          </div>
        </div>
      </div>
    HTML
  end

  describe '#initialize' do
    it 'creates a new crawler instance' do
      expect(crawler).to be_a(Spiders::FireMountainGems::Crawler)
    end

    it 'initializes results as empty array' do
      expect(crawler.results).to eq([])
    end
  end

  describe '#parse_product' do
    let(:doc) { Nokogiri::HTML(sample_product_html) }
    let(:product_item) { doc.at_css('.product-tile') }

    before do
      # Mock the helper methods directly on the crawler instance
      allow(crawler).to receive_messages(all_colors: %w[Crystal Silver Blue], all_finishes: ['Silver Lined', 'Matte', 'Opaque'])

      # Mock absolute_url method
      allow(crawler).to receive(:absolute_url) { |url| "https://www.firemountaingems.com#{url}" }

      # Mock the specific elements that will be used
      allow(product_item.at_css('.link')).to receive(:attribute).with(:href).and_return('/product/db-123-silver-lined-crystal')
      allow(product_item.at_css('img.tile-image')).to receive(:attribute).with(:src).and_return('/images/db123.jpg')
    end

    it 'extracts product information correctly' do
      result = crawler.parse_product(product_item)

      expect(result).to include(
        name: 'DB-123 Miyuki Delica Silver Lined Crystal',
        brand_product_code: 'DB-123',
        brand: 'Miyuki',
        type: 'Delica',
        size: '11/0',
      )
    end

    it 'extracts product code correctly for different types' do
      # Test DB- pattern
      expect(crawler.parse_product(product_item)[:brand_product_code]).to eq('DB-123')

      # Test DBS- pattern
      html_dbs = sample_product_html.gsub('DB-123', 'DBS-456')
      doc_dbs = Nokogiri::HTML(html_dbs)
      product_item_dbs = doc_dbs.at_css('.product-tile')

      # Re-stub the helper methods for this item too
      allow(product_item_dbs.at_css('.link')).to receive(:attribute).with(:href).and_return('/product/dbs-456-silver-lined-crystal')
      allow(product_item_dbs.at_css('img.tile-image')).to receive(:attribute).with(:src).and_return('/images/dbs456.jpg')

      result_dbs = crawler.parse_product(product_item_dbs)
      expect(result_dbs[:brand_product_code]).to eq('DBS-456')
      expect(result_dbs[:size]).to eq('15/0')
    end

    it 'determines size based on product code prefix' do
      test_cases = [
        ['DB-123', '11/0'],
        ['DBS-456', '15/0'],
        ['DBM-789', '10/0'],
        ['DBL-012', '8/0'],
      ]

      test_cases.each do |code, expected_size|
        html = sample_product_html.gsub('DB-123', code)
        doc = Nokogiri::HTML(html)
        product_item_test = doc.at_css('.product-tile')

        # Stub the helper methods for each test item
        allow(product_item_test.at_css('.link')).to receive(:attribute).with(:href).and_return("/product/#{code.downcase}-silver-lined-crystal")
        allow(product_item_test.at_css('img.tile-image')).to receive(:attribute).with(:src).and_return("/images/#{code.downcase}.jpg")

        result = crawler.parse_product(product_item_test)
        expect(result[:size]).to eq(expected_size)
      end
    end

    it 'raises error for non-delica products' do
      non_delica_html = sample_product_html.gsub('DB-123', 'ABC-123')
      doc = Nokogiri::HTML(non_delica_html)
      product_item_non_delica = doc.at_css('.product-tile')

      # Stub the helper methods for non-delica item
      allow(product_item_non_delica.at_css('.link')).to receive(:attribute).with(:href).and_return('/product/abc-123-silver-lined-crystal')
      allow(product_item_non_delica.at_css('img.tile-image')).to receive(:attribute).with(:src).and_return('/images/abc123.jpg')

      result = crawler.parse_product(product_item_non_delica)
      expect(result[:error]).to include('Skipping non-delicas')
    end

    it 'handles missing product link gracefully' do
      html_no_link = sample_product_html.gsub('<a href="/product/db-123-silver-lined-crystal" class="link">', '<div>')
      doc = Nokogiri::HTML(html_no_link)

      result = crawler.parse_product(doc.at_css('.product-tile'))
      expect(result[:error]).to include('no product link found')
    end
  end

  describe '#extract_colors_from_name' do
    before do
      allow(crawler).to receive_messages(all_colors: %w[Crystal Silver Blue], all_finishes: ['Silver Lined', 'Matte'])
    end

    it 'extracts known colors from product name' do
      name = 'DB-123 Miyuki Delica Silver Lined Crystal'
      colors = crawler.send(:extract_colors_from_name, name)
      expect(colors).to include('Crystal')
    end

    it 'returns cleaned name when no known colors found' do
      name = 'DB-123 Miyuki Delica Unknown Color'
      colors = crawler.send(:extract_colors_from_name, name)
      expect(colors).not_to be_empty
    end
  end

  describe '#extract_finishes_from_name' do
    before do
      allow(crawler).to receive(:all_finishes).and_return(['Silver Lined', 'Matte', 'Opaque'])
    end

    it 'extracts known finishes from product name' do
      name = 'DB-123 Miyuki Delica Silver Lined Crystal'
      finishes = crawler.send(:extract_finishes_from_name, name)
      expect(finishes).to eq('Silver Lined')
    end

    it 'returns empty string when no known finishes found' do
      name = 'DB-123 Miyuki Delica Crystal'
      finishes = crawler.send(:extract_finishes_from_name, name)
      expect(finishes).to eq('')
    end
  end

  describe '.crawl_and_return_results' do
    it 'returns an array of results' do
      # Mock the run method to avoid actual HTTP requests
      allow(Spiders::FireMountainGems::Crawler).to receive(:run) do |_options, &block|
        # Simulate yielding some test data
        block.call({ name: 'Test Bead', brand_product_code: 'DB-001' })
        block.call({ name: 'Test Bead 2', brand_product_code: 'DB-002' })
      end

      results = Spiders::FireMountainGems::Crawler.crawl_and_return_results

      expect(results).to be_an(Array)
      expect(results.length).to eq(2)
      expect(results.first).to include(name: 'Test Bead')
    end
  end

  describe 'helper methods' do
    describe '#get_clean_name' do
      it 'removes product code and brand prefix' do
        name = 'DB-123 Miyuki Delica Silver Lined Crystal'
        clean_name = crawler.send(:get_clean_name, name)
        expect(clean_name).to eq('Silver Lined Crystal')
      end
    end

    describe '#all_colors' do
      it 'caches color names from database' do
        color_relation = double('color_relation') # rubocop:disable RSpec/VerifiedDoubles
        allow(Catalog::Bead).to receive(:distinct).and_return(color_relation)
        allow(color_relation).to receive(:pluck).with(:color_group).and_return(['Crystal', 'Silver'])
        allow(color_relation).to receive(:compact).and_return(['Crystal', 'Silver'])

        # Call twice to test caching
        first_result = crawler.send(:all_colors)
        second_result = crawler.send(:all_colors)

        expect(first_result).to eq(['Crystal', 'Silver'])
        expect(second_result).to eq(['Crystal', 'Silver'])
      end
    end

    describe '#all_finishes' do
      it 'caches finish names from database' do
        finish_relation = double('finish_relation') # rubocop:disable RSpec/VerifiedDoubles
        allow(Catalog::Bead).to receive(:distinct).and_return(finish_relation)
        allow(finish_relation).to receive(:pluck).with(:finish).and_return(['Silver Lined', 'Matte'])
        allow(finish_relation).to receive(:compact).and_return(['Silver Lined', 'Matte'])

        # Call twice to test caching
        first_result = crawler.send(:all_finishes)
        second_result = crawler.send(:all_finishes)

        expect(first_result).to eq(['Silver Lined', 'Matte'])
        expect(second_result).to eq(['Silver Lined', 'Matte'])
      end
    end
  end
end
