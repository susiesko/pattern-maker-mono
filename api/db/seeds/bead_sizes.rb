# frozen_string_literal: true

# db/seeds/bead_sizes.rb
# Seed bead sizes for different bead types

puts 'Seeding bead sizes...'

# Seed bead sizes for Miyuki Delica
miyuki_brand = Catalog::BeadBrand.find_by(name: 'Miyuki')
if miyuki_brand
  delica_type = Catalog::BeadType.find_by(name: 'Delica', brand: miyuki_brand)
  if delica_type
    bead_sizes = [
      { size: '6/0' },
      { size: '8/0' },
      { size: '11/0' },
      { size: '15/0' }
    ]

    bead_sizes.each do |size_attrs|
      Catalog::BeadSize.find_or_create_by!(size: size_attrs[:size], type: delica_type,
                                           brand: miyuki_brand)
    end

    puts "Bead sizes for Miyuki Delica seeded. Total count: #{Catalog::BeadSize.where(type: delica_type).count}"
  else
    puts 'Warning: Delica bead type not found. Please run bead_types seed first.'
  end
else
  puts 'Warning: Miyuki brand not found. Please run bead_brands seed first.'
end

# Seed bead sizes for Miyuki Round
if miyuki_brand
  round_type = Catalog::BeadType.find_by(name: 'Round', brand: miyuki_brand)
  if round_type
    round_bead_sizes = [
      { size: '6/0' },
      { size: '8/0' },
      { size: '11/0' },
      { size: '15/0' }
    ]

    round_bead_sizes.each do |size_attrs|
      Catalog::BeadSize.find_or_create_by!(size: size_attrs[:size], type: round_type,
                                           brand: miyuki_brand)
    end

    puts "Bead sizes for Miyuki Round seeded. Total count: #{Catalog::BeadSize.where(type: round_type).count}"
  else
    puts 'Warning: Round bead type not found. Please run bead_types seed first.'
  end
end
