# frozen_string_literal: true

FactoryBot.define do
  factory :bead_brand, class: 'Catalog::BeadBrand' do
    sequence(:name) { |n| "Brand #{n}" }
    website { "https://www.example.com" }
  end
end
