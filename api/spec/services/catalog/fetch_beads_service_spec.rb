# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Catalog::FetchBeadsService do
  let!(:brand) { create(:bead_brand) }
  let!(:type) { create(:bead_type, brand: brand) }
  let!(:size) { create(:bead_size, brand: brand, type: type) }
  let!(:beads) { create_list(:bead, 25, brand: brand, type: type, size: size) }

  describe '#call' do
    it 'returns all beads' do
      result = described_class.new.call
      expect(result.count).to eq(25)
    end

    it 'applies filters' do
      result = described_class.new(brand_id: brand.id).call
      expect(result.all? { |b| b.brand_id == brand.id }).to be true
    end

    it 'applies search filter' do
      search_term = beads.first.name[0..2]
      result = described_class.new(search: search_term).call
      expect(result.all? { |b| b.name.downcase.include?(search_term.downcase) }).to be true
    end

    it 'applies sorting' do
      result = described_class.new(sort_by: 'name', sort_direction: 'asc').call
      names = result.map(&:name)
      expect(names).to eq(names.sort)
    end
  end
end
