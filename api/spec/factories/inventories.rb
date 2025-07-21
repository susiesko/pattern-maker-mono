# frozen_string_literal: true

FactoryBot.define do
  factory :inventory do
    association :user
    bead { association :bead }

    quantity { 10.5 }
    quantity_unit { 'unit' }

    trait :with_grams do
      quantity { 25.5 }
      quantity_unit { 'grams' }
    end

    trait :with_ounces do
      quantity { 2.5 }
      quantity_unit { 'ounces' }
    end

    trait :zero_quantity do
      quantity { 0 }
    end
  end
end
