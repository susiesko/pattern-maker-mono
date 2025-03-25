# frozen_string_literal: true

FactoryBot.define do
  factory :bead, class: 'Catalog::Bead' do
    sequence(:name) { |n| "Bead #{n}" }
    sequence(:brand_product_code) { |n| "BP-#{n}" }
    metadata { { material: 'glass', shape: 'round' } }
    image { 'bead.jpg' }

    # Create associations inline to ensure they exist for both build and create
    brand { association :bead_brand }

    # For size and type, we need to ensure they use the same brand
    size { association :bead_size, brand: brand }
    type { association :bead_type, brand: brand }

    trait :with_colors do
      transient do
        colors_count { 2 }
      end

      after(:create) do |bead, evaluator|
        evaluator.colors_count.times do
          color = create(:bead_color)
          create(:bead_color_link, bead: bead, color: color)
        end
      end
    end

    trait :with_finishes do
      transient do
        finishes_count { 2 }
      end

      after(:create) do |bead, evaluator|
        evaluator.finishes_count.times do
          finish = create(:bead_finish)
          create(:bead_finish_link, bead: bead, finish: finish)
        end
      end
    end

    factory :bead_with_colors_and_finishes do
      with_colors
      with_finishes
    end
  end
end
