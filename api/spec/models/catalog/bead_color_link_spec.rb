# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Catalog::BeadColorLink, type: :model do
  describe 'validations' do
    let(:bead) { create(:bead) }
    let(:color) { create(:bead_color) }
    let(:bead_color_link) { create(:bead_color_link, bead: bead, color: color) }

    it 'is not valid with duplicate bead and color' do
      duplicate_link = build(:bead_color_link, bead: bead, color: color)
      expect(duplicate_link).not_to be_valid
    end

    it 'has the correct error message for duplicate links' do
      duplicate_link = build(:bead_color_link, bead: bead, color: color)
      duplicate_link.valid?
      expect(duplicate_link.errors[:bead_id]).to include('has already been taken')
    end

    it 'is valid with valid attributes' do
      expect(build(:bead_color_link)).to be_valid
    end

    it 'is valid with a different bead and same color' do
      new_bead = create(:bead)
      expect(build(:bead_color_link, bead: new_bead, color: color)).to be_valid
    end

    it 'is valid with a different color and same bead' do
      new_color = create(:bead_color)
      expect(build(:bead_color_link, bead: bead, color: new_color)).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a bead' do
      association = described_class.reflect_on_association(:bead)
      expect(association.macro).to eq :belongs_to
    end

    it 'has the correct class name for bead' do
      association = described_class.reflect_on_association(:bead)
      expect(association.options[:class_name]).to eq 'Catalog::Bead'
    end

    it 'belongs to a color' do
      association = described_class.reflect_on_association(:color)
      expect(association.macro).to eq :belongs_to
    end

    it 'has the correct class name for color' do
      association = described_class.reflect_on_association(:color)
      expect(association.options[:class_name]).to eq 'Catalog::BeadColor'
    end
  end

  describe 'bead and color relationships' do
    let(:bead) { create(:bead) }
    let(:color) { create(:bead_color) }
    let(:bead_color_link) { create(:bead_color_link, bead: bead, color: color) }

    it 'belongs to the correct bead' do
      expect(bead_color_link.bead).to eq(bead)
    end

    it 'belongs to the correct color' do
      expect(bead_color_link.color).to eq(color)
    end
  end
end
