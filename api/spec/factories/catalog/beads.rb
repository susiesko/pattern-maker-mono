# frozen_string_literal: true

FactoryBot.define do
  factory :bead, class: 'Catalog::Bead' do
    sequence(:name) { |n| "Bead #{n}" }
    sequence(:brand_product_code) { |n| "BP-#{n}" }
    metadata { { material: 'glass', shape: 'round' } }
    image { 'bead.jpg' }

    # Create brand association
    brand { association :bead_brand }

    # New detailed attributes with default values
    shape { 'Delica' }
    size { '11/0' }
    color_group { 'red' }
    glass_group { 'Opaque' }
    finish { 'Matte' }
    dyed { 'Dyed' }
    galvanized { 'Non-galvanized' }
    plating { 'Non-plating' }

    trait :delica do
      shape { 'Delica' }
      size { '11/0' }
    end

    trait :rocailles do
      shape { 'Rocailles' }
      size { '8/0' }
    end

    trait :red do
      color_group { 'red' }
    end

    trait :blue do
      color_group { 'blue' }
    end

    trait :opaque do
      glass_group { 'Opaque' }
    end

    trait :transparent do
      glass_group { 'Transparent' }
    end

    trait :matte do
      finish { 'Matte' }
    end

    trait :glossy do
      finish { 'Glossy' }
    end

    trait :dyed do
      dyed { 'Dyed' }
    end

    trait :non_dyed do
      dyed { 'Non-dyed' }
    end

    trait :galvanized do
      galvanized { 'Galvanized' }
    end

    trait :non_galvanized do
      galvanized { 'Non-galvanized' }
    end

    trait :plating do
      plating { 'Plating' }
    end

    trait :non_plating do
      plating { 'Non-plating' }
    end
  end
end
