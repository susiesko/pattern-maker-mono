# frozen_string_literal: true

require 'vessel'

class MiyukiSpider < Vessel::Cargo
  # Configure the spider
  domain 'miyukiwholesale.com'
  start_urls 'https://www.miyukiwholesale.com/miyuki/'

  # Set a reasonable delay between requests to be polite
  delay 1.0

  # Set a user agent
  headers 'User-Agent' => 'PatternMaker/1.0 (+https://yourwebsite.com)'

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

      Rails.logger.info "Found category: #{category_name} (#{category_url})"

      # Follow each category link and pass the category name as data
      yield request(url: category_url, method: :parse_category, data: { category: category_name })
    end

    # If no categories were found, try to parse the page as a category page directly
    return unless css('a[href*="/miyuki/"]').empty?

    Rails.logger.info 'No categories found, trying to parse as a category page directly'
    parse_category(data: { category: 'Miyuki Beads' })
  end

  # Parse each bead category page
  def parse_category(data: {})
    category = data[:category]
    Rails.logger.info "Parsing category: #{category} (#{current_url})"

    # Find the brand in the database or create it if it doesn't exist
    brand = Catalog::BeadBrand.find_or_create_by!(name: 'Miyuki', website: 'https://www.miyukiwholesale.com/')

    # Find or create the bead type
    bead_type = Catalog::BeadType.find_or_create_by!(name: category, brand: brand)

    # Extract all beads from the page
    bead_items = css('a[href*="/miyuki-"] img').map { |img| img.ancestors('a').first }
    Rails.logger.info "Found #{bead_items.length} beads on page"

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

      # Create or find the bead size
      bead_size = Catalog::BeadSize.find_or_create_by!(
        size: size_info.presence || 'Unknown',
        brand: brand,
        type: bead_type,
        metadata: { source_url: current_url }
      )

      # Try to extract color information from the name
      color_parts = name.split('-').map(&:strip)
      color_name = color_parts.last if color_parts.size > 1
      color_name ||= 'Unknown'
      color = Catalog::BeadColor.find_or_create_by!(name: color_name)

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

      finish = Catalog::BeadFinish.find_or_create_by!(name: finish_name) if finish_name.present?

      # Create or update the bead
      bead = Catalog::Bead.find_or_create_by!(
        brand_product_code: product_code,
        brand: brand,
        type: bead_type,
        size: bead_size
      )

      # Update bead attributes
      bead.update!(
        name: name,
        image: image_url,
        metadata: {
          source_url: product_url,
          scraped_at: Time.current
        }
      )

      # Associate with color
      bead.bead_color_links.find_or_create_by!(color: color)

      # Associate with finish if available
      bead.bead_finish_links.find_or_create_by!(finish: finish) if finish.present?

      # Log the scraped bead
      Rails.logger.info "Scraped bead: #{product_code} - #{name}"
    end

    # If no beads were found with the expected selectors, try some alternative selectors
    return unless bead_items.empty?

    Rails.logger.info 'No beads found with primary selectors, trying alternatives'

    # Try alternative selectors
    css('a[href*="miyuki"] img').map { |img| img.ancestors('a').first }.each do |item|
      product_url = absolute_url(item.attribute(:href))
      product_text = item.text.strip

      Rails.logger.info "Found item with alternative selector: #{product_text} (#{product_url})"
    end

    # Follow pagination if available
    next_page = at_css('a[href*="NEXT"]') || at_css('a:contains("NEXT")') || css('a').find { |a| a.text.include?('NEXT') }
    if next_page
      next_page_url = absolute_url(next_page.attribute(:href))
      Rails.logger.info "Following next page: #{next_page_url}"
      yield request(url: next_page_url, method: :parse_category, data: data)
    end
  end
end
