# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Catalog::BeadBrand, type: :model do
  # Associations
  it { should have_many(:bead_types).dependent(:destroy) }
  it { should have_many(:bead_sizes).dependent(:destroy) }
  it { should have_many(:beads).dependent(:destroy) }

  # Validations
  it { should validate_presence_of(:name) }

  # Factory
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:bead_brand)).to be_valid
    end
  end
end
