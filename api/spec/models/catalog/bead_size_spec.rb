# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Catalog::BeadSize, type: :model do
  # Common test variables
  let(:valid_bead_size) { build(:bead_size) }

  describe 'validations' do
    let(:bead_size_without_size) { build(:bead_size, size: nil) }

    it 'validates presence of size' do
      expect(bead_size_without_size).not_to be_valid
    end

    it 'is valid with valid attributes' do
      expect(valid_bead_size).to be_valid
    end
  end

  describe 'associations' do
    describe 'brand association' do
      let(:association) { described_class.reflect_on_association(:brand) }

      it 'belongs to a brand' do
        expect(association.macro).to eq :belongs_to
      end

      it 'has the correct class name for brand' do
        expect(association.options[:class_name]).to eq 'Catalog::BeadBrand'
      end
    end

    describe 'type association' do
      let(:association) { described_class.reflect_on_association(:type) }

      it 'belongs to a type' do
        expect(association.macro).to eq :belongs_to
      end

      it 'has the correct class name for type' do
        expect(association.options[:class_name]).to eq 'Catalog::BeadType'
      end
    end

    describe 'beads association' do
      let(:association) { described_class.reflect_on_association(:beads) }

      it 'has many beads' do
        expect(association.macro).to eq :has_many
      end

      it 'has the correct foreign key for beads' do
        expect(association.options[:foreign_key]).to eq :size_id
      end

      it 'destroys dependent beads' do
        expect(association.options[:dependent]).to eq :destroy
      end
    end
  end

  describe 'cascading deletes' do
    let!(:brand) { create(:bead_brand) }
    let!(:bead_type) { create(:bead_type, brand: brand) }
    let!(:bead_size) { create(:bead_size, brand: brand, type: bead_type) }
    let!(:bead) { create(:bead, brand: brand, size: bead_size) }

    it 'deletes associated beads when deleted' do
      expect { bead_size.destroy }.to change(Catalog::Bead, :count).by(-1)
    end
  end

  describe 'brand and type relationships' do
    let(:brand) { create(:bead_brand) }
    let(:bead_type) { create(:bead_type, brand: brand) }
    let(:bead_size) { create(:bead_size, brand: brand, type: bead_type) }

    it 'belongs to the correct brand' do
      expect(bead_size.brand).to eq(brand)
    end

    it 'belongs to the correct type' do
      expect(bead_size.type).to eq(bead_type)
    end
  end

  describe 'metadata' do
    let(:bead_size) { create(:bead_size, metadata: { diameter: '5mm', weight: '0.2g' }) }

    it 'stores and retrieves diameter metadata correctly' do
      expect(bead_size.metadata['diameter']).to eq('5mm')
    end

    it 'stores and retrieves weight metadata correctly' do
      expect(bead_size.metadata['weight']).to eq('0.2g')
    end
  end
end
