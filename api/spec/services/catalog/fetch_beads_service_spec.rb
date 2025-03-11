# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Catalog::FetchBeadsService do
  let!(:brand) { create(:bead_brand) }
  let!(:type) { create(:bead_type, brand: brand) }
  let!(:size) { create(:bead_size, brand: brand, type: type) }
  let!(:beads) { create_list(:bead, 25, brand: brand, type: type, size: size) }

  describe '#call' do
    context 'without controller' do
      it 'returns paginated beads' do
        pagy, result = described_class.new(page: 1, items: 10).call

        expect(result.count).to eq(10)
        expect(pagy.count).to eq(25)
        expect(pagy.page).to eq(1)
        expect(pagy.items).to eq(10)
        expect(pagy.pages).to eq(3)
      end

      it 'handles page parameter' do
        pagy, result = described_class.new(page: 2, items: 10).call

        expect(result.count).to eq(10)
        expect(pagy.page).to eq(2)
      end

      it 'applies filters' do
        _pagy, result = described_class.new(brand_id: brand.id).call

        expect(result.count).to eq(20) # Default items per page is 20
        expect(result.all? { |b| b.brand_id == brand.id }).to be true
      end
    end

    context 'with controller' do
      let(:controller) { double('controller') }
      let(:pagy_double) { double('pagy', page: 1, items: 20, pages: 2, count: 25, next: 2, prev: nil) }
      let(:paginated_beads) { beads.first(20) }

      before do
        allow(controller).to receive(:pagy).and_return([pagy_double, paginated_beads])
      end

      it "uses controller's pagy method" do
        expect(controller).to receive(:pagy).with(kind_of(ActiveRecord::Relation), hash_including(items: 20))

        pagy, result = described_class.new({}, controller).call

        expect(pagy).to eq(pagy_double)
        expect(result).to eq(paginated_beads)
      end
    end
  end
end
