# frozen_string_literal: true

FactoryBot.define do
  factory :bead_size, class: 'Catalog::BeadSize' do
    sequence(:size) { |n| "Size #{n}" }
    metadata { { diameter: '3mm', weight: '0.1g' } }

    # Create associations inline to ensure they exist for both build and create
    brand { association :bead_brand }
    type { association :bead_type, brand: brand }
  end
end
