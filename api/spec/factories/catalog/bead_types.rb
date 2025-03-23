# frozen_string_literal: true

FactoryBot.define do
  factory :bead_type, class: 'Catalog::BeadType' do
    sequence(:name) { |n| "Type #{n}" }

    # Create association inline to ensure it exists for both build and create
    brand { association :bead_brand }
  end
end
