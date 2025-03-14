# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Catalog::FetchBeadTypeService do
  let!(:brand) { create(:bead_brand) }
  let!(:bead_type) { create(:bead_type, brand: brand) }

  describe '#call' do
    context 'when the bead type exists' do
      it 'returns the bead type' do
        result = described_class.new(bead_type.id).call

        expect(result).to eq(bead_type)
      end

      it 'includes associations' do
        result = described_class.new(bead_type.id).call

        expect(result.association(:brand).loaded?).to be true
      end
    end

    context 'when the bead type does not exist' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect do
          described_class.new(999).call
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
