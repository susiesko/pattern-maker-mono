# Bead Spiders

This directory contains web spiders built with the [Vessel](https://github.com/rubycdp/vessel) gem to crawl bead manufacturer websites and populate the bead database.

## Available Spiders

- `miyuki_wholesale_spider.rb` - Crawls the Miyuki Wholesale website to extract bead information
- `miyuki_wholesale_preview_spider.rb` - Preview version that doesn't save to the database
- `fire_mountain_gems_spider.rb` - Crawls the Fire Mountain Gems website for Miyuki Delica 11/0 beads
- `fire_mountain_gems_preview_spider.rb` - Preview version that doesn't save to the database

## Running Spiders

You can run the spiders using the provided Rake tasks:

```bash
# Run the Miyuki Wholesale spider
rails spiders:miyuki_wholesale

# Run the Miyuki Wholesale preview spider
rails spiders:miyuki_wholesale_preview

# Run the Fire Mountain Gems spider
rails spiders:fire_mountain_gems

# Run the Fire Mountain Gems preview spider
rails spiders:fire_mountain_gems_preview

# Run all spiders
rails spiders:all
```

## Spider Structure

Each spider follows a similar structure:

1. Define the domain and start URLs
2. Implement a `parse` method to handle the initial page and follow links
3. Implement specific parsing methods for different page types
4. Extract data and create/update database records

## Customizing Spiders

To customize a spider:

1. Adjust the CSS selectors to match the website's structure
2. Modify the data extraction logic as needed
3. Update the database record creation/update logic

## Adding New Spiders

To add a new spider:

1. Create a new Ruby file in this directory (e.g., `toho_spider.rb`)
2. Subclass `Vessel::Spider` and implement the required methods
3. Add a new Rake task in `lib/tasks/spiders.rake`
4. Add tests in `spec/lib/spiders/`

## Debugging

To debug a spider:

1. Set the log level to `:debug` in `config/initializers/vessel.rb`
2. Run the spider with the `DEBUG=true` environment variable:

```bash
DEBUG=true rails spiders:miyuki_wholesale
```

## Notes

- Spiders are configured to be polite to the target websites with appropriate delays
- Response caching is enabled to reduce load on the target websites
- The spider will automatically retry failed requests