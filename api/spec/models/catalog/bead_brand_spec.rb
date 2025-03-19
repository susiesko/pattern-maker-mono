require 'rails_helper'

RSpec.describe Catalog::BeadBrand, type: :model do
  describe 'validations' do
    it 'validates presence of name' do
      expect(build(:bead_brand, name: nil)).not_to be_valid
    end

    it 'is valid with valid attributes' do
      expect(build(:bead_brand)).to be_valid
    end

    it 'is valid without a website' do
      expect(build(:bead_brand, website: nil)).to be_valid
    end
  end

  describe 'associations' do
    it 'has many bead types' do
      association = described_class.reflect_on_association(:bead_types)
      expect(association.macro).to eq :has_many
    end

    it 'has the correct foreign key for bead types' do
      association = described_class.reflect_on_association(:bead_types)
      expect(association.options[:foreign_key]).to eq :brand_id
    end

    it 'destroys dependent bead types' do
      association = described_class.reflect_on_association(:bead_types)
      expect(association.options[:dependent]).to eq :destroy
    end

    it 'has many bead sizes' do
      association = described_class.reflect_on_association(:bead_sizes)
      expect(association.macro).to eq :has_many
    end

    it 'has the correct foreign key for bead sizes' do
      association = described_class.reflect_on_association(:bead_sizes)
      expect(association.options[:foreign_key]).to eq :brand_id
    end

    it 'destroys dependent bead sizes' do
      association = described_class.reflect_on_association(:bead_sizes)
      expect(association.options[:dependent]).to eq :destroy
    end

    it 'has many beads' do
      association = described_class.reflect_on_association(:beads)
      expect(association.macro).to eq :has_many
    end

    it 'has the correct foreign key for beads' do
      association = described_class.reflect_on_association(:beads)
      expect(association.options[:foreign_key]).to eq :brand_id
    end

    it 'destroys dependent beads' do
      association = described_class.reflect_on_association(:beads)
      expect(association.options[:dependent]).to eq :destroy
    end
  end

  describe 'cascading deletes' do
    let(:brand) { create(:bead_brand) }
    let(:bead_type) { create(:bead_type, brand: brand) }
    let(:bead_size) { create(:bead_size, brand: brand, type: bead_type) }
    let(:bead) { create(:bead, brand: brand, size: bead_size) }

    it 'deletes associated bead types when deleted' do
      expect { brand.destroy }.to change(Catalog::BeadType, :count).by(-1)
    end

    it 'deletes associated bead sizes when deleted' do
      expect { brand.destroy }.to change(Catalog::BeadSize, :count).by(-1)
    end

    it 'deletes associated beads when deleted' do
      expect { brand.destroy }.to change(Catalog::Bead, :count).by(-1)
    end
  end
end
