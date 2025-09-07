# frozen_string_literal: true

module Cosmos
  class BeadDocument
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    # Document attributes
    attribute :id, :string
    attribute :name, :string
    attribute :brand, :string
    attribute :brand_product_code, :string
    attribute :shape, :string
    attribute :size, :string
    attribute :color_group, :string
    attribute :glass_group, :string
    attribute :finish, :string
    attribute :dyed, :string
    attribute :galvanized, :string
    attribute :plating, :string
    attribute :image_url, :string
    attribute :description, :string
    attribute :price_per_unit, :decimal
    attribute :currency, :string
    attribute :availability, :string
    attribute :source_url, :string
    attribute :scraped_at, :datetime
    attribute :created_at, :datetime
    attribute :updated_at, :datetime

    # Validations
    validates :id, presence: true
    validates :name, presence: true
    validates :brand, presence: true
    validates :brand_product_code, presence: true

    # Container configuration
    CONTAINER_NAME = 'beads'
    PARTITION_KEY = '/brand'

    class << self
      # Create a new bead document
      # @param attributes [Hash] bead attributes
      # @return [BeadDocument] created document
      def create(attributes = {})
        doc = new(attributes)
        doc.id ||= SecureRandom.uuid
        doc.created_at = Time.current
        doc.updated_at = Time.current
        
        if doc.valid?
          cosmos_doc = CosmosDbService.create_document(
            CONTAINER_NAME,
            doc.to_cosmos_hash,
            doc.brand
          )
          from_cosmos_hash(cosmos_doc)
        else
          doc
        end
      end

      # Find a bead by ID and brand
      # @param id [String] document ID
      # @param brand [String] brand name (partition key)
      # @return [BeadDocument, nil] found document or nil
      def find(id, brand)
        cosmos_doc = CosmosDbService.find_document(CONTAINER_NAME, id, brand)
        cosmos_doc ? from_cosmos_hash(cosmos_doc) : nil
      end

      # Query beads by brand
      # @param brand [String] brand name
      # @return [Array<BeadDocument>] matching documents
      def by_brand(brand)
        query = "SELECT * FROM c WHERE c.brand = @brand"
        parameters = [{ name: '@brand', value: brand }]
        
        docs = CosmosDbService.query_documents(CONTAINER_NAME, query, parameters)
        docs.map { |doc| from_cosmos_hash(doc) }
      end

      # Query beads with filters
      # @param filters [Hash] filter conditions
      # @return [Array<BeadDocument>] matching documents
      def where(filters = {})
        conditions = []
        parameters = []
        
        filters.each do |key, value|
          conditions << "c.#{key} = @#{key}"
          parameters << { name: "@#{key}", value: value }
        end
        
        return [] if conditions.empty?
        
        query = "SELECT * FROM c WHERE #{conditions.join(' AND ')}"
        docs = CosmosDbService.query_documents(CONTAINER_NAME, query, parameters)
        docs.map { |doc| from_cosmos_hash(doc) }
      end

      # Import scraped bead data
      # @param scraped_data [Array<Hash>] array of bead data from scrapers
      # @return [Array<BeadDocument>] created documents
      def import_scraped_data(scraped_data)
        scraped_data.map do |bead_data|
          # Convert scraped format to document format
          attributes = {
            name: bead_data['name'],
            brand: bead_data['brand'] || bead_data['site_name'],
            brand_product_code: bead_data['product_code'] || bead_data['sku'],
            shape: bead_data['shape'],
            size: bead_data['size'],
            color_group: bead_data['color'] || bead_data['color_group'],
            glass_group: bead_data['glass_type'] || bead_data['glass_group'],
            finish: bead_data['finish'],
            image_url: bead_data['image_url'],
            description: bead_data['description'],
            price_per_unit: bead_data['price'],
            currency: bead_data['currency'] || 'USD',
            availability: bead_data['availability'] || 'in_stock',
            source_url: bead_data['url'],
            scraped_at: bead_data['scraped_at'] ? Time.parse(bead_data['scraped_at']) : Time.current
          }
          
          create(attributes)
        rescue StandardError => e
          Rails.logger.error "Failed to import bead data: #{bead_data} - #{e.message}"
          nil
        end.compact
      end

      private

      # Create BeadDocument from Cosmos DB hash
      # @param cosmos_hash [Hash] document from Cosmos DB
      # @return [BeadDocument] model instance
      def from_cosmos_hash(cosmos_hash)
        new(cosmos_hash.transform_keys(&:to_sym))
      end
    end

    # Update the document
    # @return [Boolean] true if successful
    def update(attributes = {})
      assign_attributes(attributes)
      self.updated_at = Time.current
      
      if valid?
        CosmosDbService.update_document(
          CONTAINER_NAME,
          to_cosmos_hash,
          brand
        )
        true
      else
        false
      end
    end

    # Delete the document
    # @return [Boolean] true if successful
    def destroy
      return false unless id && brand
      
      CosmosDbService.delete_document(CONTAINER_NAME, id, brand)
    end

    # Convert to Cosmos DB hash format
    # @return [Hash] document hash for Cosmos DB
    def to_cosmos_hash
      attributes.compact.transform_keys(&:to_s).tap do |hash|
        # Ensure datetime fields are properly formatted
        hash['created_at'] = created_at.iso8601 if created_at
        hash['updated_at'] = updated_at.iso8601 if updated_at
        hash['scraped_at'] = scraped_at.iso8601 if scraped_at
      end
    end

    # Convert to JSON for API responses
    # @return [Hash] serialized document
    def as_json(options = {})
      to_cosmos_hash
    end
  end
end