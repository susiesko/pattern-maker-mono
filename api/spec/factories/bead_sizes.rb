# frozen_string_literal: true

FactoryBot.define do
  factory :bead_size, class: 'Catalog::BeadSize' do
    size { ['6/0', '8/0', '11/0', '15/0'].sample }
    metadata { {} }
    association :brand, factory: :bead_brand
    association :type, factory: :bead_type
  end
end
