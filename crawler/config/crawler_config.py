"""
Configuration settings for the crawler
"""

import os
from typing import Dict, Any

# Database Configuration
DATABASE_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': os.getenv('DB_PORT', '5432'),
    'name': os.getenv('DB_NAME', 'pattern_maker_development'),
    'user': os.getenv('DB_USER', 'postgres'),
    'password': os.getenv('DB_PASSWORD', '')
}

# API Configuration
API_CONFIG = {
    'base_url': os.getenv('API_BASE_URL', 'http://localhost:3000'),
    'token': os.getenv('API_TOKEN', '')
}

# Crawler Configuration
CRAWLER_CONFIG = {
    'buffer_size': 100,  # Number of beads to process in each batch
    'download_delay': 1.0,  # Delay between requests in seconds
    'user_agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
}

# Spider Configuration
SPIDER_CONFIG = {
    'allowed_domains': ['firemountaingems.com'],
    'start_urls': ['https://www.firemountaingems.com/beads/beads-by-brand/miyuki/'],
    'product_selectors': {
        'tile': '.product-tile',
        'link': '.link::attr(href)',
        'name': 'h3.name::text',
        'image': 'img.tile-image::attr(src)',
        'next_page': 'a.page-link-next::attr(href)'
    },
    'product_code_patterns': [
        r'DB-?(\d+)',
        r'DBS-?(\d+)',
        r'DBM-?(\d+)',
        r'DBL-?(\d+)'
    ],
    'size_mapping': {
        'DBS-': '15/0',
        'DB-': '11/0',
        'DBM-': '10/0',
        'DBL-': '8/0'
    }
}

# Logging Configuration
LOGGING_CONFIG = {
    'level': 'INFO',
    'format': '%(asctime)s [%(name)s] %(levelname)s: %(message)s'
}

def get_database_url() -> str:
    """Build database connection URL from configuration"""
    config = DATABASE_CONFIG
    return f"postgresql://{config['user']}:{config['password']}@{config['host']}:{config['port']}/{config['name']}"

def get_config() -> Dict[str, Any]:
    """Get all configuration settings"""
    return {
        'database': DATABASE_CONFIG,
        'api': API_CONFIG,
        'crawler': CRAWLER_CONFIG,
        'spider': SPIDER_CONFIG,
        'logging': LOGGING_CONFIG
    } 