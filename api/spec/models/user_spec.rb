# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  # Create a valid subject for testing
  subject {
    User.new(
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    )
  }

  # Validations
  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
    it { is_expected.to validate_length_of(:username).is_at_least(3).is_at_most(30) }
    it { is_expected.to validate_length_of(:password).is_at_least(6) }
    it { is_expected.to have_secure_password }
  end

  # Instance methods
  describe 'instance methods' do
    describe '#downcase_email' do
      it 'converts email to lowercase before saving' do
        user = User.create(
          username: 'testuser2',
          email: 'TEST@EXAMPLE.COM',
          password: 'password123',
          password_confirmation: 'password123'
        )
        expect(user.email).to eq('test@example.com')
      end
    end
  end
end
