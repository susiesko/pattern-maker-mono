#!/usr/bin/env python3
"""
Simple script to run the Fire Mountain Gems crawler
"""

import logging
import sys
from pathlib import Path

# Add the crawler directory to the Python path
crawler_dir = Path(__file__).parent
sys.path.insert(0, str(crawler_dir))

from scrapy.crawler import CrawlerProcess
from scrapy.utils.project import get_project_settings
from spiders.fire_mountain_gems_view import FireMountainGemsSpider

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(name)s] %(levelname)s: %(message)s'
)

logger = logging.getLogger(__name__)

def main():
    """Run the crawler"""
    logger.info("🕷️  Starting Fire Mountain Gems crawler...")
    
    # Set up Scrapy
    settings = get_project_settings()
    settings.set('SPIDER_MODULES', ['spiders'])
    settings.set('NEWSPIDER_MODULE', 'spiders')
    
    # Create and run crawler
    process = CrawlerProcess(settings)
    process.crawl(FireMountainGemsSpider)
    process.start()
    
    logger.info("✅ Crawler completed! Check beads.json for results")

if __name__ == '__main__':
    main() 