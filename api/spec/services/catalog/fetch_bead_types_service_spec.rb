require 'rails_helper'

RSpec.describe Catalog::FetchBeadTypesService do
  let!(:brand) { create(:bead_brand) }
  let!(:bead_types) { create_list(:bead_type, 25, brand: brand) }
  
  describe "#call" do
    context "without controller" do
      it "returns paginated bead types" do
        pagy, result = described_class.new(page: 1, items: 10).call
        
        expect(result.count).to eq(10)
        expect(pagy.count).to eq(25)
        expect(pagy.page).to eq(1)
        expect(pagy.items).to eq(10)
        expect(pagy.pages).to eq(3)
      end
      
      it "handles page parameter" do
        pagy, result = described_class.new(page: 2, items: 10).call
        
        expect(result.count).to eq(10)
        expect(pagy.page).to eq(2)
      end
      
      it "applies filters" do
        pagy, result = described_class.new(brand_id: brand.id).call
        
        expect(result.count).to eq(20) # Default items per page is 20
        expect(result.all? { |bt| bt.brand_id == brand.id }).to be true
      end
      
      it "handles the last page with fewer items" do
        pagy, result = described_class.new(page: 3, items: 10).call
        
        expect(result.count).to eq(5) # 25 total, 10 per page, 5 on the last page
        expect(pagy.page).to eq(3)
      end
    end
    
    context "with controller" do
      let(:controller) { double("controller") }
      let(:pagy_double) { double("pagy", page: 1, items: 20, pages: 2, count: 25, next: 2, prev: nil) }
      let(:paginated_bead_types) { bead_types.first(20) }
      
      before do
        allow(controller).to receive(:pagy).and_return([pagy_double, paginated_bead_types])
      end
      
      it "uses controller's pagy method" do
        expect(controller).to receive(:pagy).with(kind_of(ActiveRecord::Relation), hash_including(items: 20))
        
        pagy, result = described_class.new({}, controller).call
        
        expect(pagy).to eq(pagy_double)
        expect(result).to eq(paginated_bead_types)
      end
      
      it "passes custom items parameter to controller's pagy method" do
        expect(controller).to receive(:pagy).with(kind_of(ActiveRecord::Relation), hash_including(items: 10))
        
        described_class.new({items: 10}, controller).call
      end
    end
  end
end