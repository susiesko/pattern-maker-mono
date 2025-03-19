require 'rails_helper'

RSpec.describe Catalog::BeadFinish, type: :model do
  describe 'validations' do
    it 'validates presence of name' do
      expect(build(:bead_finish, name: nil)).not_to be_valid
    end

    it 'is valid with valid attributes' do
      expect(build(:bead_finish)).to be_valid
    end
  end

  describe 'associations' do
    it 'has many bead finish links' do
      association = described_class.reflect_on_association(:bead_finish_links)
      expect(association.macro).to eq :has_many
    end

    it 'has the correct foreign key for bead finish links' do
      association = described_class.reflect_on_association(:bead_finish_links)
      expect(association.options[:foreign_key]).to eq :finish_id
    end

    it 'destroys dependent bead finish links' do
      association = described_class.reflect_on_association(:bead_finish_links)
      expect(association.options[:dependent]).to eq :destroy
    end

    it 'has many beads through bead finish links' do
      association = described_class.reflect_on_association(:beads)
      expect(association.macro).to eq :has_many
      expect(association.options[:through]).to eq :bead_finish_links
    end
  end

  describe 'cascading deletes' do
    let(:bead) { create(:bead) }
    let(:finish) { create(:bead_finish) }
    let(:bead_finish_link) { create(:bead_finish_link, bead: bead, finish: finish) }

    it 'deletes associated bead finish links when deleted' do
      expect { finish.destroy }.to change(Catalog::BeadFinishLink, :count).by(-1)
    end
  end

  describe 'beads relationship' do
    let(:bead1) { create(:bead) }
    let(:bead2) { create(:bead) }
    let(:finish) { create(:bead_finish) }

    before do
      create(:bead_finish_link, bead: bead1, finish: finish)
      create(:bead_finish_link, bead: bead2, finish: finish)
    end

    it 'includes the correct beads' do
      expect(finish.beads).to include(bead1, bead2)
    end

    it 'has the correct number of beads' do
      expect(finish.beads.count).to eq(2)
    end
  end
end
