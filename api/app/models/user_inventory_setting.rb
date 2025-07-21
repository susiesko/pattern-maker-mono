# frozen_string_literal: true

class UserInventorySetting < ApplicationRecord
  belongs_to :user

  validates :field_definitions, presence: true
  validates :user_id, uniqueness: true
  validate :valid_field_definitions_format

  scope :by_user, ->(user) { where(user: user) }

  def field_definitions_hash
    field_definitions || []
  end

  private

  def valid_field_definitions_format
    return if field_definitions.blank?

    unless field_definitions.is_a?(Array)
      errors.add(:field_definitions, 'must be an array')
      return
    end

    field_definitions.each_with_index { |field, index| validate_field_format(field, index) }
  end

  def validate_field_format(field, index)
    return add_field_error(index, 'must be a hash') unless field.is_a?(Hash)

    validate_required_keys(field, index)
    validate_field_type(field, index)
  end

  def validate_required_keys(field, index)
    %w[fieldName fieldType label].each do |key|
      next if field.key?(key) && field[key].present?

      add_field_error(index, "is missing required key: #{key}")
    end
  end

  def validate_field_type(field, index)
    valid_types = %w[text number date select textarea boolean]
    return if valid_types.include?(field['fieldType'])

    add_field_error(index, "has invalid fieldType. Must be one of: #{valid_types.join(', ')}")
  end

  def add_field_error(index, message)
    errors.add(:field_definitions, "field at index #{index} #{message}")
  end
end
