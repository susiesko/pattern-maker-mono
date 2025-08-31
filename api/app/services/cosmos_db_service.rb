# frozen_string_literal: true

require 'faraday'
require 'faraday/retry'
require 'base64'
require 'openssl'
require 'cgi'

class CosmosDbService
  class << self
    # Check if Cosmos DB is properly configured
    # @return [Boolean] true if configured, false otherwise
    def configured?
      endpoint.present? && key.present? && database_name.present?
    end

    # Test the connection to Cosmos DB
    # @return [Boolean] true if connection successful
    def test_connection
      return false unless configured?
      
      response = http_client.get("/dbs") do |req|
        req.headers.merge!(auth_headers('get', 'dbs', ''))
      end
      
      response.success?
    rescue StandardError => e
      Rails.logger.error "Cosmos DB connection test failed: #{e.message}"
      false
    end

    # Create a document in a container
    # @param container_name [String] container name
    # @param document [Hash] document to create
    # @param partition_key [String] partition key value
    # @return [Hash] created document
    def create_document(container_name, document, partition_key)
      ensure_container_exists(container_name)
      
      resource_link = "dbs/#{database_name}/colls/#{container_name}/docs"
      
      response = http_client.post("/#{resource_link}") do |req|
        req.headers.merge!(auth_headers('post', resource_link, ''))
        req.headers['x-ms-documentdb-partitionkey'] = "[\"#{partition_key}\"]"
        req.headers['Content-Type'] = 'application/json'
        req.body = document.to_json
      end
      
      if response.success?
        JSON.parse(response.body)
      else
        raise "Failed to create document: #{response.status} - #{response.body}"
      end
    rescue StandardError => e
      Rails.logger.error "Error creating document: #{e.message}"
      raise
    end

    # Find a document by ID
    # @param container_name [String] container name  
    # @param document_id [String] document ID
    # @param partition_key [String] partition key value
    # @return [Hash, nil] document or nil if not found
    def find_document(container_name, document_id, partition_key)
      resource_link = "dbs/#{database_name}/colls/#{container_name}/docs/#{document_id}"
      
      response = http_client.get("/#{resource_link}") do |req|
        req.headers.merge!(auth_headers('get', resource_link, ''))
        req.headers['x-ms-documentdb-partitionkey'] = "[\"#{partition_key}\"]"
      end
      
      if response.success?
        JSON.parse(response.body)
      elsif response.status == 404
        nil
      else
        raise "Failed to find document: #{response.status} - #{response.body}"
      end
    rescue StandardError => e
      Rails.logger.error "Error finding document: #{e.message}"
      raise
    end

    # Query documents using SQL
    # @param container_name [String] container name
    # @param query [String] SQL query
    # @param parameters [Array] query parameters
    # @return [Array<Hash>] matching documents
    def query_documents(container_name, query, parameters = [])
      resource_link = "dbs/#{database_name}/colls/#{container_name}/docs"
      
      query_spec = {
        query: query,
        parameters: parameters
      }
      
      response = http_client.post("/#{resource_link}") do |req|
        req.headers.merge!(auth_headers('post', resource_link, ''))
        req.headers['Content-Type'] = 'application/query+json'
        req.headers['x-ms-documentdb-isquery'] = 'True'
        req.body = query_spec.to_json
      end
      
      if response.success?
        result = JSON.parse(response.body)
        result['Documents'] || []
      else
        raise "Failed to query documents: #{response.status} - #{response.body}"
      end
    rescue StandardError => e
      Rails.logger.error "Error querying documents: #{e.message}"
      raise
    end

    # Get configured endpoint
    # @return [String, nil] endpoint URL or nil if not configured  
    def endpoint
      @endpoint ||= ENV['COSMOS_DB_ENDPOINT']
    end

    # Get configured key
    # @return [String, nil] access key or nil if not configured
    def key
      @key ||= ENV['COSMOS_DB_KEY']
    end

    # Get configured database name
    # @return [String, nil] database name or nil if not configured
    def database_name
      @database_name ||= ENV['COSMOS_DB_DATABASE'] || 'pattern_maker'
    end

    private

    # Get HTTP client for Cosmos DB REST API
    # @return [Faraday::Connection] HTTP client
    def http_client
      @http_client ||= Faraday.new(url: endpoint) do |faraday|
        faraday.request :retry, max: 3, interval: 0.5
        faraday.adapter Faraday.default_adapter
      end
    end

    # Generate authentication headers for Cosmos DB REST API
    # @param verb [String] HTTP verb (get, post, etc.)
    # @param resource_type [String] resource type
    # @param resource_link [String] resource link
    # @return [Hash] authentication headers
    def auth_headers(verb, resource_type, resource_link)
      utc_date = Time.now.utc.strftime('%a, %d %b %Y %H:%M:%S GMT')
      
      string_to_sign = "#{verb.downcase}\n#{resource_type.downcase}\n#{resource_link}\n#{utc_date.downcase}\n\n"
      
      signature = Base64.strict_encode64(
        OpenSSL::HMAC.digest('SHA256', Base64.decode64(key), string_to_sign)
      )
      
      auth_string = CGI.escape("type=master&ver=1.0&sig=#{signature}")
      
      {
        'authorization' => auth_string,
        'x-ms-date' => utc_date,
        'x-ms-version' => '2018-12-31'
      }
    end

    # Ensure container exists, create if not
    # @param container_name [String] container name
    def ensure_container_exists(container_name)
      @created_containers ||= Set.new
      return if @created_containers.include?(container_name)
      
      # Check if container exists
      resource_link = "dbs/#{database_name}/colls/#{container_name}"
      response = http_client.get("/#{resource_link}") do |req|
        req.headers.merge!(auth_headers('get', 'colls', "dbs/#{database_name}"))
      end
      
      unless response.success?
        # Create container
        create_container(container_name)
      end
      
      @created_containers.add(container_name)
    end

    # Create a new container
    # @param container_name [String] container name
    def create_container(container_name, partition_key = '/id')
      resource_link = "dbs/#{database_name}/colls"
      
      container_spec = {
        id: container_name,
        partitionKey: {
          paths: [partition_key],
          kind: 'Hash'
        }
      }
      
      response = http_client.post("/#{resource_link}") do |req|
        req.headers.merge!(auth_headers('post', 'colls', "dbs/#{database_name}"))
        req.headers['Content-Type'] = 'application/json'
        req.body = container_spec.to_json
      end
      
      unless response.success?
        raise "Failed to create container: #{response.status} - #{response.body}"
      end
      
      Rails.logger.info "Created Cosmos DB container: #{container_name}"
    end
  end
end