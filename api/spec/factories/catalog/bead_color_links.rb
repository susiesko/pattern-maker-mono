# frozen_string_literal: true

FactoryBot.define do
  factory :bead_color_link, class: 'Catalog::BeadColorLink' do
    association :bead, factory: :bead
    association :color, factory: :bead_color
  end
end