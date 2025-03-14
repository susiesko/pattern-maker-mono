# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Catalog::BeadTypeSerializer do
  let!(:brand) { create(:bead_brand, name: 'Test Brand', website: 'https://example.com') }
  let!(:bead_type) { create(:bead_type, name: 'Test Type', brand: brand) }

  subject { described_class.new(bead_type).as_json }

  it 'includes the id' do
    expect(subject[:id]).to eq(bead_type.id)
  end

  it 'includes the name' do
    expect(subject[:name]).to eq('Test Type')
  end

  it 'includes created_at timestamp' do
    expect(subject[:created_at]).to be_present
  end

  it 'includes updated_at timestamp' do
    expect(subject[:updated_at]).to be_present
  end

  it 'includes the brand' do
    expect(subject[:brand]).to be_present
  end

  it 'includes the brand id' do
    expect(subject[:brand]['id']).to eq(brand.id)
  end

  it 'includes the brand name' do
    expect(subject[:brand]['name']).to eq('Test Brand')
  end

  it 'includes the brand website' do
    expect(subject[:brand]['website']).to eq('https://example.com')
  end
end
