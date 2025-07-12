# frozen_string_literal: true

require 'vessel'

module Spiders
  module FireMountainGems
    class Crawler < Vessel::Cargo
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
        @results = []
      end

      # Define the parser for the main beads page
      def parse
        log_message_quiet "Parsing main Miyuki Delica page: #{current_url}"

        yield request(url: current_url, method: :parse_product_listings)
      end

      # Parse the product listings on the current page
      def parse_product_listings
        # Extract all product items from the page

        begin
          product_items = css('.product-tile')
        rescue StandardError => e
          log_message_quiet "Error parsing product listings: #{e.message}"
          return
        end

        log_message_quiet "Found #{product_items.length} products on page"

        product_items.each do |item|
          bead_data = parse_product(item)

          yield bead_data
        end

        # Follow pagination if available
        next_page = at_css('a.page-link-next')
        return unless next_page

        next_page_url = absolute_url(next_page.attribute(:href))
        log_message_quiet "Following next page: #{next_page_url}"
        yield request(url: next_page_url, method: :parse_product_listings)
      end

      def parse_product(item)
        # Extract product details
        product_link = item.at_css('.link')
        raise 'no product link found' unless product_link

        product_url = absolute_url(product_link.attribute(:href))
        product_name = item.at_css('h3.name').text.strip.gsub(/\n\s+Product Title/, '')

        # Extract product code from the name or URL
        product_code_match = product_name.match(/DB-?(\d+)/) ||
                             product_name.match(/DBS-?(\d+)/) ||
                             product_name.match(/DBM-?(\d+)/) ||
                             product_name.match(/DBL-?(\d+)/)

        raise "Skipping non-delicas: #{product_name}" unless product_code_match

        prefix = product_code_match[0].match(/DB-|DBS-|DBM-|DBL-/).to_s
        product_code = "#{prefix}#{product_code_match[1]}"

        # Skip if we can't identify a Miyuki Delica product code

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

        # Try to extract finish information from the name
        finish_names = extract_finishes_from_name(product_name)

        # Try to extract color information from the name
        color_names = extract_colors_from_name(product_name)

        {
          name: product_name,
          brand_product_code: product_code,
          brand: 'Miyuki',
          type: 'Delica',
          size: product_size,
          image: image_url,
          colors: color_names.split(','),
          finishes: finish_names.split(','),
          metadata: {
            source_url: product_url,
            price: price,
          },
        }
      rescue StandardError => e
        {
          error: "Error parsing product: #{e.message}",
          name: product_name || '',
          brand_product_code: product_code || '',
          brand: 'Miyuki',
          type: 'Delica',
          size: product_size || '',
          image: image_url || '',
          colors: color_names&.split(',') || [],
          finishes: finish_names&.split(',') || [],
          metadata: {
            source_url: product_url || '',
            price: price || '',
          },
        }
      end

      # Parse individual product pages for more detailed information
      def parse_product_detail(data: {})
        log_message_quiet "Parsing product detail page: #{current_url}"

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
            additional_images: additional_images.presence,
          )

          log_message_quiet "Updated bead details: #{data[:product_code]} - #{data[:name]}"
        end

        @results
      end

      # Method to run the spider and return results
      def self.crawl_and_return_results(options = {})
        results = []

        run(options) do |data|
          results << data
        end

        puts "\nBeads found: #{results.length}"

        results
      end

      private

      def all_colors
        @all_colors ||= Catalog::BeadColor.pluck(:name)
      end

      def all_finishes
        @all_finishes ||= Catalog::BeadFinish.pluck(:name)
      end

      def get_clean_name(name)
        name.gsub(/DB-?\d+/, '').gsub('Miyuki Delica', '').strip
      end

      def get_clean_color_name(name)
        clean_color_name = get_clean_name(name)

        clean_color_name = clean_color_name.split(',').last

        clean_color_name = clean_color_name.gsub(' ().', '').strip

        all_finishes.each do |finish|
          clean_color_name = clean_color_name.downcase.gsub(finish.downcase, '').strip
        end

        clean_color_name
      end

      def get_clean_finish_name(name)
        clean_finish_name = get_clean_name(name)

        clean_finish_name = clean_finish_name.split(',').last

        clean_finish_name = clean_finish_name.gsub(' ().', '').strip

        all_colors.each do |color|
          clean_finish_name = clean_finish_name.downcase.gsub(color.downcase, '').strip
        end

        clean_finish_name
      end

      # Helper method to extract color from product name
      def extract_colors_from_name(name)
        colors = []

        # Remove product code and common prefixes
        clean_name = get_clean_color_name(name)

        # Split by common separators and take the last part as the color
        # Fetch all colors from the database

        all_colors.each do |color|
          colors << color.gsub(/\s+/, ' ').strip.capitalize if clean_name.downcase.include?(color.downcase)
        end

        colors << clean_name if colors.empty?

        colors.join(',')
      end

      # Helper method to extract finish from product name
      def extract_finishes_from_name(name)
        finishes = []

        all_finishes.each do |finish|
          finishes << finish.gsub(/\s+/, ' ').strip if name.downcase.include?(finish.downcase)
        end

        finishes.join(',')
      end

      def log_message_quiet(message)
        # log_message message
      end

      def log_message(message)
        puts "Crawler: #{message}"
      end
    end
  end
end
