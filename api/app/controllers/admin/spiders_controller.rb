# frozen_string_literal: true

module Admin
  class SpidersController < ApplicationController
    before_action :authenticate_admin!

    # GET /admin/spiders
    def index
      render json: {
        available_spiders: available_spiders
      }
    end

    # POST /admin/spiders/:name/run
    def run
      spider_name = params[:name]

      # Validate the spider name
      return render json: { error: "Unknown spider: #{spider_name}" }, status: :bad_request unless available_spiders.include?(spider_name)

      # Enqueue the spider job
      job = Catalog::RunSpiderJob.perform_later(
        spider_name,
        spider_options
      )

      render json: {
        message: "Spider #{spider_name} job enqueued",
        job_id: job.job_id
      }
    end

    private

    def authenticate_admin!
      # Implement your admin authentication logic here
      # For example:
      return if current_user&.admin?

      render json: { error: 'Unauthorized' }, status: :unauthorized
    end

    def available_spiders
      # Get all spider files and extract their names
      spider_files = Dir[Rails.root.join('lib', 'spiders', '*_spider.rb')]
      spider_files.map { |file| File.basename(file, '_spider.rb') }
    end

    def spider_options
      params.permit(:max_pages, :concurrency, :delay, :cache_responses).to_h
    end
  end
end
