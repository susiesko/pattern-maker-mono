namespace :beads do
  desc "Import beads from JSON file created by Python crawler"
  task import: :environment do
    json_file = Rails.root.join('crawler', 'beads.json')
    
    unless File.exist?(json_file)
      puts "ERROR: beads.json not found at #{json_file}"
      puts "Run the Python crawler first: cd crawler && python run_crawler.py"
      exit 1
    end
    
    puts "Importing beads from #{json_file}..."
    
    # Load JSON data
    beads_data = JSON.parse(File.read(json_file))
    puts "Found #{beads_data.length} beads to import"
    
    # Get reference data with caching
    brands = BeadBrand.all.index_by(&:name)
    types = BeadType.all.index_by(&:name)
    sizes = BeadSize.all.index_by(&:name)
    
    # Create missing reference data if needed
    miyuki_brand = brands['Miyuki'] || BeadBrand.create!(name: 'Miyuki')
    delica_type = types['Delica'] || BeadType.create!(name: 'Delica')
    
    # Prepare bulk data
    bulk_beads = []
    bulk_sizes = []
    size_cache = sizes.dup
    existing_codes = Set.new(Bead.joins(:brand).where(bead_brands: { name: 'Miyuki' }).pluck(:brand_product_code))
    
    puts "Processing #{beads_data.length} beads for bulk import..."
    
    beads_data.each_with_index do |bead_data, index|
      begin
        # Skip if already exists
        if existing_codes.include?(bead_data['product_code'])
          next
        end
        
        # Handle size creation/lookup
        size_name = bead_data['size']
        unless size_cache[size_name]
          # Add to bulk sizes if not already queued
          unless bulk_sizes.any? { |s| s[:name] == size_name }
            bulk_sizes << { 
              name: size_name, 
              created_at: Time.current, 
              updated_at: Time.current 
            }
          end
          # Cache for future lookups
          size_cache[size_name] = true
        end
        
        # Prepare bead for bulk insert
        bulk_beads << {
          brand_id: miyuki_brand.id,
          type_id: delica_type.id,
          brand_product_code: bead_data['product_code'],
          name: bead_data['name'],
          image: bead_data['image_url'],
          has_swatch: false,
          created_at: Time.current,
          updated_at: Time.current
        }
        
        print "." if (index + 1) % 100 == 0
        
      rescue => e
        puts "\nERROR: Error processing bead #{bead_data['name']}: #{e.message}"
      end
    end
    
    puts "\nStarting bulk operations..."
    
    # Bulk insert sizes first
    if bulk_sizes.any?
      puts "Creating #{bulk_sizes.size} new sizes..."
      BeadSize.insert_all(bulk_sizes, returning: false)
      
      # Refresh size cache after bulk insert
      size_cache = BeadSize.all.index_by(&:name)
    end
    
    # Add size_id to bulk beads
    bulk_beads.each do |bead|
      size_name = beads_data.find { |bd| bd['product_code'] == bead[:brand_product_code] }&.dig('size')
      bead[:size_id] = size_cache[size_name]&.id if size_name
    end
    
    # Bulk insert beads
    if bulk_beads.any?
      puts "Importing #{bulk_beads.size} beads..."
      
      # Use insert_all with batch processing for very large datasets
      batch_size = 1000
      bulk_beads.each_slice(batch_size).with_index do |batch, batch_index|
        Bead.insert_all(batch, returning: false)
        puts "Imported batch #{batch_index + 1}/#{(bulk_beads.size / batch_size.to_f).ceil}"
      end
    end
    
    puts "\nImport complete!"
    puts "Processed: #{beads_data.length} beads"
    puts "Imported: #{bulk_beads.size} new beads"
    puts "Skipped: #{beads_data.length - bulk_beads.size} existing beads"
    puts "Created: #{bulk_sizes.size} new sizes"
    puts "JSON file: #{json_file}"
  end
  
  desc "Show import status"
  task status: :environment do
    total_beads = Bead.count
    miyuki_beads = Bead.joins(:brand).where(bead_brands: { name: 'Miyuki' }).count
    
    puts "Bead Import Status"
    puts "=================="
    puts "Total beads in database: #{total_beads}"
    puts "Miyuki beads: #{miyuki_beads}"
    puts ""
    
    if File.exist?(Rails.root.join('crawler', 'beads.json'))
      json_data = JSON.parse(File.read(Rails.root.join('crawler', 'beads.json')))
      puts "beads.json contains: #{json_data.length} beads"
      puts "Last modified: #{File.mtime(Rails.root.join('crawler', 'beads.json'))}"
    else
      puts "ERROR: beads.json not found - run the crawler first"
    end
  end
end 