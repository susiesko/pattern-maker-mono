# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    username { Faker::Internet.unique.username(specifier: 3..30) }
    email { Faker::Internet.unique.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    admin { false }

    trait :admin do
      admin { true }
    end
  end
end
