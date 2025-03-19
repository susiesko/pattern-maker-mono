# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Catalog::BeadType, type: :model do
  describe 'validations' do
    it 'validates presence of name' do
      expect(build(:bead_type, name: nil)).not_to be_valid
    end

    it 'is valid with valid attributes' do
      expect(build(:bead_type)).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a brand' do
      association = described_class.reflect_on_association(:brand)
      expect(association.macro).to eq :belongs_to
    end

    it 'has the correct class name for brand' do
      association = described_class.reflect_on_association(:brand)
      expect(association.options[:class_name]).to eq 'Catalog::BeadBrand'
    end

    it 'has many bead sizes' do
      association = described_class.reflect_on_association(:bead_sizes)
      expect(association.macro).to eq :has_many
    end

    it 'has the correct foreign key for bead sizes' do
      association = described_class.reflect_on_association(:bead_sizes)
      expect(association.options[:foreign_key]).to eq :type_id
    end

    it 'destroys dependent bead sizes' do
      association = described_class.reflect_on_association(:bead_sizes)
      expect(association.options[:dependent]).to eq :destroy
    end
  end

  describe 'cascading deletes' do
    let(:brand) { create(:bead_brand) }
    let(:bead_type) { create(:bead_type, brand: brand) }
    let(:bead_size) { create(:bead_size, brand: brand, type: bead_type) }

    it 'deletes associated bead sizes when deleted' do
      expect { bead_type.destroy }.to change(Catalog::BeadSize, :count).by(-1)
    end
  end

  describe 'brand relationship' do
    let(:brand) { create(:bead_brand) }
    let(:bead_type) { create(:bead_type, brand: brand) }

    it 'belongs to the correct brand' do
      expect(bead_type.brand).to eq(brand)
    end
  end
end
