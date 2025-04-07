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

    context 'for email format validation' do
      it 'is valid with a proper email format' do
        user = User.new(
          username: 'emailtest',
          email: 'valid@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        )
        expect(user).to be_valid
      end

      it 'is invalid with an improper email format' do
        user = User.new(
          username: 'emailtest',
          email: 'invalid-email',
          password: 'password123',
          password_confirmation: 'password123'
        )
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include('is invalid')
      end
    end

    context 'when validating password' do
      it 'requires password_confirmation to match password' do
        user = User.new(
          username: 'passtest',
          email: 'pass@example.com',
          password: 'password123',
          password_confirmation: 'different123'
        )
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to include("doesn't match Password")
      end

      it 'does not require password when updating other attributes' do
        user = create(:user)
        user.username = 'updatedname'
        expect(user).to be_valid
      end

      it 'requires password validation when updating password' do
        user = create(:user)
        user.password = 'short'
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
      end
    end
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

      it 'does not modify the email if it is already lowercase' do
        user = User.create(
          username: 'testuser3',
          email: 'lowercase@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        )
        expect(user.email).to eq('lowercase@example.com')
      end

      it 'handles nil email without error' do
        user = User.new(username: 'niltest', password: 'password123', password_confirmation: 'password123')
        expect { user.send(:downcase_email) }.not_to raise_error
      end
    end
  end

  # Authentication
  describe 'authentication' do
    let(:user) { create(:user, password: 'testpassword', password_confirmation: 'testpassword') }

    it 'authenticates with correct password' do
      expect(user.authenticate('testpassword')).to eq(user)
    end

    it 'does not authenticate with incorrect password' do
      expect(user.authenticate('wrongpassword')).to be_falsey
    end
  end

  # Admin functionality
  describe 'admin functionality' do
    it 'defaults admin to false' do
      user = User.create(
        username: 'regularuser',
        email: 'regular@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      )
      expect(user.admin).to be_falsey
    end

    it 'can be created as an admin' do
      admin = User.create(
        username: 'adminuser',
        email: 'admin@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        admin: true
      )
      expect(admin.admin).to be_truthy
    end
  end

  # Factory validation
  describe 'factories' do
    it 'has a valid factory' do
      expect(build(:user)).to be_valid
    end

    it 'has a valid admin factory' do
      expect(build(:user, :admin)).to be_valid
      expect(build(:user, :admin).admin).to be_truthy
    end
  end
end
