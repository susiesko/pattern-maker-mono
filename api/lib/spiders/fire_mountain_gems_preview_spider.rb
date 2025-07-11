# frozen_string_literal: true

require 'vessel'

module Spiders
  class FireMountainGemsPreviewSpider < Vessel::Cargo
    # Configure the spider
    domain 'firemountaingems.com'
    start_urls 'https://www.firemountaingems.com/beads/beads-by-brand/miyuki/'

    # Set a reasonable delay between requests to be polite
    delay 1.0

    # Set a user agent
    headers 'User-Agent' => 'PatternMaker/1.0 (+https://kohana-beads.com)'

    # Store results in memory
    attr_reader :results

    def initialize(options = {})
      super
      @results = {
        categories: [],
        sizes: [],
        beads: []
      }
    end

    # Define the parser for the main beads page
    def parse
      puts "Parsing main Miyuki Delica page: #{current_url}"

      # Store category info
      @results[:categories] << {
        name: 'Miyuki Delica Beads',
        url: current_url
      }

      yield request(url: current_url, method: :parse_product_listings)
  
      yield @results
    end

    # def yield_request(url:, method:)
    #   request(url: url, method: method)
    # end

    # Parse the product listings on the current page
    def parse_product_listings
      # Extract all product items from the page
      product_items = css('.product-tile')
      puts "Found #{product_items.length} products on page"

      product_items.each do |item|
        # Extract product details
        product_link = item.at_css('.link')
        next unless product_link

        product_url = absolute_url(product_link.attribute(:href))
        product_name = item.at_css('h3.name').text.strip

        # Extract product code from the name or URL
        product_code_match = product_name.match(/DB-?(\d+)/) ||
          product_name.match(/DBS-?(\d+)/) ||
          product_name.match(/DBM-?(\d+)/) ||
          product_name.match(/DBL-?(\d+)/)

        if product_code_match
          prefix = product_code_match[0].match(/DB-|DBS-|DBM-|DBL-/).to_s
          product_code = "#{prefix}#{product_code_match[1]}"
        else
          # Skip if we can't identify a Miyuki Delica product code
          puts "Skipping product without Miyuki code: #{product_name}"
          next
        end
        # Determine product size based on product code prefix
        # TODO: log when there is an unknown size
        product_size = case product_code
                      when /^DBS-/ then '15/0'
                      when /^DB-/ then '11/0'
                      when /^DBM-/ then '10/0'
                      when /^DBL-/ then '8/0'
                      else 'Unknown'
                      end

        # Get the image URL
        image_element = item.at_css('img.tile-image')
        image_url = image_element ? absolute_url(image_element.attribute(:src)) : nil

        # Extract price if available
        price_element = item.at_css('.pricebooks .pricebook:first-child .price')
        price = price_element ? price_element.text.strip : nil

        # Try to extract color information from the name
        color_name = extract_color_from_name(product_name)

        # Try to extract finish information from the name
        finish_name = extract_finish_from_name(product_name)

        # puts "color_name: #{color_name}"
        # puts "finish_name: #{finish_name}"
        # puts "price: #{price}"
        # puts "image_url: #{image_url}"
        # puts "product_url: #{product_url}"
        # puts "product_code: #{product_code}"
        # puts "product_name: #{product_name}"
        # puts "product_size: #{product_size}"

        # Store bead info
        bead_data = {
          product_code: product_code,
          name: product_name,
          category: 'Miyuki Delica',
          size: '11/0',
          color: color_name,
          finish: finish_name.presence,
          image_url: image_url,
          source_url: product_url,
          price: price
        }

        @results[:beads] << bead_data

        # Print bead details to console
        # puts "Bead: #{product_code} - #{product_name}"
        # puts "  Category: Miyuki Delica"
        # puts "  Size: 11/0"
        # puts "  Color: #{color_name}"
        # puts "  Finish: #{finish_name}" if finish_name.present?
        # puts "  Price: #{price}" if price.present?
        # puts "  Image: #{image_url}"
        # puts "  Source: #{product_url}"
        # puts '---'

        # Optionally follow the product URL to get more detailed information
        # yield request(url: product_url, method: :parse_product_detail, data: bead_data)
      end

      # Follow pagination if available
      next_page = at_css('a.page-link-next')
      if next_page
        next_page_url = absolute_url(next_page.attribute(:href))
        puts "Following next page: #{next_page_url}"
        # parse_product_listings
        yield request(url: next_page_url, method: :parse_product_listings)
      end
    end

    # Parse individual product pages for more detailed information
    def parse_product_detail(data: {})
      puts "Parsing product detail page: #{current_url}"
      
      # Extract detailed product information
      description = at_css('.product-description')&.text&.strip
      specs = {}

      # Extract specifications
      css('.product-specs li').each do |spec|
        spec_text = spec.text.strip
        if spec_text.include?(':')
          key, value = spec_text.split(':', 2).map(&:strip)
          specs[key] = value
        end
      end

      # Look for additional images
      additional_images = css('.product-image-thumbnails img').map do |img|
        absolute_url(img.attribute(:src))
      end

      # Update the bead data with additional information
      bead_index = @results[:beads].find_index { |b| b[:product_code] == data[:product_code] }
      
      if bead_index
        @results[:beads][bead_index] = @results[:beads][bead_index].merge(
          description: description,
          specifications: specs,
          additional_images: additional_images.presence
        )
        
        puts "Updated bead details: #{data[:product_code]} - #{data[:name]}"
      end

      @results
    end
    
    # Method to run the spider and return results
    def self.crawl_and_return_results(options = {})
      results = []
  
      run(options) do |data|
        results << data
      end

      binding.pry
      
      # results = spider&.results || { categories: [], sizes: [], beads: [] }
      
      # Print summary
      puts "\n\n=== CRAWL SUMMARY ==="
      puts "Categories found: #{results[:categories].length}"
      results[:categories].each do |category|
        puts "  - #{category[:name]}"
      end

      puts "\nSizes found: #{results[:sizes].length}"
      results[:sizes].each do |size|
        puts "  - #{size[:category]}: #{size[:size]}"
      end

      puts "\nBeads found: #{results[:beads].length}"
      puts 'Sample of first 5 beads:' if results[:beads].any?
      results[:beads].first(5).each do |bead|
        puts "  - #{bead[:product_code]}: #{bead[:name]} (#{bead[:color]})"
      end

      results
    end

    private

    def all_colors
      @all_bead_colors ||= Catalog::BeadColor.pluck(:name)
    end

    def get_clean_name(name)
      name.gsub(/DB-?\d+/, '').gsub(/Miyuki Delica/, '').strip
    end

    # Helper method to extract color from product name
    def extract_color_from_name(name)
      # Remove product code and common prefixes
      clean_name = get_clean_name(name)

      # Split by common separators and take the last part as the color
      parts = clean_name.split(/[-,\/]/).map(&:strip)
      # Fetch all colors from the database
      
      color = all_colors.find { |c| clean_name.downcase.include?(c.downcase) } || parts.last || 'Unknown'

      # Clean up the color name
      color = color.gsub(/\s+/, ' ').strip
      color = 'Unknown' if color.blank? || color.length < 2

      color = all_colors.find { |c| color.downcase.include?(c.downcase) } || parts.last || 'Unknown'
      
      color
    end

    # Helper method to extract finish from product name
    def extract_finish_from_name(name)
      name = name.downcase
      
      if name.include?('silver lined') || name.include?('silver-lined') || name.include?('silverlined')
        'Silver Lined'
      elsif name.include?('gold lined') || name.include?('gold-lined') || name.include?('goldlined')
        'Gold Lined'
      elsif name.include?('matte')
        'Matte'
      elsif name.include?('opaque')
        'Opaque'
      elsif name.include?('transparent')
        'Transparent'
      elsif name.include?('metallic')
        'Metallic'
      elsif name.include?('galvanized')
        'Galvanized'
      elsif name.include?('luster')
        'Luster'
      elsif name.include?('dyed')
        'Dyed'
      elsif name.include?('ab') || name.include?('aurora borealis') || name.include?('auroraborealis') || name.include?('aurora-borealis') || name.include?('rainbow')
        'Aurora Borealis'
      elsif name.include?('iris')
        'Iris'
      elsif name.include?('lined')
        'Lined'
      else
        ''
      end
    end
  end
end