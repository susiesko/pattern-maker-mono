# frozen_string_literal: true

FactoryBot.define do
  factory :bead_type, class: 'Catalog::BeadType' do
    name { Faker::Commerce.product_name }
    association :brand, factory: :bead_brand
  end
end
