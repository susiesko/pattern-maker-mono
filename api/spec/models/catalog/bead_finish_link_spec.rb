# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Catalog::BeadFinishLink, type: :model do
  describe 'validations' do
    let(:bead) { create(:bead) }
    let(:finish) { create(:bead_finish) }
    let(:bead_finish_link) { create(:bead_finish_link, bead: bead, finish: finish) }

    it 'is not valid with duplicate bead and finish' do
      duplicate_link = build(:bead_finish_link, bead: bead, finish: finish)
      expect(duplicate_link).not_to be_valid
    end

    it 'has the correct error message for duplicate links' do
      duplicate_link = build(:bead_finish_link, bead: bead, finish: finish)
      duplicate_link.valid?
      expect(duplicate_link.errors[:bead_id]).to include('has already been taken')
    end

    it 'is valid with valid attributes' do
      expect(build(:bead_finish_link)).to be_valid
    end

    it 'is valid with a different bead and same finish' do
      new_bead = create(:bead)
      expect(build(:bead_finish_link, bead: new_bead, finish: finish)).to be_valid
    end

    it 'is valid with a different finish and same bead' do
      new_finish = create(:bead_finish)
      expect(build(:bead_finish_link, bead: bead, finish: new_finish)).to be_valid
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

    it 'belongs to a finish' do
      association = described_class.reflect_on_association(:finish)
      expect(association.macro).to eq :belongs_to
    end

    it 'has the correct class name for finish' do
      association = described_class.reflect_on_association(:finish)
      expect(association.options[:class_name]).to eq 'Catalog::BeadFinish'
    end
  end

  describe 'bead and finish relationships' do
    let(:bead) { create(:bead) }
    let(:finish) { create(:bead_finish) }
    let(:bead_finish_link) { create(:bead_finish_link, bead: bead, finish: finish) }

    it 'belongs to the correct bead' do
      expect(bead_finish_link.bead).to eq(bead)
    end

    it 'belongs to the correct finish' do
      expect(bead_finish_link.finish).to eq(finish)
    end
  end
end
