module Catalog
  class BeadCreatorService
    def self.create_from_spider_data(data) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      # Create or find required associations
      raise if data.nil?

      brand = BeadBrand.find_by(name: data[:brand])
      bead_type = BeadType.find_by(name: data[:type])
      size = BeadSize.find_by(size: data[:size])
      brand_name = brand.name
      brand_product_code = data[:brand_product_code]

      # Create the bead
      bead = Bead.find_or_create_by(brand_product_code: brand_product_code) do |b|
        b.name = data[:name]
        b.brand = brand
        b.type = bead_type
        b.size = size
        b.image = data[:image_url]
        b.metadata = { source_url: data[:source_url], price: data[:price] }
      end

      if data[:colors].present?
        data[:colors].each do |color|
          color = BeadColor.find_by(name: get_color_family_name(color))
          bead.colors << color
        end
      end

      if data[:finishes].present?
        data[:finishes].each do |finish|
          finish = BeadFinish.find_by(name: finish)
          bead.finishes << finish
        end
      end

      bead
    rescue StandardError => e
      puts "Error creating bead #{brand_name || ''} #{brand_product_code || ''}: #{e.message}"
    end

    def self.get_color_family_name(color_name)
      case color_name.downcase
      when 'cobalt'
        'Blue'
      when 'ivory'
        'White'
      when 'gunmetal'
        'Black'
      else
        color_name
      end
    end
  end
end
