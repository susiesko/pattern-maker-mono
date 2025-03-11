# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Catalog::FetchBeadService do
  let(:brand) { create(:bead_brand) }
  let(:type) { create(:bead_type, brand: brand) }
  let(:size) { create(:bead_size, brand: brand, type: type) }
  let(:bead) { create(:bead, brand: brand, type: type, size: size) }

  describe '#call' do
    context 'when the bead exists' do
      it 'returns the bead' do
        result = described_class.new(bead.id).call

        expect(result).to eq(bead)
      end

      it 'includes associations' do
        result = described_class.new(bead.id).call

        expect(result.association(:brand).loaded?).to be true
        expect(result.association(:size).loaded?).to be true
        expect(result.association(:colors).loaded?).to be true
        expect(result.association(:finishes).loaded?).to be true
      end
    end

    context 'when the bead does not exist' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect do
          described_class.new(999).call
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
