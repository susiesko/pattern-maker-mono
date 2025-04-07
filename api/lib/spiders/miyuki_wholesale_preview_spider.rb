# frozen_string_literal: true

require 'vessel'

class MiyukiWholesalePreviewSpider < Vessel::Cargo
  # Configure the spider
  domain 'miyukiwholesale.com'
  start_urls 'https://www.miyukiwholesale.com/miyuki/'

  # Set a reasonable delay between requests to be polite
  delay 1.0

  # Set a user agent
  headers 'User-Agent' => 'PatternMaker/1.0 (+https://yourwebsite.com)'

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
    # Extract links to different Miyuki bead categories
    css('a[href*="/miyuki/"]').each do |link|
      href = link.attribute(:href)
      next unless href && href.include?('/miyuki/')

      # Skip links that are not category links
      next if href.include?('miyuki_catalog') ||
              href.include?('miyukilist') ||
              href.include?('miyuki_bestsellers') ||
              href.include?('miyuki_colorrange') ||
              href.include?('miyuki_samecolor') ||
              href.include?('miyuki_colortypes')

      category_url = absolute_url(href)
      category_name = link.text.strip

      # Skip empty or very short category names
      next if category_name.blank? || category_name.length < 3

      # Store category info
      @results[:categories] << {
        name: category_name,
        url: category_url
      }

      puts "Found category: #{category_name} (#{category_url})"

      # Follow each category link and pass the category name as data
      req = request(url: category_url)
      req.instance_variable_set(:@category_name, category_name)
      yield req
    end

    # If no categories were found, try to parse the page as a category page directly
    return unless @results[:categories].empty?

    puts 'No categories found, trying to parse as a category page directly'
    parse_category(data: { category: 'Miyuki Beads' })
  end

  # Parse each bead category page
  def parse_category(data: {})
    category = data[:category]
    puts "Parsing category: #{category} (#{current_url})"

    # Extract all beads from the page
    bead_items = css('a[href*="/miyuki-"] img').map { |img| img.ancestors('a').first }
    puts "Found #{bead_items.length} beads on page"

    bead_items.each do |bead_item|
      # Get the product URL
      product_url = absolute_url(bead_item.attribute(:href))

      # Extract product name and code from the text
      product_text = bead_item.text.strip

      # Try to extract product code from the URL or text
      product_code_match = product_url.match(/miyuki-.*?-(\w+-\d+)/) ||
                           product_text.match(/(\w+\d+)$/)
      product_code = product_code_match ? product_code_match[1] : 'Unknown'

      # Extract name by removing the product code from the text
      name = product_text.gsub(product_code, '').strip
      name = name.gsub(/\s+/, ' ').strip

      # Get the image URL
      image_element = bead_item.at_css('img')
      image_url = image_element ? absolute_url(image_element.attribute(:src)) : nil

      # Try to extract size information from the name or URL
      size_info = ''
      if name.include?('11/0') || product_url.include?('11-0')
        size_info = '11/0'
      elsif name.include?('15/0') || product_url.include?('15-0')
        size_info = '15/0'
      elsif name.include?('8/0') || product_url.include?('8-0')
        size_info = '8/0'
      elsif name.include?('6/0') || product_url.include?('6-0')
        size_info = '6/0'
      end

      # Try to extract color information from the name
      color_parts = name.split('-').map(&:strip)
      color_name = color_parts.last if color_parts.size > 1
      color_name ||= 'Unknown'

      # Try to extract finish information from the name
      finish_name = ''
      if name.include?('silver lined')
        finish_name = 'Silver Lined'
      elsif name.include?('gold lined')
        finish_name = 'Gold Lined'
      elsif name.include?('matte')
        finish_name = 'Matte'
      elsif name.include?('opaque')
        finish_name = 'Opaque'
      elsif name.include?('transparent')
        finish_name = 'Transparent'
      elsif name.include?('metallic')
        finish_name = 'Metallic'
      end

      # Store bead info
      bead_data = {
        product_code: product_code,
        name: name,
        category: category,
        size: size_info,
        color: color_name,
        finish: finish_name.presence,
        image_url: image_url,
        source_url: product_url
      }

      @results[:beads] << bead_data

      # Print bead details to console
      puts "Bead: #{product_code} - #{name}"
      puts "  Category: #{category}"
      puts "  Size: #{size_info}" if size_info.present?
      puts "  Color: #{color_name}"
      puts "  Finish: #{finish_name}" if finish_name.present?
      puts "  Image: #{image_url}"
      puts "  Source: #{product_url}"
      puts '---'

      # Optionally follow the product URL to get more detailed information
      # yield request(url: product_url, method: :parse_product, data: bead_data)
    end

    # If no beads were found with the expected selectors, try some alternative selectors
    return unless bead_items.empty?

    puts 'No beads found with primary selectors, trying alternatives'

    # Try alternative selectors
    css('a[href*="miyuki"] img').map { |img| img.ancestors('a').first }.each do |item|
      product_url = absolute_url(item.attribute(:href))
      product_text = item.text.strip

      puts 'Found item with alternative selector:'
      puts "  URL: #{product_url}"
      puts "  Text: #{product_text}"
      puts '---'
    end

    # Follow pagination if available
    next_page = at_css('a[href*="NEXT"]') || at_css('a:contains("NEXT")') || css('a').find { |a| a.text.include?('NEXT') }
    return unless next_page

    next_page_url = absolute_url(next_page.attribute(:href))
    puts "Following next page: #{next_page_url}"
    yield request(url: next_page_url, method: :parse_category, data: data)
  end

  # Parse individual product pages for more detailed information
  def parse_product(data: {})
    puts "Parsing product page: #{current_url}"

    # Extract additional product details here
    # This would be implemented if we decide to follow product links

    # For now, we'll just return the data we already have
    yield data
  end

  # Method to run the spider and return results
  def self.crawl_and_return_results(options = {})
    results = nil

    run(options) do |data|
      # Store the results when the spider is done
      results = data.results if data.is_a?(MiyukiWholesalePreviewSpider)
    end

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
end
