#!/usr/bin/env python3
"""
Script to run the Fire Mountain Gems spider with S3 upload capability
"""

import logging
import sys
import os
from pathlib import Path

# Add the crawler directory to the Python path
crawler_dir = Path(__file__).parent
sys.path.insert(0, str(crawler_dir))

# Load environment variables from .env file
try:
    from dotenv import load_dotenv
    load_dotenv(crawler_dir / '.env')
    print("✅ Loaded environment variables from .env file")
except ImportError:
    print("⚠️  python-dotenv not installed - please set environment variables manually")
except Exception as e:
    print(f"⚠️  Could not load .env file: {e}")

from scrapy.crawler import CrawlerProcess
from scrapy.utils.project import get_project_settings
from spiders.fire_mountain_gems_view import FireMountainGemsSpider

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(name)s] %(levelname)s: %(message)s',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler('fire_mountain_gems_spider.log')
    ]
)

logger = logging.getLogger(__name__)

def check_s3_config():
    """Check if S3 configuration is present"""
    bucket = os.environ.get('AWS_S3_BUCKET')
    access_key = os.environ.get('AWS_ACCESS_KEY_ID')
    secret_key = os.environ.get('AWS_SECRET_ACCESS_KEY')
    
    if not all([bucket, access_key, secret_key]):
        logger.warning("🚨 S3 upload not configured - scraped data will only be saved locally")
        logger.info("To enable S3 upload, set these environment variables:")
        logger.info("  - AWS_S3_BUCKET")
        logger.info("  - AWS_ACCESS_KEY_ID") 
        logger.info("  - AWS_SECRET_ACCESS_KEY")
        logger.info("  - AWS_REGION (optional, defaults to us-east-1)")
        return False
    else:
        logger.info(f"✅ S3 upload configured - will upload to bucket: {bucket}")
        return True

def main():
    """Run the Fire Mountain Gems spider"""
    logger.info("🕷️  Starting Fire Mountain Gems spider...")
    
    # Check S3 configuration
    s3_configured = check_s3_config()
    
    # Get scrapy settings
    settings = get_project_settings()
    
    # Configure additional settings for this run
    settings.update({
        'USER_AGENT': 'PatternMaker/1.0 (+https://kohana-beads.com)',
        'DOWNLOAD_DELAY': 1.0,  # Be polite to the server
        'RANDOMIZE_DOWNLOAD_DELAY': 0.5,
        'COOKIES_ENABLED': True,
        'ROBOTSTXT_OBEY': True,
    })
    
    # Create and run the crawler
    process = CrawlerProcess(settings)
    process.crawl(FireMountainGemsSpider)
    process.start()
    
    logger.info("🎉 Fire Mountain Gems spider completed!")
    
    if s3_configured:
        logger.info("📤 Data has been uploaded to S3")
    else:
        logger.info("💾 Data saved locally only - configure S3 for cloud storage")

if __name__ == '__main__':
    main()
