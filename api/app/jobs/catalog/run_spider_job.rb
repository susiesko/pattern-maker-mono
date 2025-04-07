# frozen_string_literal: true

module Catalog
  class RunSpiderJob < ApplicationJob
    queue_as :spiders

    # Retry the job if it fails, with exponential backoff
    retry_on StandardError, wait: :exponentially_longer, attempts: 3

    # Discard the job if it fails after retries
    discard_on StandardError do |job, error|
      Rails.logger.error("Spider job discarded: #{error.message}")
    end

    def perform(spider_name, options = {})
      # Convert string keys to symbols
      options = options.transform_keys(&:to_sym) if options.is_a?(Hash)

      # Run the spider
      result = Catalog::SpiderRunnerService.new(spider_name, options).call

      # Log the result
      if result[:success]
        Rails.logger.info(result[:message])
      else
        Rails.logger.error(result[:message])
        raise result[:error] if result[:error]
      end
    end
  end
end
