# frozen_string_literal: true

# db/seeds/bead_finishes.rb
# Seed bead finishes

puts 'Seeding bead finishes...'

# Common bead finishes across brands
bead_finishes = [
  { name: 'Matte' },
  { name: 'Glossy' },
  { name: 'Metallic' },
  { name: 'Galvanized' },
  { name: 'AB (Aurora Borealis)' },
  { name: 'Luster' },
  { name: 'Ceylon' },
  { name: 'Opaque' },
  { name: 'Color-Lined' },
  { name: 'Silver-Lined' },
  { name: 'Gold-Lined' },
  { name: 'Iris' },
  { name: 'Duracoat' },
  { name: 'Picasso'  }
]

bead_finishes.each do |finish_attrs|
  Catalog::BeadFinish.find_or_create_by!(name: finish_attrs[:name])
end

puts "Bead finishes seeded. Total count: #{Catalog::BeadFinish.count}"
