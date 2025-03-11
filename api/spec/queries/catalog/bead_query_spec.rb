# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Catalog::BeadQuery do
  let!(:brand1) { create(:bead_brand, name: 'Miyuki') }
  let!(:brand2) { create(:bead_brand, name: 'Toho') }
  let!(:type1) { create(:bead_type, name: 'Delica', brand: brand1) }
  let!(:type2) { create(:bead_type, name: 'Round', brand: brand2) }
  let!(:size1) { create(:bead_size, size: '11/0', brand: brand1, type: type1) }
  let!(:size2) { create(:bead_size, size: '8/0', brand: brand2, type: type2) }
  let!(:color1) { create(:bead_color, name: 'Red') }
  let!(:color2) { create(:bead_color, name: 'Blue') }
  let!(:finish1) { create(:bead_finish, name: 'Matte') }
  let!(:finish2) { create(:bead_finish, name: 'Glossy') }

  let!(:bead1) do
    create(:bead, name: 'Red Delica', brand_product_code: 'DB001', brand: brand1, type: type1, size: size1)
  end
  let!(:bead2) do
    create(:bead, name: 'Blue Round', brand_product_code: 'TR001', brand: brand2, type: type2, size: size2)
  end

  before do
    create(:bead_color_link, bead: bead1, color: color1)
    create(:bead_color_link, bead: bead2, color: color2)
    create(:bead_finish_link, bead: bead1, finish: finish1)
    create(:bead_finish_link, bead: bead2, finish: finish2)
  end

  describe '#call' do
    context 'with no parameters' do
      it 'returns all beads' do
        result = described_class.new.call
        expect(result.count).to eq(2)
      end
    end

    context 'with brand filter' do
      it 'returns beads for the specified brand' do
        result = described_class.new.call(brand_id: brand1.id)
        expect(result.count).to eq(1)
        expect(result.first.name).to eq('Red Delica')
      end
    end

    context 'with search parameter' do
      it 'returns beads matching the search term in name' do
        result = described_class.new.call(search: 'Delica')
        expect(result.count).to eq(1)
        expect(result.first.name).to eq('Red Delica')
      end

      it 'returns beads matching the search term in product code' do
        result = described_class.new.call(search: 'DB001')
        expect(result.count).to eq(1)
        expect(result.first.brand_product_code).to eq('DB001')
      end
    end

    context 'with sorting' do
      it 'sorts by name in ascending order' do
        result = described_class.new.call(sort_by: 'name', sort_direction: 'asc')
        expect(result.first.name).to eq('Blue Round')
        expect(result.last.name).to eq('Red Delica')
      end

      it 'sorts by name in descending order' do
        result = described_class.new.call(sort_by: 'name', sort_direction: 'desc')
        expect(result.first.name).to eq('Red Delica')
        expect(result.last.name).to eq('Blue Round')
      end
    end

    # Add more tests for other filters
  end
end
