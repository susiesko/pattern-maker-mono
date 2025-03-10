# frozen_string_literal: true

FactoryBot.define do
  factory :bead_color, class: 'Catalog::BeadColor' do
    name { Faker::Color.color_name }
  end
end
