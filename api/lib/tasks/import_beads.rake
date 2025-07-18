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
    
    # Get reference data
    brands = BeadBrand.all.index_by(&:name)
    types = BeadType.all.index_by(&:name)
    sizes = BeadSize.all.index_by(&:name)
    
    # Create missing reference data if needed
    miyuki_brand = brands['Miyuki'] || BeadBrand.create!(name: 'Miyuki')
    delica_type = types['Delica'] || BeadType.create!(name: 'Delica')
    
    # Import beads
    imported_count = 0
    skipped_count = 0
    
    beads_data.each do |bead_data|
      begin
        # Find or create size
        size = sizes[bead_data['size']] || BeadSize.create!(name: bead_data['size'])
        
        # Create bead record
        bead = Bead.find_or_initialize_by(
          brand: miyuki_brand,
          brand_product_code: bead_data['product_code']
        )
        
        # Update attributes
        bead.assign_attributes(
          type: delica_type,
          name: bead_data['name'],
          size: size,
          image: bead_data['image_url'],
          has_swatch: false
        )
        
        if bead.save
          imported_count += 1
          print "." if imported_count % 10 == 0
        else
          skipped_count += 1
          puts "\nWARNING: Failed to save bead: #{bead_data['name']} - #{bead.errors.full_messages.join(', ')}"
        end
        
      rescue => e
        skipped_count += 1
        puts "\nERROR: Error importing bead #{bead_data['name']}: #{e.message}"
      end
    end
    
    puts "\n\nImport complete!"
    puts "Imported: #{imported_count} beads"
    puts "Skipped: #{skipped_count} beads"
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