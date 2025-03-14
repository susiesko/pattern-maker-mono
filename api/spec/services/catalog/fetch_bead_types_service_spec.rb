# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Catalog::FetchBeadTypesService do
  let!(:brand) { create(:bead_brand) }
  let!(:bead_types) { create_list(:bead_type, 25, brand: brand) }

  describe '#call' do
    it 'returns all bead types' do
      result = described_class.new.call
      expect(result.count).to eq(25)
    end

    it 'applies filters' do
      result = described_class.new(brand_id: brand.id).call
      expect(result.all? { |bt| bt.brand_id == brand.id }).to be true
    end

    it "applies search filter" do
      search_term = bead_types.first.name[0..2]
      result = described_class.new(search: search_term).call

expect(result.all? { |bt| bt.name.downcase.include?(search_term.downcase) }).to be true
    end

    it "applies sorting" do
      result = described_class.new(sort_by: "name", sort_direction: "asc").call
      names = result.map(&:name)
      expect(names).to eq(names.sort)
    end
  end
end
