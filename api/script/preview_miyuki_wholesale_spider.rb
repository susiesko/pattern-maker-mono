# frozen_string_literal: true

# This script runs the Miyuki Wholesale preview spider and provides an interactive console
# to explore the results.
#
# Usage:
#   rails runner script/preview_miyuki_wholesale_spider.rb [options]
#
# Options:
#   MAX_PAGES=5      Limit the crawl to 5 pages
#   CONCURRENCY=3    Use 3 concurrent connections
#   DELAY=2.0        Wait 2 seconds between requests
#   EXPORT_JSON=true Export results to miyuki_beads.json

require 'irb'

puts "Loading Miyuki Wholesale preview spider..."
require Rails.root.join('lib', 'spiders', 'miyuki_wholesale_preview_spider')

# Set up options from environment variables
options = {}
options[:max_pages] = ENV['MAX_PAGES'].to_i if ENV['MAX_PAGES'].present?
options[:threads] = { max: ENV['CONCURRENCY'].to_i } if ENV['CONCURRENCY'].present?
options[:delay] = ENV['DELAY'].to_f if ENV['DELAY'].present?

puts "Starting crawl with options: #{options.inspect}"

# Run the spider and get results
results = MiyukiWholesalePreviewSpider.crawl_and_return_results(options)

puts "\nCrawl completed!"
puts "Found #{results[:beads].length} beads in #{results[:categories].length} categories"

# Export to JSON file if requested
if ENV['EXPORT_JSON'].present?
  require 'json'
  filename = ENV['EXPORT_JSON'] == 'true' ? 'miyuki_wholesale_beads.json' : ENV['EXPORT_JSON']
  File.write(filename, JSON.pretty_generate(results))
  puts "Results exported to #{filename}"
end

puts "\nStarting interactive console. The results are available in the 'results' variable."
puts "Example commands:"
puts "  results[:beads].count                  # Count of beads found"
puts "  results[:beads].first                  # First bead details"
puts "  results[:beads].select { |b| b[:color].include?('Blue') }  # Find blue beads"
puts "  File.write('blue_beads.json', JSON.pretty_generate(results[:beads].select { |b| b[:color].include?('Blue') }))  # Export blue beads to JSON"

# Make variables available in the IRB session
TOPLEVEL_BINDING.local_variable_set(:results, results)

# Start an interactive IRB session
IRB.start