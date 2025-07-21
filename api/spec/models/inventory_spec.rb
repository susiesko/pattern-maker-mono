# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Inventory, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:bead) }
  end

  describe 'validations' do
    subject { build(:inventory) }

    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_numericality_of(:quantity).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:quantity_unit) }
    it { is_expected.to validate_inclusion_of(:quantity_unit).in_array(%w[unit grams ounces pounds]) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:bead_id).with_message('can only have one inventory entry per bead') }
  end

  describe 'scopes' do
    let(:first_user) { create(:user) }
    let(:second_user) { create(:user) }
    let(:red_bead) { create(:bead) }
    let(:blue_bead) { create(:bead) }

    before do
      create(:inventory, user: first_user, bead: red_bead)
      create(:inventory, user: first_user, bead: blue_bead)
      create(:inventory, user: second_user, bead: red_bead)
    end

    describe '.by_user' do
      it 'returns inventories for specific user' do
        expect(Inventory.by_user(first_user).count).to eq(2)
        expect(Inventory.by_user(second_user).count).to eq(1)
      end
    end

    describe '.by_bead' do
      it 'returns inventories for specific bead' do
        expect(Inventory.by_bead(red_bead).count).to eq(2)
        expect(Inventory.by_bead(blue_bead).count).to eq(1)
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:inventory)).to be_valid
    end
  end
end
