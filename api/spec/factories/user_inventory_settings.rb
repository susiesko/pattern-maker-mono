# frozen_string_literal: true

FactoryBot.define do
  factory :user_inventory_setting do
    association :user

    field_definitions do
      [
        { 'fieldName' => 'location', 'fieldType' => 'text', 'label' => 'Storage Location' },
        { 'fieldName' => 'purchase_date', 'fieldType' => 'date', 'label' => 'Purchase Date' },
        { 'fieldName' => 'notes', 'fieldType' => 'textarea', 'label' => 'Notes' },
      ]
    end

    trait :empty_fields do
      field_definitions { [] }
    end

    trait :with_custom_fields do
      field_definitions do
        [
          { 'fieldName' => 'supplier', 'fieldType' => 'text', 'label' => 'Supplier' },
          { 'fieldName' => 'cost', 'fieldType' => 'number', 'label' => 'Cost' },
          { 'fieldName' => 'is_favorite', 'fieldType' => 'boolean', 'label' => 'Is Favorite?' },
        ]
      end
    end
  end
end
