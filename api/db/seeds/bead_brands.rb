# db/seeds/bead_brands.rb
# Seed bead brands

puts "Seeding bead brands..."

bead_brands = [
  { name: "Miyuki", website: "https://www.miyuki-beads.co.jp/english/" },
  { name: "Toho", website: "https://www.toho-beads.co.jp/english/" },
  { name: "Preciosa", website: "https://www.preciosa-ornela.com" }
]

bead_brands.each do |brand_attrs|
  Catalog::BeadBrand.find_or_create_by!(name: brand_attrs[:name]) do |brand|
    brand.website = brand_attrs[:website]
  end
end

puts "Bead brands seeded. Total count: #{Catalog::BeadBrand.count}"