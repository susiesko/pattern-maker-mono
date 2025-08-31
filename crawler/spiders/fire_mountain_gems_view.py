"""
Fire Mountain Gems Spider - Simple JSON Export
Crawls Miyuki Delica beads and saves them to a JSON file for Rails import
"""

import re
import json
import logging
import os
from datetime import datetime
from urllib.parse import urljoin
from scrapy import Spider, Request
from typing import Dict, Any, Optional
from pathlib import Path

try:
    import boto3
    from botocore.exceptions import ClientError, NoCredentialsError
    S3_AVAILABLE = True
except ImportError:
    S3_AVAILABLE = False
    logging.warning("boto3 not installed - S3 upload will be skipped")

logger = logging.getLogger(__name__)


class FireMountainGemsSpider(Spider):
    """Simple spider that crawls and saves to JSON"""
    
    name = 'fire_mountain_gems'
    allowed_domains = ['firemountaingems.com']
    start_urls = ['https://www.firemountaingems.com/beads/beads-by-brand/miyuki/']
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.beads_found = []
        self.total_count = 0
        self.output_file = Path('beads.json')
    
    def parse(self, response):
        """Parse the main Miyuki Delica page"""
        logger.info(f"Parsing page: {response.url}")
        
        product_items = response.css('.product-tile')
        logger.info(f"Found {len(product_items)} products on page")
        
        for item in product_items:
            bead_data = self._parse_product(item, response)
            if bead_data:
                self.beads_found.append(bead_data)
                self.total_count += 1
                logger.info(f"Found bead #{self.total_count}: {bead_data['name']} ({bead_data['product_code']}) - Size: {bead_data['size']}")
        
        # Follow pagination
        yield from self._follow_pagination(response)
    
    def _parse_product(self, item, response) -> Optional[Dict[str, Any]]:
        """Parse individual product item"""
        try:
            # Extract basic product info
            product_link = item.css('.link::attr(href)').get()
            if not product_link:
                return None
            
            product_url = urljoin(response.url, product_link)
            product_name = self._extract_product_name(item)
            
            # Extract and validate product code
            product_code = self._extract_product_code(product_name)
            if not product_code:
                logger.debug(f"Skipping non-delicas: {product_name}")
                return None
            
            # Get image URL
            image_url = self._extract_image_url(item, response)
            
            return {
                'name': product_name,
                'product_code': product_code,
                'brand': 'Miyuki',
                'type': 'Delica',
                'size': self._get_product_size(product_code),
                'image_url': image_url,
                'source_url': product_url,
            }
            
        except Exception as e:
            logger.error(f"Error parsing product: {e}")
            return None
    
    def _extract_product_name(self, item) -> str:
        """Extract and clean product name"""
        product_name = item.css('h3.name::text').get()
        if product_name:
            return product_name.strip().replace('\nProduct Title', '')
        return ""
    
    def _extract_product_code(self, product_name: str) -> Optional[str]:
        """Extract product code from product name"""
        patterns = [
            r'DB-?(\d+)',
            r'DBS-?(\d+)',
            r'DBM-?(\d+)',
            r'DBL-?(\d+)'
        ]
        
        for pattern in patterns:
            match = re.search(pattern, product_name)
            if match:
                full_match = match.group(0)
                prefix_match = re.search(r'DB-|DBS-|DBM-|DBL-', full_match)
                if prefix_match:
                    prefix = prefix_match.group(0)
                    return f"{prefix}{match.group(1)}"
                return full_match
        
        return None
    
    def _extract_image_url(self, item, response) -> Optional[str]:
        """Extract image URL from product item"""
        image_url = item.css('img.tile-image::attr(src)').get()
        if image_url:
            return urljoin(response.url, image_url)
        return None
    
    def _get_product_size(self, product_code: str) -> str:
        """Determine product size based on product code prefix"""
        size_mapping = {
            'DBS-': '15/0',
            'DB-': '11/0',
            'DBM-': '10/0',
            'DBL-': '8/0'
        }
        
        for prefix, size in size_mapping.items():
            if product_code.startswith(prefix):
                return size
        
        return 'Unknown'
    
    def _follow_pagination(self, response):
        """Follow pagination links"""
        next_page = response.css('a.page-link-next::attr(href)').get()
        if next_page:
            next_page_url = urljoin(response.url, next_page)
            logger.info(f"Following next page: {next_page_url}")
            yield Request(next_page_url, callback=self.parse)
    
    def _save_to_json(self):
        """Save beads data to JSON file and upload to S3"""
        try:
            # Prepare data with metadata
            timestamp = datetime.now().isoformat()
            output_data = {
                'metadata': {
                    'spider': self.name,
                    'scraped_at': timestamp,
                    'total_results': len(self.beads_found),
                    'source': 'Fire Mountain Gems'
                },
                'beads': self.beads_found
            }
            
            # Save locally
            with open(self.output_file, 'w') as f:
                json.dump(output_data, f, indent=2)
            logger.info(f"Saved {len(self.beads_found)} beads to {self.output_file}")
            
            # Upload to S3 if configured
            self._upload_to_s3()
            
        except Exception as e:
            logger.error(f"Error saving to JSON: {e}")
    
    def _upload_to_s3(self):
        """Upload the JSON file to S3"""
        if not S3_AVAILABLE:
            logger.info("Skipping S3 upload - boto3 not available")
            return
            
        # Check for required environment variables
        bucket_name = os.environ.get('AWS_S3_BUCKET')
        access_key = os.environ.get('AWS_ACCESS_KEY_ID')
        secret_key = os.environ.get('AWS_SECRET_ACCESS_KEY')
        region = os.environ.get('AWS_REGION', 'us-east-1')
        
        if not all([bucket_name, access_key, secret_key]):
            logger.warning("Skipping S3 upload - missing AWS credentials or bucket name")
            logger.info("Required env vars: AWS_S3_BUCKET, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY")
            return
        
        try:
            # Create S3 client
            s3_client = boto3.client(
                's3',
                region_name=region,
                aws_access_key_id=access_key,
                aws_secret_access_key=secret_key
            )
            
            # Create timestamped S3 key
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            site_name = 'firemountaingems.com'
            s3_key = f"beads/{site_name}/feed-{timestamp}.json"
            
            # Upload file
            with open(self.output_file, 'rb') as f:
                s3_client.put_object(
                    Bucket=bucket_name,
                    Key=s3_key,
                    Body=f,
                    ContentType='application/json',
                    Metadata={
                        'spider': self.name,
                        'scraped_at': datetime.now().isoformat(),
                        'total_beads': str(len(self.beads_found))
                    }
                )
            
            logger.info(f"Successfully uploaded to s3://{bucket_name}/{s3_key}")
            
        except NoCredentialsError:
            logger.error("AWS credentials not found")
        except ClientError as e:
            logger.error(f"AWS S3 error: {e}")
        except Exception as e:
            logger.error(f"Unexpected error uploading to S3: {e}")
    
    def _display_summary(self):
        """Display summary of all beads found"""
        logger.info(f"SUMMARY: Found {len(self.beads_found)} beads")
        
        # Group by size
        sizes = {}
        for bead in self.beads_found:
            size = bead['size']
            if size not in sizes:
                sizes[size] = []
            sizes[size].append(bead)
        
        for size, beads in sizes.items():
            logger.info(f"\nSize {size}: {len(beads)} beads")
            for bead in beads[:5]:  # Show first 5 of each size
                logger.info(f"  - {bead['name']} ({bead['product_code']})")
            if len(beads) > 5:
                logger.info(f"  ... and {len(beads) - 5} more")
    
    def closed(self, reason):
        """Called when spider is closed"""
        self._save_to_json()
        self._display_summary()
        logger.info(f"Spider closed: {reason}") 