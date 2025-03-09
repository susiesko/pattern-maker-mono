# db/seeds/bead_types.rb
# Seed bead types for different brands

puts "Seeding bead types..."

# Seed bead types for Miyuki
miyuki_brand = Catalog::BeadBrand.find_by(name: "Miyuki")
if miyuki_brand
  miyuki_bead_types = [
    { name: "Delica" },
    { name: "Round" }
  ]

  miyuki_bead_types.each do |type_attrs|
    Catalog::BeadType.find_or_create_by!(name: type_attrs[:name], brand: miyuki_brand)
  end

  puts "Bead types for Miyuki seeded. Total count: #{Catalog::BeadType.where(brand: miyuki_brand).count}"
else
  puts "Warning: Miyuki brand not found. Please run bead_brands seed first."
end

# Seed bead types for Toho
toho_brand = Catalog::BeadBrand.find_by(name: "Toho")
if toho_brand
  toho_bead_types = [
    { name: "Aiko"},
    { name: "Treasure" },
    { name: "Seed" }
  ]

  toho_bead_types.each do |type_attrs|
    Catalog::BeadType.find_or_create_by!(name: type_attrs[:name], brand: toho_brand)
  end

  puts "Bead types for Toho seeded. Total count: #{Catalog::BeadType.where(brand: toho_brand).count}"
else
  puts "Warning: Toho brand not found. Please run bead_brands seed first."
end