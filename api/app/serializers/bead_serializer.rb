class BeadSerializer < ActiveModel::Serializer
  attributes :id, :name, :brand_product_code, :image, :metadata, :created_at, :updated_at
  
  belongs_to :brand do
    object.brand.as_json(only: [:id, :name, :website])
  end
  
  belongs_to :size do
    object.size.as_json(only: [:id, :size])
  end
  
  belongs_to :type do
    object.type.as_json(only: [:id, :name])
  end
  
  has_many :colors do
    object.colors.as_json(only: [:id, :name])
  end
  
  has_many :finishes do
    object.finishes.as_json(only: [:id, :name])
  end
end