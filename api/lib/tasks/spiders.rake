# frozen_string_literal: true

require 'vessel'

namespace :spiders do
  desc 'Run the Miyuki Wholesale spider to crawl and populate the bead database'
  task miyuki_wholesale: :environment do
    puts 'Starting Miyuki Wholesale spider...'

    # Load the spider
    require Rails.root.join('lib', 'spiders', 'miyuki_wholesale_spider')

    # Options can be passed as environment variables
    options = {}
    options[:max_pages] = ENV['MAX_PAGES'].to_i if ENV['MAX_PAGES'].present?
    options[:threads] = { max: ENV['CONCURRENCY'].to_i } if ENV['CONCURRENCY'].present?
    options[:delay] = ENV['DELAY'].to_f if ENV['DELAY'].present?

    puts "Running with options: #{options.inspect}"

    # Run the spider
    MiyukiWholesaleSpider.run(options)

    puts 'Miyuki Wholesale spider completed!'
  end

  desc 'Run the Miyuki Wholesale preview spider to see results without saving to database'
  task miyuki_wholesale_preview: :environment do
    puts 'Starting Miyuki Wholesale preview spider...'

    # Load the preview spider
    require Rails.root.join('lib', 'spiders', 'miyuki_wholesale_preview_spider')

    # Options can be passed as environment variables
    options = {}
    options[:max_pages] = ENV['MAX_PAGES'].to_i if ENV['MAX_PAGES'].present?
    options[:threads] = { max: ENV['CONCURRENCY'].to_i } if ENV['CONCURRENCY'].present?
    options[:delay] = ENV['DELAY'].to_f if ENV['DELAY'].present?

    puts "Running with options: #{options.inspect}"

    # Run the spider and get results
    results = MiyukiWholesalePreviewSpider.crawl_and_return_results(options)

    # Export to JSON file if requested
    if ENV['EXPORT_JSON'].present?
      require 'json'
      filename = ENV['EXPORT_JSON'] == 'true' ? 'miyuki_wholesale_beads.json' : ENV['EXPORT_JSON']
      File.write(filename, JSON.pretty_generate(results))
      puts "Results exported to #{filename}"
    end
  end

  desc 'Run the Fire Mountain Gems spider to crawl and populate the bead database'
  task fire_mountain_gems: :environment do
    puts 'Starting Fire Mountain Gems spider...'

    # Load the spider
    require Rails.root.join('lib', 'spiders', 'fire_mountain_gems_spider')

    # Options can be passed as environment variables
    options = {}
    options[:max_pages] = ENV['MAX_PAGES'].to_i if ENV['MAX_PAGES'].present?
    options[:threads] = { max: ENV['CONCURRENCY'].to_i } if ENV['CONCURRENCY'].present?
    options[:delay] = ENV['DELAY'].to_f if ENV['DELAY'].present?

    puts "Running with options: #{options.inspect}"

    # Run the spider
    FireMountainGemsSpider.run(options)

    puts 'Fire Mountain Gems spider completed!'
  end

  desc 'Run the Fire Mountain Gems preview spider to see results without saving to database'
  task fire_mountain_gems_preview: :environment do
    puts 'Starting Fire Mountain Gems preview spider...'

    # Load the preview spider
    require Rails.root.join('lib', 'spiders', 'fire_mountain_gems_preview_spider')

    # Options can be passed as environment variables
    options = {}
    options[:max_pages] = ENV['MAX_PAGES'].to_i if ENV['MAX_PAGES'].present?
    options[:threads] = { max: ENV['CONCURRENCY'].to_i } if ENV['CONCURRENCY'].present?
    options[:delay] = ENV['DELAY'].to_f if ENV['DELAY'].present?

    puts "Running with options: #{options.inspect}"

    # Run the spider and get results
    results = FireMountainGemsPreviewSpider.crawl_and_return_results(options)

    # Export to JSON file if requested
    if ENV['EXPORT_JSON'].present?
      require 'json'
      filename = ENV['EXPORT_JSON'] == 'true' ? 'fire_mountain_gems_beads.json' : ENV['EXPORT_JSON']
      File.write(filename, JSON.pretty_generate(results))
      puts "Results exported to #{filename}"
    end
  end

  desc 'Run all spiders to populate the bead database'
  task all: :environment do
    puts 'Running all spiders...'

    # Add more spiders here as they are created
    Rake::Task['spiders:miyuki_wholesale'].invoke
    Rake::Task['spiders:fire_mountain_gems'].invoke

    puts 'All spiders completed!'
  end
end