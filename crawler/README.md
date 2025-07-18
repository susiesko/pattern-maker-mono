# 🕷️ Pattern Maker Crawler

Simple web crawler for Fire Mountain Gems Miyuki Delica beads.

## 🎯 What It Does

1. **Crawls** Fire Mountain Gems website for Miyuki Delica beads
2. **Extracts** product data (name, code, size, image, etc.)
3. **Saves** to `beads.json` file
4. **Rails imports** the JSON into the database

## 🚀 Quick Start

### 1. Run the Crawler

```bash
cd crawler
source venv/bin/activate
python run_crawler.py
```

This will:

- Crawl Fire Mountain Gems
- Extract all Miyuki Delica beads
- Save to `beads.json`
- Show a summary

### 2. Import to Rails Database

```bash
cd api
rails beads:import
```

This will:

- Read `beads.json`
- Import beads into the database
- Handle duplicates and errors

### 3. Check Status

```bash
cd api
rails beads:status
```

## 📁 File Structure

```
crawler/
├── run_crawler.py          # Simple runner script
├── spiders/
│   └── fire_mountain_gems_view.py  # Main crawler
├── config/
│   └── settings.py         # Scrapy settings
├── requirements.txt         # Python dependencies
└── beads.json             # Output file (created by crawler)

api/
└── lib/tasks/
    └── import_beads.rake  # Rails import script
```

## 🔧 Configuration

### Scrapy Settings (`config/settings.py`)

- **`DOWNLOAD_DELAY = 1.0`**: Wait 1 second between requests
- **`ROBOTSTXT_OBEY = True`**: Respect robots.txt
- **`HTTPCACHE_ENABLED = True`**: Cache responses

### Environment Variables

Create `.env` file in crawler directory:

```bash
# Optional - for API mode (not used in JSON mode)
API_BASE_URL=http://localhost:3000
API_TOKEN=your_token_here
```

## 📊 Data Flow

1. **Python crawler** → `beads.json`
2. **Rails rake task** → Database

### Example JSON Output

```json
[
  {
    "name": "Miyuki Delica DB-1234, Red",
    "product_code": "DB-1234",
    "brand": "Miyuki",
    "type": "Delica",
    "size": "11/0",
    "image_url": "https://...",
    "source_url": "https://..."
  }
]
```

## 🚀 Performance

- **Crawling**: ~30 seconds for 1000+ beads
- **Import**: ~5 seconds for 1000+ beads
- **Memory**: Low (no database connections in Python)
- **Network**: Minimal (just crawling, no API calls)

## 🐛 Troubleshooting

### Common Issues

1. **Import errors**: Make sure you're in the crawler directory
2. **Rate limiting**: Increase `DOWNLOAD_DELAY` in settings
3. **Missing dependencies**: Run `pip install -r requirements.txt`
4. **JSON not found**: Run the crawler first

### Debug Mode

```bash
cd crawler
scrapy crawl fire_mountain_gems -L DEBUG
```

## 🔄 Adding New Suppliers

To add a new supplier:

1. Create a new spider in `spiders/`
2. Follow the same pattern as `fire_mountain_gems_view.py`
3. Update the output format to match the JSON structure
4. Create a corresponding Rails rake task

## 🧹 Code Quality

- **Simple**: One spider, one output format
- **Focused**: Each tool has a single responsibility
- **Maintainable**: Easy to understand and modify
- **Reliable**: No complex database integration in Python

## 🤝 Contributing

1. Follow the existing code structure
2. Add proper error handling
3. Include logging for debugging
4. Test with different sites
5. Update documentation

## 📝 License

Part of the Pattern Maker project.
