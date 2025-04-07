# Miyuki Spider Guide

This guide explains how to use the Miyuki spider to crawl the English Miyuki website and populate your bead database.

## Overview

The Miyuki spider is built using the [Vessel](https://github.com/rubycdp/vessel) gem, which provides a powerful and flexible framework for web scraping in Ruby. The spider crawls the English Miyuki website, extracts information about beads, and stores it in your database.

## Prerequisites

- Ruby 3.x
- Rails 8.x
- PostgreSQL database
- Vessel gem (already included in the Gemfile)

## Running the Spider

There are several ways to run the Miyuki spider:

### 1. Using Rake Tasks

The simplest way to run the spider is using the provided Rake tasks:

```bash
# Run the Miyuki spider
rails spiders:miyuki

# Run all spiders (including Miyuki)
rails spiders:all
```

### 2. Using the Admin API

If you're an admin user, you can trigger the spider through the API:

```bash
# Get a list of available spiders
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" http://localhost:3000/admin/spiders

# Run the Miyuki spider
curl -X POST -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"max_pages": 10, "concurrency": 2}' \
  http://localhost:3000/admin/spiders/miyuki/run
```

### 3. Using the Service Directly

You can also run the spider programmatically using the provided service:

```ruby
# Run the spider synchronously
result = Catalog::SpiderRunnerService.new('miyuki', max_pages: 10).call

# Run the spider asynchronously as a background job
Catalog::RunSpiderJob.perform_later('miyuki', max_pages: 10)
```

## Configuration Options

The spider accepts several configuration options:

- `max_pages`: Maximum number of pages to crawl (default: unlimited)
- `concurrency`: Number of concurrent requests (default: 2)
- `delay`: Delay between requests in seconds (default: 1.0)
- `cache_responses`: Whether to cache responses (default: true)

## How It Works

The Miyuki spider works as follows:

1. Starts at the main beads page: `https://www.miyuki-beads.co.jp/english/beads/`
2. Identifies links to different bead categories (e.g., Delica, Round)
3. For each category:
   - Extracts bead size information
   - Extracts individual bead details (product code, name, color, finish)
   - Creates or updates database records
   - Follows pagination links to process all pages

## Database Structure

The spider populates the following tables:

- `bead_brands`: Information about the Miyuki brand
- `bead_types`: Different types of beads (e.g., Delica, Round)
- `bead_sizes`: Sizes for each bead type (e.g., 11/0, 15/0)
- `bead_colors`: Colors of beads
- `bead_finishes`: Finishes applied to beads
- `beads`: Individual bead products with their details
- `bead_color_links`: Associations between beads and colors
- `bead_finish_links`: Associations between beads and finishes

## Customizing the Spider

If you need to customize the spider's behavior:

1. Open the spider file at `lib/spiders/miyuki_spider.rb`
2. Adjust the CSS selectors to match the website's structure
3. Modify the data extraction logic as needed
4. Update the database record creation/update logic

## Troubleshooting

### Common Issues

1. **Spider not finding any beads**:
   - Check if the website structure has changed
   - Update the CSS selectors in the spider

2. **Rate limiting or blocking**:
   - Increase the `delay` between requests
   - Use a different user agent

3. **Database errors**:
   - Check if all required tables and associations exist
   - Ensure the database schema matches the expected structure

### Debugging

To enable debug logging:

```bash
DEBUG=true rails spiders:miyuki
```

## Maintenance

The spider should be periodically checked and updated to ensure it continues to work with the Miyuki website. If the website structure changes, you may need to update the CSS selectors and data extraction logic.

## Next Steps

After running the spider successfully, you can:

1. Verify the data in your database
2. Use the data in your application
3. Set up scheduled runs to keep your database up to date

For scheduled runs, consider using a cron job or a scheduled job framework like Sidekiq Scheduler or Whenever.

## Related Resources

- [Vessel Documentation](https://github.com/rubycdp/vessel)
- [Miyuki Website](https://www.miyuki-beads.co.jp/english/)
- [Web Scraping Best Practices](https://www.scrapehero.com/how-to-prevent-getting-blacklisted-while-scraping/)