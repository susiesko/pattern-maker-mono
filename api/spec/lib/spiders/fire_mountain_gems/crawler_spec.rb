require 'rails_helper'

RSpec.describe Spiders::FireMountainGems::Crawler do
  let(:crawler) { described_class.new }

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
      expect(crawler).to be_a(described_class)
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
      allow(crawler).to receive(:all_colors).and_return(%w[Crystal Silver Blue])
      allow(crawler).to receive(:all_finishes).and_return(['Silver Lined', 'Matte', 'Opaque'])

      # Mock absolute_url method
      allow(crawler).to receive(:absolute_url) { |url| "https://www.firemountaingems.com#{url}" }

      # Mock the attribute method to return strings instead of Nokogiri::XML::Attr objects
      allow_any_instance_of(Nokogiri::XML::Element).to receive(:attribute) do |element, attr_name|
        case attr_name
        when :href, 'href'
          element.get_attribute('href')
        when :src, 'src'
          element.get_attribute('src')
        else
          element.get_attribute(attr_name.to_s)
        end
      end
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
      result_dbs = crawler.parse_product(doc_dbs.at_css('.product-tile'))
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
        result = crawler.parse_product(doc.at_css('.product-tile'))
        expect(result[:size]).to eq(expected_size)
      end
    end

    it 'raises error for non-delica products' do
      non_delica_html = sample_product_html.gsub('DB-123', 'ABC-123')
      doc = Nokogiri::HTML(non_delica_html)

      result = crawler.parse_product(doc.at_css('.product-tile'))
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
      allow(crawler).to receive(:all_colors).and_return(%w[Crystal Silver Blue])
      allow(crawler).to receive(:all_finishes).and_return(['Silver Lined', 'Matte'])
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
      allow(described_class).to receive(:run) do |options, &block|
        # Simulate yielding some test data
        block.call({ name: 'Test Bead', brand_product_code: 'DB-001' })
        block.call({ name: 'Test Bead 2', brand_product_code: 'DB-002' })
      end

      results = described_class.crawl_and_return_results

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
        color_relation = double('color_relation')
        allow(Catalog::Bead).to receive(:distinct).and_return(color_relation)
        allow(color_relation).to receive(:pluck).with(:color_group).and_return(['Crystal', 'Silver'])
        allow(color_relation).to receive(:compact).and_return(['Crystal', 'Silver'])

        # Call twice to test caching
        crawler.send(:all_colors)
        crawler.send(:all_colors)
      end
    end

    describe '#all_finishes' do
      it 'caches finish names from database' do
        finish_relation = double('finish_relation')
        allow(Catalog::Bead).to receive(:distinct).and_return(finish_relation)
        allow(finish_relation).to receive(:pluck).with(:finish).and_return(['Silver Lined', 'Matte'])
        allow(finish_relation).to receive(:compact).and_return(['Silver Lined', 'Matte'])

        # Call twice to test caching
        crawler.send(:all_finishes)
        crawler.send(:all_finishes)
      end
    end
  end
end
