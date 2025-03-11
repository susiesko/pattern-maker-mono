# frozen_string_literal: true

FactoryBot.define do
  factory :bead_finish, class: 'Catalog::BeadFinish' do
    name { %w[Matte Glossy Metallic Galvanized AB Luster].sample }
  end
end
