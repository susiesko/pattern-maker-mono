# frozen_string_literal: true

FactoryBot.define do
  factory :bead_finish, class: 'Catalog::BeadFinish' do
    sequence(:name) { |n| "Finish #{n}" }
  end
end
