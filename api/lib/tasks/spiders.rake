# frozen_string_literal: true

require 'vessel'

namespace :spiders do
  desc 'Run the Miyuki spider to crawl and populate the bead database'
  task miyuki: :environment do
    puts 'Starting Miyuki spider...'

    # Load the spider
    require Rails.root.join('lib', 'spiders', 'miyuki_spider')

    # Options can be passed as environment variables
    options = {}
    options[:max_pages] = ENV['MAX_PAGES'].to_i if ENV['MAX_PAGES'].present?
    options[:threads] = { max: ENV['CONCURRENCY'].to_i } if ENV['CONCURRENCY'].present?
    options[:delay] = ENV['DELAY'].to_f if ENV['DELAY'].present?

    puts "Running with options: #{options.inspect}"

    # Run the spider
    MiyukiSpider.run(options)

    puts 'Miyuki spider completed!'
  end

  desc 'Run the Miyuki preview spider to see results without saving to database'
  task miyuki_preview: :environment do
    puts 'Starting Miyuki preview spider...'

    # Load the preview spider
    require Rails.root.join('lib', 'spiders', 'miyuki_preview_spider')

    # Options can be passed as environment variables
    options = {}
    options[:max_pages] = ENV['MAX_PAGES'].to_i if ENV['MAX_PAGES'].present?
    options[:threads] = { max: ENV['CONCURRENCY'].to_i } if ENV['CONCURRENCY'].present?
    options[:delay] = ENV['DELAY'].to_f if ENV['DELAY'].present?

    puts "Running with options: #{options.inspect}"

    # Run the spider and get results
    results = MiyukiPreviewSpider.crawl_and_return_results(options)

    # Export to JSON file if requested
    if ENV['EXPORT_JSON'].present?
      require 'json'
      filename = ENV['EXPORT_JSON'] == 'true' ? 'miyuki_beads.json' : ENV['EXPORT_JSON']
      File.write(filename, JSON.pretty_generate(results))
      puts "Results exported to #{filename}"
    end
  end

  desc 'Run all spiders to populate the bead database'
  task all: :environment do
    puts 'Running all spiders...'

    # Add more spiders here as they are created
    Rake::Task['spiders:miyuki'].invoke

    puts 'All spiders completed!'
  end
end