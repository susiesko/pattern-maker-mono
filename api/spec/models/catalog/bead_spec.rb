# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Catalog::Bead, type: :model do
  # Common test variables used across multiple contexts
  let(:valid_bead) { build(:bead) }

  describe 'validations' do
    let(:bead_without_name) { build(:bead, name: nil) }
    let(:bead_without_product_code) { build(:bead, brand_product_code: nil) }

    it 'validates presence of name' do
      expect(bead_without_name).not_to be_valid
    end

    it 'validates presence of brand_product_code' do
      expect(bead_without_product_code).not_to be_valid
    end

    it 'is valid with valid attributes' do
      expect(valid_bead).to be_valid
    end
  end

  describe 'associations' do
    describe 'brand association' do
      let(:association) { described_class.reflect_on_association(:brand) }

      it 'belongs to a brand' do
        expect(association.macro).to eq :belongs_to
      end

      it 'has the correct class name for brand' do
        expect(association.options[:class_name]).to eq 'Catalog::BeadBrand'
      end
    end

    describe 'size association' do
      let(:association) { described_class.reflect_on_association(:size) }

      it 'belongs to a size' do
        expect(association.macro).to eq :belongs_to
      end

      it 'has the correct class name for size' do
        expect(association.options[:class_name]).to eq 'Catalog::BeadSize'
      end
    end

    describe 'color links and colors associations' do
      let(:links_association) { described_class.reflect_on_association(:bead_color_links) }
      let(:colors_association) { described_class.reflect_on_association(:colors) }

      it 'has many bead color links' do
        expect(links_association.macro).to eq :has_many
      end

      it 'destroys dependent bead color links' do
        expect(links_association.options[:dependent]).to eq :destroy
      end

      it 'has many colors' do
        expect(colors_association.macro).to eq :has_many
      end

      it 'has colors through bead color links' do
        expect(colors_association.options[:through]).to eq :bead_color_links
      end

      it 'has the correct source for colors' do
        expect(colors_association.options[:source]).to eq :color
      end

      it 'has the correct class name for colors' do
        expect(colors_association.options[:class_name]).to eq 'Catalog::BeadColor'
      end
    end

    describe 'finish links and finishes associations' do
      let(:links_association) { described_class.reflect_on_association(:bead_finish_links) }
      let(:finishes_association) { described_class.reflect_on_association(:finishes) }

      it 'has many bead finish links' do
        expect(links_association.macro).to eq :has_many
      end

      it 'destroys dependent bead finish links' do
        expect(links_association.options[:dependent]).to eq :destroy
      end

      it 'has many finishes' do
        expect(finishes_association.macro).to eq :has_many
      end

      it 'has finishes through bead finish links' do
        expect(finishes_association.options[:through]).to eq :bead_finish_links
      end

      it 'has the correct source for finishes' do
        expect(finishes_association.options[:source]).to eq :finish
      end

      it 'has the correct class name for finishes' do
        expect(finishes_association.options[:class_name]).to eq 'Catalog::BeadFinish'
      end
    end
  end

  describe 'cascading deletes' do
    let!(:bead) { create(:bead) }
    let!(:color) { create(:bead_color) }
    let!(:finish) { create(:bead_finish) }
    let!(:color_link) { create(:bead_color_link, bead: bead, color: color) }
    let!(:finish_link) { create(:bead_finish_link, bead: bead, finish: finish) }

    it 'deletes associated bead color links when deleted' do
      expect { bead.destroy }.to change(Catalog::BeadColorLink, :count).by(-1)
    end

    it 'deletes associated bead finish links when deleted' do
      expect { bead.destroy }.to change(Catalog::BeadFinishLink, :count).by(-1)
    end
  end

  describe 'brand and size relationships' do
    let(:brand) { create(:bead_brand) }
    let(:bead_type) { create(:bead_type, brand: brand) }
    let(:size) { create(:bead_size, brand: brand, type: bead_type) }
    let(:bead) { create(:bead, brand: brand, size: size) }

    it 'belongs to the correct brand' do
      expect(bead.brand).to eq(brand)
    end

    it 'belongs to the correct size' do
      expect(bead.size).to eq(size)
    end
  end

  describe 'colors and finishes relationships' do
    let!(:bead) { create(:bead) }
    let!(:color1) { create(:bead_color) }
    let!(:color2) { create(:bead_color) }
    let!(:finish1) { create(:bead_finish) }
    let!(:finish2) { create(:bead_finish) }

    before do
      create(:bead_color_link, bead: bead, color: color1)
      create(:bead_color_link, bead: bead, color: color2)
      create(:bead_finish_link, bead: bead, finish: finish1)
      create(:bead_finish_link, bead: bead, finish: finish2)
    end

    it 'includes the correct colors' do
      expect(bead.colors).to include(color1, color2)
    end

    it 'has the correct number of colors' do
      expect(bead.colors.count).to eq(2)
    end

    it 'includes the correct finishes' do
      expect(bead.finishes).to include(finish1, finish2)
    end

    it 'has the correct number of finishes' do
      expect(bead.finishes.count).to eq(2)
    end
  end

  describe 'metadata' do
    let(:bead) { create(:bead, metadata: { material: 'crystal', shape: 'bicone' }) }

    it 'stores and retrieves material metadata correctly' do
      expect(bead.metadata['material']).to eq('crystal')
    end

    it 'stores and retrieves shape metadata correctly' do
      expect(bead.metadata['shape']).to eq('bicone')
    end
  end
end
