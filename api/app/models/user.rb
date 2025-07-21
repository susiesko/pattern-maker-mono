# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  # Associations
  has_many :inventories, dependent: :destroy
  has_one :user_inventory_setting, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :username, length: { minimum: 3, maximum: 30 }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  # Callbacks
  before_save :downcase_email

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
