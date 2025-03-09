# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb

# Master seed file that loads all individual seed files

# Option to clear existing data (development/testing only)
if ENV['RESET_DB'] == 'true'
  puts "Clearing existing data..."
  Catalog::BeadBrand.destroy_all
  Catalog::BeadColor.destroy_all
  Catalog::BeadSize.destroy_all
  Catalog::BeadType.destroy_all
  Catalog::BeadFinish.destroy_all
end

# Explicitly list seed files in the order they should be executed
seed_files = %w[bead_brands.rb bead_types.rb bead_sizes.rb bead_colors.rb bead_finishes.rb]

seed_files.each do |seed_file|
  filename = File.join(Rails.root, 'db', 'seeds', seed_file)
  if File.exist?(filename)
    puts "Loading seed file: #{File.basename(filename)}"
    load filename
  else
    puts "Warning: Seed file #{seed_file} not found."
  end
end

puts "Seeding completed!"


