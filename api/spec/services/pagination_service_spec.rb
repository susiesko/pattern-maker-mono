require 'rails_helper'

RSpec.describe PaginationService do
  describe '#paginate' do
    context 'with default limit' do
      it 'returns first 20 records and has_more true' do
        create_list(:bead, 25)
        relation = Catalog::Bead.order(id: :desc)
        service = described_class.new(relation)
        result = service.paginate

        expect(result[:records].size).to eq(20)
        expect(result[:pagination][:has_more]).to be(true)
        expect(result[:pagination][:current_page]).to eq(1)
        expect(result[:pagination][:per_page]).to eq(20)
      end
    end

    context 'with custom page size' do
      it 'returns records for the specified page' do
        create_list(:bead, 15)
        relation = Catalog::Bead.order(id: :desc)

        # First page
        first_page = described_class.new(relation, per_page: 5).paginate
        expect(first_page[:records].size).to eq(5)
        expect(first_page[:pagination][:has_more]).to be(true)
        expect(first_page[:pagination][:current_page]).to eq(1)

        # Second page
        second_page = described_class.new(relation, page: 2, per_page: 5).paginate
        expect(second_page[:records].size).to eq(5)
        expect(second_page[:pagination][:current_page]).to eq(2)
        expect(second_page[:pagination][:has_previous]).to be(true)
      end
    end

    context 'with custom limit' do
      it 'respects the per_page parameter' do
        create_list(:bead, 15)
        relation = Catalog::Bead.order(id: :desc)
        service = described_class.new(relation, per_page: 10)
        result = service.paginate

        expect(result[:records].size).to eq(10)
        expect(result[:pagination][:per_page]).to eq(10)
      end
    end

    context 'with pagination info' do
      it 'returns correct pagination metadata' do
        create_list(:bead, 25)
        relation = Catalog::Bead.order(id: :desc)
        service = described_class.new(relation, page: 2, per_page: 10)
        result = service.paginate

        expect(result[:pagination][:current_page]).to eq(2)
        expect(result[:pagination][:per_page]).to eq(10)
        expect(result[:pagination][:total_count]).to eq(25)
        expect(result[:pagination][:total_pages]).to eq(3)
        expect(result[:pagination][:has_more]).to be(true)
        expect(result[:pagination][:has_previous]).to be(true)
      end
    end
  end
end
