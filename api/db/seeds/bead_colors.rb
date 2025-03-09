# db/seeds/bead_colors.rb
# Seed bead colors

puts "Seeding bead colors..."

bead_colors = [
  { name: "Transparent" },
  { name: "Translucent" },
  { name: "Black" },
  { name: "Grey" },
  { name: "White" },
  { name: "Pink" },
  { name: "Red" },
  { name: "Orange" },
  { name: "Yellow" },
  { name: "Green" },
  { name: "Blue" },
  { name: "Purple" },
  { name: "Brown" },
  { name: "Beige" },
  { name: "Gold" },
  { name: "Silver" }
]

bead_colors.each do |color_attrs|
  Catalog::BeadColor.find_or_create_by!(name: color_attrs[:name])
end

puts "Bead colors seeded. Total count: #{Catalog::BeadColor.count}"