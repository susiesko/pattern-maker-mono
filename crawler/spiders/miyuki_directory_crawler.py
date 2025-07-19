"""
Fire Mountain Gems Spider - Simple JSON Export
Crawls Miyuki Delica beads and saves them to a JSON file for Rails import
"""

import re
import json
import logging
import os
import psycopg2
from urllib.parse import urljoin
from scrapy import Spider, Request
from typing import Dict, Any, Optional, Set
from pathlib import Path

logger = logging.getLogger(__name__)


class MiyukiDirectoryCrawler(Spider):
    """Simple spider that crawls and saves to JSON"""
    
    name = 'miyuki_directory'
    allowed_domains = ['miyuki-beads.co.jp']
    start_urls = ['https://www.miyuki-beads.co.jp/directory/']
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        
        self.total_count = 0
        self.duplicate_count = 0
        self.output_file = Path('data/beads.json')
        self.size_counts = {}
        self.existing_product_codes: Set[str] = set()
        self.pages_crawled = 0
        # max_pages comes from -a max_pages=N argument and gets set as self.max_pages automatically
        # Convert to int if provided, otherwise None (unlimited)
        if hasattr(self, 'max_pages') and self.max_pages is not None:
            self.max_pages = int(self.max_pages)
        else:
            self.max_pages = None

        # Open file for streaming JSON output
        self._json_file = None
        self._first_item = True
    
    def open_spider(self, spider):
        """Initialize JSON file for streaming output and load existing product codes"""
        # Skip database check for now - just create empty set
        self.existing_product_codes = set()
        logger.info("Skipping database duplicate check - will scrape all products")
        
        self._json_file = open(self.output_file, 'w')
        self._json_file.write('[\n')
        logger.info(f"Starting spider, streaming to {self.output_file}")
        logger.info(f"Found {len(self.existing_product_codes)} existing products in database")
    
    def _load_existing_product_codes(self):
        """Load existing product codes from database to avoid duplicates"""
        try:
            # Use same database config as Rails
            conn = psycopg2.connect(
                host=os.getenv('DATABASE_HOST', 'localhost'),
                port=int(os.getenv('DATABASE_PORT', '5432')),
                database='pattern_maker_development',  # Use Rails development DB
                user=os.getenv('DATABASE_USERNAME', ''),
                password=os.getenv('DATABASE_PASSWORD', '')
            )
            
            with conn.cursor() as cursor:
                cursor.execute("SELECT product_code FROM beads WHERE brand = 'Miyuki'")
                self.existing_product_codes = {row[0] for row in cursor.fetchall()}
            
            conn.close()
            logger.info(f"Loaded {len(self.existing_product_codes)} existing Miyuki product codes")
            
        except Exception as e:
            logger.warning(f"Could not load existing product codes: {e}")
            logger.info("Continuing without duplicate checking")
            self.existing_product_codes = set()

    def closed(self, reason):
        """Close JSON file and display summary"""
        if self._json_file:
            self._json_file.write('\n]')
            self._json_file.close()
            self._json_file = None
        self._display_summary()
        logger.info(f"Spider completed: {self.total_count} beads saved to {self.output_file}")
        logger.info(f"Spider closed with reason: {reason}")

    def __del__(self):
        """Destructor to ensure file is always closed"""
        if hasattr(self, '_json_file') and self._json_file:
            try:
                self._json_file.write('\n]')
                self._json_file.close()
            except:
                pass  # File might already be closed
    
    def parse(self, response):
        """Parse the main Miyuki Delica page"""
        logger.info(f"Parsing page: {response.url}")
        
        product_items = response.css('.product')
        logger.info(f"Found {len(product_items)} products on page")
        
        for item in product_items:
            bead_data = self._parse_product(item, response)
            if bead_data:
                # Instead of crawling the product page now, just show how to do it:
                yield Request(bead_data['source_url'], callback=self.parse_product_detail, meta={'bead_data': bead_data})
        
        # Follow pagination
        yield from self._follow_pagination(response)
    
    def _parse_product(self, item, response) -> Optional[Dict[str, Any]]:
        """Parse individual product item"""
        try:
            # Extract basic product info
            product_link = item.css('.woocommerce-LoopProduct-link::attr(href)').get()
            if not product_link:
                return None
            
            product_url = urljoin(response.url, product_link)
            product_name = self._extract_product_name(item)
            
            # Extract and validate product code
            product_code = self._extract_product_code(product_name)
            if not product_code:
                logger.debug(f"Skipping non-delicas: {product_name}")
                return None
            
            # Check for duplicates
            if product_code in self.existing_product_codes:
                logger.debug(f"Skipping duplicate product: {product_name} ({product_code})")
                self.duplicate_count += 1
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
        product_name = item.css('h2.woocommerce-loop-product__title::text').get()
        if product_name:
            return product_name.strip().replace('\nProduct Title', '')
        return ""
    
    def _extract_product_code(self, product_name: str) -> Optional[str]:
        """Extract product code from product name"""
        patterns = [
            r'(DB)(\d+)([A-Z]?)',
            r'(DBS)(\d+)([A-Z]?)',
            r'(DBM)(\d+)([A-Z]?)',
            r'(DBL)(\d+)([A-Z]?)'
        ]
        
        for pattern in patterns:
            match = re.search(pattern, product_name)
            if match:
                prefix = match.group(1)      # "DB", "DBS", etc.
                number = match.group(2)      # "123", "5", etc.
                suffix = match.group(3)      # "B", "C", or ""
                
                # Pad number to 4 digits
                padded_number = number.zfill(4)
                
                # Build the formatted code
                if suffix:
                    return f"{prefix}-{padded_number}-{suffix}"
                else:
                    return f"{prefix}-{padded_number}"
        
        return None
    
    def _extract_image_url(self, item, response) -> Optional[str]:
        """Extract image URL from product item"""
        image_url = item.css('img.attachment-woocommerce_thumbnail::attr(src)').get()
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
        self.pages_crawled += 1
        
        if self.max_pages is not None and self.pages_crawled >= self.max_pages:
            logger.info(f"Reached max pages limit ({self.max_pages}), stopping pagination")
            return
            
        next_page = response.css('a.next::attr(href)').get()
        if next_page:
            next_page_url = urljoin(response.url, next_page)
            logger.info(f"Following next page: {next_page_url}")
            yield Request(next_page_url, callback=self.parse)
    
    def _write_bead_to_json(self, bead_data):
        """Write a single bead to the JSON file"""
        # Ensure file is open (in case spider instance issues)
        if not self._json_file:
            self._json_file = open(self.output_file, 'w')
            self._json_file.write('[\n')
            self._first_item = True
            
        try:
            if not self._first_item:
                self._json_file.write(',\n')
            else:
                self._first_item = False
            
            json.dump(bead_data, self._json_file, indent=2)
            self._json_file.flush()  # Ensure data is written immediately
        except Exception as e:
            logger.error(f"Error writing bead to JSON: {e}")
    
    def _display_summary(self):
        """Display summary of all beads found"""
        logger.info(f"SUMMARY: Found {self.total_count} beads")
        logger.info(f"Skipped {self.duplicate_count} duplicate products")
        
        for size, count in self.size_counts.items():
            logger.info(f"Size {size}: {count} beads")
    
    def parse_product_detail(self, response):
        """Parse the product detail page to extract color and finish info"""
        bead_data = response.meta['bead_data']

        color = response.css(
            'tr.woocommerce-product-attributes-item--attribute_pa_color-group td.woocommerce-product-attributes-item__value p::text'
        ).get()
        finish = response.css(
            'tr.woocommerce-product-attributes-item--attribute_pa_finish td.woocommerce-product-attributes-item__value p::text'
        ).get()
        shape = response.css(
            'tr.woocommerce-product-attributes-item--attribute_pa_shape td.woocommerce-product-attributes-item__value p::text'
        ).get()
        size = response.css(
            'tr.woocommerce-product-attributes-item--attribute_pa_size td.woocommerce-product-attributes-item__value p::text'
        ).get()
        glass_group = response.css(
            'tr.woocommerce-product-attributes-item--attribute_pa_glass-group td.woocommerce-product-attributes-item__value p::text'
        ).get()
        dyed = response.css(
            'tr.woocommerce-product-attributes-item--attribute_pa_dyed td.woocommerce-product-attributes-item__value p::text'
        ).get()
        galvanized = response.css(
            'tr.woocommerce-product-attributes-item--attribute_pa_galva td.woocommerce-product-attributes-item__value p::text'
        ).get()
        plating = response.css(
            'tr.woocommerce-product-attributes-item--attribute_pa_plating td.woocommerce-product-attributes-item__value p::text'
        ).get()

        bead_data['color'] = color.strip() if color else None
        bead_data['finish'] = finish.strip() if finish else None
        bead_data['shape'] = shape.strip() if shape else None
        bead_data['size_detail'] = size.strip() if size else None
        bead_data['glass_group'] = glass_group.strip() if glass_group else None
        bead_data['dyed'] = dyed.strip() if dyed else None
        bead_data['galvanized'] = galvanized.strip() if galvanized else None
        bead_data['plating'] = plating.strip() if plating else None

        logger.info(
            f"Detailed bead #{self.total_count + 1}: {bead_data['name']} ({bead_data['product_code']}) - "
            f"Color: {bead_data['color']}, Finish: {bead_data['finish']}, "
            f"Shape: {bead_data['shape']}, Size: {bead_data['size_detail']}, Glass Group: {bead_data['glass_group']}, Dyed: {bead_data['dyed']}, Galvanized: {bead_data['galvanized']}, Plating: {bead_data['plating']}"
        )

        self.total_count += 1
        self.size_counts[bead_data['size']] = self.size_counts.get(bead_data['size'], 0) + 1
        self._write_bead_to_json(bead_data) 