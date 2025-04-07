# frozen_string_literal: true

module Catalog
  class SpiderRunnerService
    attr_reader :spider_name, :options

    def initialize(spider_name, options = {})
      @spider_name = spider_name
      @options = options
    end

    def call
      # Load the spider class
      require_spider

      # Run the spider
      spider_class.run(spider_options)

      # Return success
      { success: true, message: "#{spider_name} spider completed successfully" }
    rescue => e
      # Log the error
      Rails.logger.error("Spider error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))

      # Return error
      { success: false, message: "Spider error: #{e.message}", error: e }
    end

    private

    def require_spider
      require Rails.root.join('lib', 'spiders', "#{spider_name.underscore}_spider")
    end

    def spider_class
      "#{spider_name.camelize}Spider".constantize
    end

    def spider_options
      {
        threads: { max: options[:concurrency] || 2 },
        delay: options[:delay] || 1.0,
        max_pages: options[:max_pages]
      }.compact
    end
  end
end