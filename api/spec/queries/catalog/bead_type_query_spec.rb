require 'rails_helper'

RSpec.describe Catalog::BeadTypeQuery do
  let!(:brand1) { create(:bead_brand, name: "Miyuki") }
  let!(:brand2) { create(:bead_brand, name: "Toho") }
  let!(:type1) { create(:bead_type, name: "Delica", brand: brand1) }
  let!(:type2) { create(:bead_type, name: "Round", brand: brand2) }
  let!(:type3) { create(:bead_type, name: "Cube", brand: brand1) }
  
  describe "#call" do
    context "with no parameters" do
      it "returns all bead types" do
        result = described_class.new.call
        expect(result.count).to eq(3)
      end
    end
    
    context "with brand filter" do
      it "returns bead types for the specified brand" do
        result = described_class.new.call(brand_id: brand1.id)
        expect(result.count).to eq(2)
        expect(result.pluck(:name)).to contain_exactly("Delica", "Cube")
      end
    end
    
    context "with search parameter" do
      it "returns bead types matching the search term" do
        result = described_class.new.call(search: "Del")
        expect(result.count).to eq(1)
        expect(result.first.name).to eq("Delica")
      end
      
      it "is case insensitive" do
        result = described_class.new.call(search: "del")
        expect(result.count).to eq(1)
        expect(result.first.name).to eq("Delica")
      end
    end
    
    context "with sorting" do
      it "sorts by name in ascending order by default" do
        result = described_class.new.call(sort_by: "name")
        expect(result.first.name).to eq("Cube")
        expect(result.last.name).to eq("Round")
      end
      
      it "sorts by name in descending order when specified" do
        result = described_class.new.call(sort_by: "name", sort_direction: "desc")
        expect(result.first.name).to eq("Round")
        expect(result.last.name).to eq("Cube")
      end
      
      it "defaults to name sorting when an invalid column is specified" do
        result = described_class.new.call(sort_by: "invalid_column")
        expect(result.first.name).to eq("Cube")
        expect(result.last.name).to eq("Round")
      end
    end
    
    context "with combined filters" do
      it "applies multiple filters correctly" do
        result = described_class.new.call(
          brand_id: brand1.id,
          search: "Del",
          sort_by: "name",
          sort_direction: "asc"
        )
        expect(result.count).to eq(1)
        expect(result.first.name).to eq("Delica")
      end
    end
    
    context "with includes" do
      it "eager loads associations" do
        result = described_class.new.call
        expect(result.first.association(:brand).loaded?).to be true
      end
    end
  end
end