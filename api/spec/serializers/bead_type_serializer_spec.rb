require 'rails_helper'

RSpec.describe BeadTypeSerializer do
  let!(:brand) { create(:bead_brand, name: "Test Brand", website: "https://example.com") }
  let!(:bead_type) { create(:bead_type, name: "Test Type", brand: brand) }
  
  subject { described_class.new(bead_type).as_json }
  
  it "includes the id" do
    expect(subject[:id]).to eq(bead_type.id)
  end
  
  it "includes the name" do
    expect(subject[:name]).to eq("Test Type")
  end
  
  it "includes timestamps" do
    expect(subject[:created_at]).to be_present
    expect(subject[:updated_at]).to be_present
  end
  
  it "includes the brand" do
    expect(subject[:brand]).to be_present
    expect(subject[:brand][:id]).to eq(brand.id)
    expect(subject[:brand][:name]).to eq("Test Brand")
    expect(subject[:brand][:website]).to eq("https://example.com")
  end
  
  it "does not include other brand attributes" do
    expect(subject[:brand].keys).to contain_exactly(:id, :name, :website)
  end
end