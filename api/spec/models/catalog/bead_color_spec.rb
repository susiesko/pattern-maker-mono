require 'rails_helper'

RSpec.describe Catalog::BeadColor, type: :model do
  describe 'validations' do
    it 'validates presence of name' do
      expect(build(:bead_color, name: nil)).not_to be_valid
    end

    it 'is valid with valid attributes' do
      expect(build(:bead_color)).to be_valid
    end
  end

  describe 'associations' do
    it 'has many bead color links' do
      association = described_class.reflect_on_association(:bead_color_links)
      expect(association.macro).to eq :has_many
    end

    it 'has the correct foreign key for bead color links' do
      association = described_class.reflect_on_association(:bead_color_links)
      expect(association.options[:foreign_key]).to eq :color_id
    end

    it 'destroys dependent bead color links' do
      association = described_class.reflect_on_association(:bead_color_links)
      expect(association.options[:dependent]).to eq :destroy
    end

    it 'has many beads through bead color links' do
      association = described_class.reflect_on_association(:beads)
      expect(association.macro).to eq :has_many
      expect(association.options[:through]).to eq :bead_color_links
    end
  end

  describe 'cascading deletes' do
    let(:bead) { create(:bead) }
    let(:color) { create(:bead_color) }
    let(:bead_color_link) { create(:bead_color_link, bead: bead, color: color) }

    it 'deletes associated bead color links when deleted' do
      expect { color.destroy }.to change(Catalog::BeadColorLink, :count).by(-1)
    end
  end

  describe 'beads relationship' do
    let(:bead1) { create(:bead) }
    let(:bead2) { create(:bead) }
    let(:color) { create(:bead_color) }

    before do
      create(:bead_color_link, bead: bead1, color: color)
      create(:bead_color_link, bead: bead2, color: color)
    end

    it 'includes the correct beads' do
      expect(color.beads).to include(bead1, bead2)
    end

    it 'has the correct number of beads' do
      expect(color.beads.count).to eq(2)
    end
  end
end
