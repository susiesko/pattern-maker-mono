# Fire Mountain Gems Spider Guide

This guide explains how to use the Fire Mountain Gems spider to crawl the Fire Mountain Gems website for Miyuki Delica beads and populate your bead database.

## Overview

The Fire Mountain Gems spider is built using the [Vessel](https://github.com/rubycdp/vessel) gem, which provides a powerful and flexible framework for web scraping in Ruby. The spider crawls the Fire Mountain Gems website's Miyuki section, extracts information about Delica beads, and stores it in your database.

## Prerequisites

- Ruby 3.x
- Rails 8.x
- PostgreSQL database
- Vessel gem (already included in the Gemfile)

## Setup

Before running the spider, create the output directory:

```bash
mkdir -p tmp/crawler_results/fire_mountain_gems
```

## Running the Spider

### Using Rake Tasks

The simplest way to run the spider is using the provided Rake tasks:

```bash
# Run the Fire Mountain Gems spider
rails spiders:fire_mountain_gems

# Run all spiders
rails spiders:all
```

### Configuration with Environment Variables

You can configure the spider using environment variables:

```bash
# Run with specific options
MAX_PAGES=10 CONCURRENCY=2 DELAY=1.5 rails spiders:fire_mountain_gems
```

### Using the Spider Directly

You can also run the spider programmatically:

```ruby
# Run the spider and get results
results = Spiders::FireMountainGems::Crawler.crawl_and_return_results(
  max_pages: 10,
  threads: { max: 2 },
  delay: 1.0
)

# Process results
results.each do |result|
  Catalog::BeadCreatorService.create_from_spider_data(result)
end
```

## Configuration Options

The spider accepts several configuration options:

- `max_pages`: Maximum number of pages to crawl (default: unlimited)
- `threads`: Thread configuration hash with `max` key for concurrency (default: 1)
- `delay`: Delay between requests in seconds (default: 1.0)

## How It Works

The Fire Mountain Gems spider works as follows:

1. Starts at the Miyuki beads page: `https://www.firemountaingems.com/beads/beads-by-brand/miyuki/`
2. Identifies product tiles on each page
3. For each product:
   - Extracts product name and code (DB, DBS, DBM, DBL prefixes)
   - Determines bead size based on product code prefix
   - Extracts image URL and price information
   - Parses colors and finishes from product names
   - Creates structured data for database insertion
4. Follows pagination links to process all pages
5. Saves results to JSON files in `tmp/crawler_results/fire_mountain_gems/`
6. Processes results through `Catalog::BeadCreatorService`

## Technical Details

The spider inherits from `Vessel::Cargo` and uses CSS selectors to parse HTML:

- `.product-tile` - Product containers
- `.link` - Product links
- `h3.name` - Product names
- `img.tile-image` - Product images
- `.pricebooks .pricebook:first-child .price` - Pricing information
- `a.page-link-next` - Pagination links

## Database Structure

The spider populates the following tables:

- `bead_brands`: Information about the Miyuki brand
- `bead_types`: Different types of beads (Delica)
- `bead_sizes`: Sizes for each bead type (11/0, 15/0, 10/0, 8/0)
- `bead_colors`: Colors of beads (extracted from product names)
- `bead_finishes`: Finishes applied to beads (extracted from product names)
- `beads`: Individual bead products with their details
- `bead_color_links`: Associations between beads and colors
- `bead_finish_links`: Associations between beads and finishes

## Product Code Mapping

The spider automatically maps product codes to bead sizes:

- `DB-` prefix → 11/0 size
- `DBS-` prefix → 15/0 size  
- `DBM-` prefix → 10/0 size
- `DBL-` prefix → 8/0 size

## Data Extraction

The spider extracts:

- **Product name**: From the product tile heading
- **Brand product code**: Parsed from product name (e.g., "DB-0001")
- **Image URL**: From product tile image
- **Price**: From pricing information
- **Colors**: Extracted from product name using database matching
- **Finishes**: Extracted from product name using database matching
- **Metadata**: Source URL and additional product information

## Customizing the Spider

To customize the spider's behavior:

1. Open `lib/spiders/fire_mountain_gems/crawler.rb`
2. Adjust CSS selectors in `parse_product_listings` method
3. Modify data extraction logic in `parse_product` method
4. Update color/finish extraction methods if needed

## Troubleshooting

### Common Issues

1. **Output directory missing**:
   ```bash
   mkdir -p tmp/crawler_results/fire_mountain_gems
   ```

2. **Spider not finding products**:
   - Check if Fire Mountain Gems website structure has changed
   - Update CSS selectors (`.product-tile`, `.link`, `h3.name`)

3. **Rate limiting or blocking**:
   - Increase the `DELAY` environment variable
   - Reduce `CONCURRENCY` setting

4. **Database errors**:
   - Ensure all required tables exist
   - Check that `Catalog::BeadCreatorService` is working properly

5. **Missing colors/finishes**:
   - Verify color and finish data exists in database
   - Check extraction logic in `extract_colors_from_name` and `extract_finishes_from_name`

### Debugging

Enable debug logging:

```bash
DEBUG=true rails spiders:fire_mountain_gems
```

Check crawler results:

```bash
ls -la tmp/crawler_results/fire_mountain_gems/
```

## Output Files

The spider saves results to timestamped JSON files:
- Location: `tmp/crawler_results/fire_mountain_gems/`
- Format: `results_YYYYMMDD_HHMMSS.json`

## Maintenance

- Monitor Fire Mountain Gems website for structure changes
- Update CSS selectors if products aren't being found
- Verify color/finish extraction accuracy
- Check for new product code patterns

## Related Resources

- [Vessel Documentation](https://github.com/rubycdp/vessel)
- [Fire Mountain Gems Website](https://www.firemountaingems.com/)
- [Web Scraping Best Practices](https://www.scrapehero.com/how-to-prevent-getting-blacklisted-while-scraping/)
