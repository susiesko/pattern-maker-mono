# frozen_string_literal: true

FactoryBot.define do
  factory :bead, class: 'Catalog::Bead' do
    name { Faker::Commerce.product_name }
    brand_product_code { "#{('A'..'Z').to_a.sample}#{Faker::Number.number(digits: 4)}" }
    metadata { {} }
    association :brand, factory: :bead_brand
    association :type, factory: :bead_type
    association :size, factory: :bead_size

    # Add colors and finishes after creation
    transient do
      colors_count { 1 }
      finishes_count { 1 }
    end

    after(:create) do |bead, evaluator|
      create_list(:bead_color_link, evaluator.colors_count, bead: bead)
      create_list(:bead_finish_link, evaluator.finishes_count, bead: bead)
    end
  end
end
