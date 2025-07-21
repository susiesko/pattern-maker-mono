# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserInventorySetting, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    subject { build(:user_inventory_setting) }

    it { is_expected.to validate_presence_of(:field_definitions) }

    context 'with valid field definitions' do
      let(:valid_fields) do
        [
          { 'fieldName' => 'location', 'fieldType' => 'text', 'label' => 'Storage Location' },
          { 'fieldName' => 'purchase_date', 'fieldType' => 'date', 'label' => 'Purchase Date' },
          { 'fieldName' => 'notes', 'fieldType' => 'textarea', 'label' => 'Notes' },
        ]
      end

      it 'accepts valid field definitions' do
        setting = build(:user_inventory_setting, field_definitions: valid_fields)
        expect(setting).to be_valid
      end
    end

    context 'with invalid field definitions' do
      it 'rejects non-array field definitions' do
        setting = build(:user_inventory_setting, field_definitions: 'invalid')
        expect(setting).not_to be_valid
        expect(setting.errors[:field_definitions]).to include('must be an array')
      end

      it 'rejects non-hash field objects' do
        setting = build(:user_inventory_setting, field_definitions: ['invalid'])
        expect(setting).not_to be_valid
        expect(setting.errors[:field_definitions]).to include('field at index 0 must be a hash')
      end

      it 'rejects fields missing required keys' do
        invalid_fields = [{ 'fieldName' => 'location' }] # missing fieldType and label
        setting = build(:user_inventory_setting, field_definitions: invalid_fields)
        expect(setting).not_to be_valid
        expect(setting.errors[:field_definitions]).to include('field at index 0 is missing required key: fieldType')
        expect(setting.errors[:field_definitions]).to include('field at index 0 is missing required key: label')
      end

      it 'rejects invalid field types' do
        invalid_fields = [{ 'fieldName' => 'test', 'fieldType' => 'invalid', 'label' => 'Test' }]
        setting = build(:user_inventory_setting, field_definitions: invalid_fields)
        expect(setting).not_to be_valid
        expect(setting.errors[:field_definitions]).to include('field at index 0 has invalid fieldType. Must be one of: text, number, date, select, textarea, boolean')
      end
    end
  end

  describe 'scopes' do
    let(:first_user) { create(:user) }
    let(:second_user) { create(:user) }

    before do
      create(:user_inventory_setting, user: first_user)
      create(:user_inventory_setting, user: user2)
    end

    describe '.by_user' do
      it 'returns settings for specific user' do
        expect(UserInventorySetting.by_user(user1).count).to eq(1)
        expect(UserInventorySetting.by_user(user2).count).to eq(1)
      end
    end
  end

  describe '#field_definitions_hash' do
    it 'returns field definitions as array' do
      fields = [{ 'fieldName' => 'test', 'fieldType' => 'text', 'label' => 'Test' }]
      setting = build(:user_inventory_setting, field_definitions: fields)
      expect(setting.field_definitions_hash).to eq(fields)
    end

    it 'returns empty array when field_definitions is nil' do
      setting = build(:user_inventory_setting, field_definitions: nil)
      expect(setting.field_definitions_hash).to eq([])
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:user_inventory_setting)).to be_valid
    end
  end
end
