# frozen_string_literal: true

require 'vessel'

class FireMountainGemsSpider < Vessel::Cargo
  # Configure the spider
  domain 'firemountaingems.com'
  start_urls 'https://www.firemountaingems.com/beads/beads-by-brand/miyuki/delica/11-0-delica-round-beads/'

  # Set a reasonable delay between requests to be polite
  delay 1.0

  # Set a user agent
  headers 'User-Agent' => 'PatternMaker/1.0 (+https://yourwebsite.com)'

  # Define the parser for the main beads page
  def parse
    Rails.logger.info "Parsing main Miyuki Delica page: #{current_url}"

    # Find the size 11/0 category link
    size_11_link = css('a').find do |link|
      link.text.strip.downcase.include?('11/0') ||
      link.text.strip.downcase.include?('11-0') ||
      link.text.strip.downcase.include?('11º')
    end

    if size_11_link
      size_11_url = absolute_url(size_11_link.attribute(:href))
      Rails.logger.info "Found Size 11/0 link: #{size_11_url}"
      yield request(url: size_11_url, method: :parse_size_page)
    else
      # If we can't find a specific size link, try to parse the current page for products
      Rails.logger.info "No specific size 11/0 link found, parsing current page for products"
      parse_product_listings
    end
  end

  # Parse the size-specific page
  def parse_size_page
    Rails.logger.info "Parsing Size 11/0 page: #{current_url}"
    parse_product_listings
  end

  # Parse the product listings on the current page
  def parse_product_listings
    # Find the brand in the database or create it if it doesn't exist
    brand = Catalog::BeadBrand.find_or_create_by!(
      name: 'Miyuki', 
      website: 'https://www.miyuki-beads.co.jp/english/'
    )

    # Find or create the bead type for Delica
    bead_type = Catalog::BeadType.find_or_create_by!(
      name: 'Delica Beads',
      brand: brand
    )

    # Find or create the bead size for 11/0
    bead_size = Catalog::BeadSize.find_or_create_by!(
      size: '11/0',
      brand: brand,
      type: bead_type,
      metadata: { source_url: current_url }
    )

    # Extract all product items from the page
    product_items = css('.product-item')
    Rails.logger.info "Found #{product_items.length} products on page"

    product_items.each do |item|
      # Extract product details
      product_link = item.at_css('.product-name a')
      next unless product_link

      product_url = absolute_url(product_link.attribute(:href))
      product_name = product_link.text.strip

      # Extract product code from the name or URL
      product_code_match = product_name.match(/DB-?(\d+)/) || 
                           product_url.match(/DB-?(\d+)/)
      
      if product_code_match
        product_code = "DB#{product_code_match[1]}"
      else
        # Skip if we can't identify a Miyuki Delica product code
        Rails.logger.info "Skipping product without Miyuki code: #{product_name}"
        next
      end

      # Get the image URL
      image_element = item.at_css('.product-image img')
      image_url = image_element ? absolute_url(image_element.attribute(:src)) : nil

      # Extract price if available
      price_element = item.at_css('.price')
      price = price_element ? price_element.text.strip : nil

      # Try to extract color information from the name
      color_name = extract_color_from_name(product_name)
      color = Catalog::BeadColor.find_or_create_by!(name: color_name)

      # Try to extract finish information from the name
      finish_name = extract_finish_from_name(product_name)
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
        name: product_name,
        image: image_url,
        metadata: {
          source_url: product_url,
          scraped_at: Time.current,
          price: price
        }
      )

      # Associate with color
      bead.bead_color_links.find_or_create_by!(color: color)

      # Associate with finish if available
      bead.bead_finish_links.find_or_create_by!(finish: finish) if finish.present?

      # Log the scraped bead
      Rails.logger.info "Scraped bead: #{product_code} - #{product_name}"

      # Optionally follow the product URL to get more detailed information
      yield request(url: product_url, method: :parse_product_detail, data: { bead_id: bead.id })
    end

    # Follow pagination if available
    next_page = at_css('.next a')
    if next_page
      next_page_url = absolute_url(next_page.attribute(:href))
      Rails.logger.info "Following next page: #{next_page_url}"
      yield request(url: next_page_url, method: :parse_product_listings)
    end
  end

  # Parse individual product pages for more detailed information
  def parse_product_detail(data: {})
    Rails.logger.info "Parsing product detail page: #{current_url}"
    
    bead_id = data[:bead_id]
    return unless bead_id

    bead = Catalog::Bead.find_by(id: bead_id)
    return unless bead

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

    # Update bead with additional information
    bead.update!(
      metadata: bead.metadata.merge(
        description: description,
        specifications: specs,
        updated_at: Time.current
      )
    )

    # Look for additional images
    additional_images = css('.product-image-thumbnails img').map do |img|
      absolute_url(img.attribute(:src))
    end

    if additional_images.any?
      bead.update!(
        metadata: bead.metadata.merge(
          additional_images: additional_images
        )
      )
    end

    Rails.logger.info "Updated bead details: #{bead.brand_product_code} - #{bead.name}"
  end

  private

  # Helper method to extract color from product name
  def extract_color_from_name(name)
    # Remove product code and common prefixes
    clean_name = name.gsub(/DB-?\d+/, '').gsub(/Miyuki Delica/, '').strip
    
    # Split by common separators and take the last part as the color
    parts = clean_name.split(/[-,\/]/).map(&:strip)
    color = parts.last || 'Unknown'
    
    # Clean up the color name
    color = color.gsub(/\s+/, ' ').strip
    color = 'Unknown' if color.blank? || color.length < 2
    
    color
  end

  # Helper method to extract finish from product name
  def extract_finish_from_name(name)
    name = name.downcase
    
    if name.include?('silver lined')
      'Silver Lined'
    elsif name.include?('gold lined')
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
    elsif name.include?('ab') || name.include?('aurora borealis')
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