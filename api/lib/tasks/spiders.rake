# frozen_string_literal: true

require 'vessel'

namespace :spiders do
  desc 'Run the Fire Mountain Gems spider to crawl and populate the bead database'
  task fire_mountain_gems: :environment do
    puts 'Starting Fire Mountain Gems spider...'

    # Options can be passed as environment variables
    options = {}
    options[:max_pages] = ENV['MAX_PAGES'].to_i if ENV['MAX_PAGES'].present?
    options[:threads] = { max: ENV['CONCURRENCY'].to_i } if ENV['CONCURRENCY'].present?
    options[:delay] = ENV['DELAY'].to_f if ENV['DELAY'].present?

    puts "Running with options: #{options.inspect}"

    # Run the spider
    results = Spiders::FireMountainGems::Crawler.crawl_and_return_results(options)

    timestamp = Time.now.utc.strftime('%Y%m%d_%H%M%S')
    filename = File.join(Rails.root, 'tmp', 'crawler_results', 'fire_mountain_gems', "results_#{timestamp}.json")

    File.write(filename, JSON.pretty_generate(results))

    puts "Results saved to #{filename}"

    results.each do |result|
      Catalog::BeadCreatorService.create_from_spider_data(result)
    end

    puts 'Fire Mountain Gems spider completed!'
  end

  desc 'Run all spiders to populate the bead database'
  task all: :environment do
    puts 'Running all spiders...'

    # Add more spiders here as they are created
    Rake::Task['spiders:fire_mountain_gems'].invoke

    puts 'All spiders completed!'
  end
end