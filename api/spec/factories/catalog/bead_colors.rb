# frozen_string_literal: true

FactoryBot.define do
  factory :bead_color, class: 'Catalog::BeadColor' do
    sequence(:name) { |n| "Color #{n}" }
  end
end
