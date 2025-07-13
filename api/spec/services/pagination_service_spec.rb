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
        expect(result[:has_more]).to be(true)
        expect(result[:next_cursor]).to be_present
        expect(result[:limit]).to eq(20)
      end
    end
    
    context 'with cursor' do
      it 'returns records after the cursor' do
        create_list(:bead, 15)
        relation = Catalog::Bead.order(id: :desc)
        
        # First page
        first_page = described_class.new(relation, limit: 5).paginate
        expect(first_page[:records].size).to eq(5)
        expect(first_page[:has_more]).to be(true)
        
        # Second page using cursor
        second_page = described_class.new(relation, cursor: first_page[:next_cursor], limit: 5).paginate
        expect(second_page[:records].size).to eq(5)
        expect(second_page[:records].first.id).to be < first_page[:records].last.id
      end
    end
    
    context 'with custom limit' do
      it 'respects the limit parameter' do
        create_list(:bead, 15)
        relation = Catalog::Bead.order(id: :desc)
        service = described_class.new(relation, limit: 10)
        result = service.paginate
        
        expect(result[:records].size).to eq(10)
        expect(result[:limit]).to eq(10)
      end
    end
    
    context 'with brand_product_code cursor' do
      it 'paginates by brand_product_code in ascending order' do
        # Create beads with specific product codes
        create(:bead, brand_product_code: 'A-001')
        create(:bead, brand_product_code: 'B-002') 
        create(:bead, brand_product_code: 'C-003')
        
        relation = Catalog::Bead.order(brand_product_code: :asc)
        
        # First page
        first_page = described_class.new(
          relation, 
          limit: 2, 
          cursor_field: :brand_product_code, 
          direction: :asc
        ).paginate
        
        expect(first_page[:records].size).to eq(2)
        expect(first_page[:records].first.brand_product_code).to eq('A-001')
        expect(first_page[:records].last.brand_product_code).to eq('B-002')
        expect(first_page[:next_cursor]).to eq('B-002')
        
        # Second page
        second_page = described_class.new(
          relation, 
          cursor: first_page[:next_cursor], 
          limit: 2, 
          cursor_field: :brand_product_code, 
          direction: :asc
        ).paginate
        
        expect(second_page[:records].size).to eq(1)
        expect(second_page[:records].first.brand_product_code).to eq('C-003')
        expect(second_page[:has_more]).to be(false)
      end
    end
  end
end 