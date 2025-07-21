# frozen_string_literal: true

class Inventory < ApplicationRecord
  belongs_to :user
  belongs_to :bead, class_name: 'Catalog::Bead'

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity_unit, presence: true, inclusion: { in: %w[unit grams ounces pounds] }
  validates :user_id, uniqueness: { scope: :bead_id, message: 'can only have one inventory entry per bead' } # rubocop:disable Rails/I18nLocaleTexts

  scope :by_user, ->(user) { where(user: user) }
  scope :by_bead, ->(bead) { where(bead: bead) }
end
