#!/usr/bin/env python3
"""
Script to run the Miyuki Directory crawler and then import the data to database
"""

import logging
import sys
from pathlib import Path

# Add the crawler directory to the Python path
crawler_dir = Path(__file__).parent
sys.path.insert(0, str(crawler_dir))

from scrapy.crawler import CrawlerProcess
from scrapy.utils.project import get_project_settings
from spiders.miyuki_directory_crawler import MiyukiDirectoryCrawler
from importers.miyuki_directory import MiyukiDirectoryImporter

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(name)s] %(levelname)s: %(message)s'
)

logger = logging.getLogger(__name__)

def main():
    """Run the Miyuki Directory crawler and then import the data"""
    logger.info("🕷️  Starting Miyuki Directory crawler...")
    
    # Step 1: Run the crawler to scrape data to JSON
    settings = get_project_settings()
    settings.set('SPIDER_MODULES', ['spiders'])
    settings.set('NEWSPIDER_MODULE', 'spiders')

    process = CrawlerProcess(settings)
    process.crawl(MiyukiDirectoryCrawler)
    process.start()
    
    logger.info("✅ Crawler completed! JSON file created")
    
    # Step 2: Import the JSON data to database
    logger.info("📊 Starting database import...")
    
    try:
        importer = MiyukiDirectoryImporter()
        importer.connect_to_database()
        importer.load_existing_product_codes()
        
        result = importer.bulk_import_beads()
        
        logger.info(f"🎉 Import completed!")
        logger.info(f"📊 Total beads in file: {result['total_count']}")
        logger.info(f"✅ New beads imported: {result['imported_count']}")
        logger.info(f"🔄 Duplicates skipped: {result['duplicate_count']}")
        
        importer.close_connection()
        
    except Exception as e:
        logger.error(f"💥 Database import failed: {e}")
        raise
    
    logger.info("🚀 Complete pipeline finished: Scrape → Import → Done!")

if __name__ == '__main__':
    main() 