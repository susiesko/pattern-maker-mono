# frozen_string_literal: true

require 'aws-sdk-s3'

class S3StorageService
  class << self
    # Upload a file to S3
    # @param file_path [String] Local file path to upload
    # @param s3_key [String] S3 key (path) where file should be stored
    # @param options [Hash] Additional options
    # @return [Boolean] true if successful, false otherwise
    def upload_file(file_path, s3_key, options = {})
      return false unless File.exist?(file_path)
      return false unless configured?

      begin
        s3_client.put_object(
          bucket: bucket_name,
          key: s3_key,
          body: File.read(file_path),
          content_type: options[:content_type] || 'application/json',
          metadata: options[:metadata] || {}
        )

        Rails.logger.info "Successfully uploaded #{file_path} to s3://#{bucket_name}/#{s3_key}"
        true
      rescue Aws::S3::Errors::ServiceError => e
        Rails.logger.error "S3 upload failed: #{e.message}"
        false
      rescue StandardError => e
        Rails.logger.error "Unexpected error during S3 upload: #{e.message}"
        false
      end
    end

    # Upload scraped data with automatic timestamping
    # @param file_path [String] Local JSON file path
    # @param spider_name [String] Name of the spider (e.g., 'fire_mountain_gems')
    # @param options [Hash] Additional options
    # @return [Boolean] true if successful, false otherwise
    def upload_scraped_data(file_path, spider_name, options = {})
      timestamp = options[:timestamp] || Time.current.strftime('%Y%m%d_%H%M%S')
      site_name = options[:site_name] || spider_name
      s3_key = "beads/#{site_name}/feed-#{timestamp}.json"
      
      upload_file(file_path, s3_key, {
        content_type: 'application/json',
        metadata: {
          'spider' => spider_name,
          'scraped_at' => Time.current.iso8601,
          'rails_env' => Rails.env
        }.merge(options[:metadata] || {})
      })
    end

    # Check if S3 is properly configured
    # @return [Boolean] true if configured, false otherwise
    def configured?
      bucket_name.present? && 
      ENV['AWS_ACCESS_KEY_ID'].present? && 
      ENV['AWS_SECRET_ACCESS_KEY'].present?
    end

    # Get the configured bucket name
    # @return [String, nil] bucket name or nil if not configured
    def bucket_name
      @bucket_name ||= ENV['AWS_S3_BUCKET']
    end

    # Get the configured AWS region
    # @return [String] AWS region, defaults to 'us-east-1'
    def region
      @region ||= ENV['AWS_REGION'] || 'us-east-1'
    end

    private

    # Get or create S3 client
    # @return [Aws::S3::Client] configured S3 client
    def s3_client
      @s3_client ||= Aws::S3::Client.new(
        region: region,
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      )
    end
  end
end