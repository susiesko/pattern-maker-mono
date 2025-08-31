# frozen_string_literal: true

module Cosmos
  class UserDocument
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations
    include ActiveModel::SecurePassword

    # Document attributes
    attribute :id, :string
    attribute :email, :string
    attribute :username, :string
    attribute :password_digest, :string
    attribute :created_at, :datetime
    attribute :updated_at, :datetime
    
    # Embedded inventory settings
    attribute :inventory_settings, :string, default: -> { {} }
    
    # Embedded inventories array
    attribute :inventories, :string, default: -> { [] }

    # Validations
    validates :id, presence: true
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 30 }
    validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

    has_secure_password

    # Container configuration
    CONTAINER_NAME = 'users'
    PARTITION_KEY = '/email'

    class << self
      # Create a new user document
      # @param attributes [Hash] user attributes
      # @return [UserDocument] created document
      def create(attributes = {})
        doc = new(attributes)
        doc.id ||= SecureRandom.uuid
        doc.email = doc.email.downcase if doc.email
        doc.created_at = Time.current
        doc.updated_at = Time.current
        
        if doc.valid?
          cosmos_doc = CosmosDbService.create_document(
            CONTAINER_NAME,
            doc.to_cosmos_hash,
            doc.email
          )
          from_cosmos_hash(cosmos_doc)
        else
          doc
        end
      end

      # Find user by ID and email
      # @param id [String] document ID
      # @param email [String] email address (partition key)
      # @return [UserDocument, nil] found document or nil
      def find(id, email)
        cosmos_doc = CosmosDbService.find_document(CONTAINER_NAME, id, email.downcase)
        cosmos_doc ? from_cosmos_hash(cosmos_doc) : nil
      end

      # Find user by email
      # @param email [String] email address
      # @return [UserDocument, nil] found document or nil
      def find_by_email(email)
        query = "SELECT * FROM c WHERE c.email = @email"
        parameters = [{ name: '@email', value: email.downcase }]
        
        docs = CosmosDbService.query_documents(CONTAINER_NAME, query, parameters)
        docs.first ? from_cosmos_hash(docs.first) : nil
      end

      # Find user by username
      # @param username [String] username
      # @return [UserDocument, nil] found document or nil
      def find_by_username(username)
        query = "SELECT * FROM c WHERE c.username = @username"
        parameters = [{ name: '@username', value: username }]
        
        docs = CosmosDbService.query_documents(CONTAINER_NAME, query, parameters)
        docs.first ? from_cosmos_hash(docs.first) : nil
      end

      # Authenticate user
      # @param email_or_username [String] email or username
      # @param password [String] password
      # @return [UserDocument, nil] authenticated user or nil
      def authenticate(email_or_username, password)
        user = if email_or_username.include?('@')
                 find_by_email(email_or_username)
               else
                 find_by_username(email_or_username)
               end
        
        user&.authenticate(password) ? user : nil
      end

      private

      # Create UserDocument from Cosmos DB hash
      # @param cosmos_hash [Hash] document from Cosmos DB
      # @return [UserDocument] model instance
      def from_cosmos_hash(cosmos_hash)
        new(cosmos_hash.transform_keys(&:to_sym))
      end
    end

    # Update the document
    # @return [Boolean] true if successful
    def update(attributes = {})
      assign_attributes(attributes)
      self.email = email.downcase if email
      self.updated_at = Time.current
      
      if valid?
        CosmosDbService.update_document(
          CONTAINER_NAME,
          to_cosmos_hash,
          email
        )
        true
      else
        false
      end
    end

    # Delete the document
    # @return [Boolean] true if successful
    def destroy
      return false unless id && email
      
      CosmosDbService.delete_document(CONTAINER_NAME, id, email)
    end

    # Add bead to inventory
    # @param bead_id [String] bead document ID
    # @param quantity [Numeric] quantity to add
    # @param unit [String] quantity unit
    # @return [Boolean] true if successful
    def add_to_inventory(bead_id, quantity, unit = 'unit')
      existing_inventory = inventories.find { |inv| inv['bead_id'] == bead_id }
      
      if existing_inventory
        existing_inventory['quantity'] += quantity
        existing_inventory['updated_at'] = Time.current.iso8601
      else
        inventories << {
          'bead_id' => bead_id,
          'quantity' => quantity,
          'quantity_unit' => unit,
          'added_at' => Time.current.iso8601,
          'updated_at' => Time.current.iso8601
        }
      end
      
      update
    end

    # Remove bead from inventory
    # @param bead_id [String] bead document ID
    # @return [Boolean] true if successful
    def remove_from_inventory(bead_id)
      inventories.reject! { |inv| inv['bead_id'] == bead_id }
      update
    end

    # Update inventory settings
    # @param settings [Hash] new settings
    # @return [Boolean] true if successful
    def update_inventory_settings(settings)
      self.inventory_settings = inventory_settings.merge(settings)
      update
    end

    # Check if new record (no ID assigned yet)
    # @return [Boolean] true if new record
    def new_record?
      id.blank?
    end

    # Convert to Cosmos DB hash format
    # @return [Hash] document hash for Cosmos DB
    def to_cosmos_hash
      attributes.compact.transform_keys(&:to_s).tap do |hash|
        # Ensure datetime fields are properly formatted
        hash['created_at'] = created_at.iso8601 if created_at
        hash['updated_at'] = updated_at.iso8601 if updated_at
        
        # Ensure nested objects are properly serialized
        hash['inventory_settings'] = inventory_settings.is_a?(Hash) ? inventory_settings : {}
        hash['inventories'] = inventories.is_a?(Array) ? inventories : []
      end
    end

    # Convert to JSON for API responses (exclude sensitive data)
    # @return [Hash] serialized document
    def as_json(options = {})
      to_cosmos_hash.except('password_digest')
    end
  end
end