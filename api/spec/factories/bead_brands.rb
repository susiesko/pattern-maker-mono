FactoryBot.define do
  factory :bead_brand, class: 'Catalog::BeadBrand' do
    name { Faker::Company.name }
    website { Faker::Internet.url }
  end
end