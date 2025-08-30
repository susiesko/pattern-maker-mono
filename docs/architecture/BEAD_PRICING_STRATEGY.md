# Bead Pricing Data Acquisition Strategy

## Executive Summary

This document outlines comprehensive strategies for acquiring, processing, and maintaining pricing data for bead retailers. Based on analysis of the current Pattern Maker system and 2025 market research, we present multiple approaches from API integration to ethical web scraping.

## Current System Analysis

### Existing Crawler Capabilities
- **Fire Mountain Gems scraper**: Extracts product catalog data
- **Miyuki Directory scraper**: Captures product specifications
- **Missing**: Price extraction and monitoring functionality

### Key Retailers for Price Monitoring
1. **Fire Mountain Gems** - Major wholesale supplier
2. **Miyuki Direct** - Manufacturer pricing
3. **Lima Beads** - Competitive online retailer
4. **Shipwreck Beads** - Specialty supplier
5. **Artbeads.com** - Premium bead retailer

## Strategy 1: Official API Integration (Preferred)

### Google Shopping Content API
```python
# Implementation approach for Google Shopping API
import google.auth
from googleapiclient.discovery import build

class GoogleShoppingPriceMonitor:
    def __init__(self, merchant_id: str, credentials_path: str):
        self.merchant_id = merchant_id
        self.service = build('content', 'v2.1', 
                           credentials=self._load_credentials(credentials_path))
    
    def get_product_prices(self, product_ids: list) -> dict:
        """Fetch current pricing for specific products"""
        request = self.service.products().list(
            merchantId=self.merchant_id,
            pageSize=250
        )
        response = request.execute()
        return self._parse_pricing_data(response)
    
    def monitor_price_changes(self, comparison_shopping_service_id: str):
        """Monitor competitive pricing through CSS reports"""
        request = self.service.reports().search(
            merchantId=self.merchant_id,
            reportRequest={
                'reportType': 'PRICE_COMPETITIVENESS_PRODUCT_VIEW',
                'aggregationPeriod': 'DAILY'
            }
        )
        return request.execute()
```

### Third-Party Price APIs
```python
# Using commercial price monitoring APIs
import requests

class PriceAPIMonitor:
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://api.prisync.com/v1"
    
    def track_product_price(self, product_url: str, retailer_name: str):
        """Add product to price monitoring"""
        payload = {
            "url": product_url,
            "name": f"Bead - {retailer_name}",
            "currency": "USD",
            "monitor_frequency": "daily"
        }
        response = requests.post(
            f"{self.base_url}/products",
            headers={"Authorization": f"Bearer {self.api_key}"},
            json=payload
        )
        return response.json()
```

## Strategy 2: Ethical Web Scraping (Fallback)

### Legal Compliance Framework
```python
# Enhanced scraper with legal compliance
import scrapy
from scrapy.downloadermiddlewares.robotstxt import RobotsTxtMiddleware
import time
import random

class EthicalPriceSpider(scrapy.Spider):
    name = 'ethical_price_spider'
    
    # Compliance settings
    custom_settings = {
        'ROBOTSTXT_OBEY': True,
        'DOWNLOAD_DELAY': 3,  # 3 seconds between requests
        'RANDOMIZE_DOWNLOAD_DELAY': 0.5,  # 50% randomization
        'CONCURRENT_REQUESTS': 1,  # Single threaded
        'CONCURRENT_REQUESTS_PER_DOMAIN': 1,
        'USER_AGENT': 'Pattern-Maker Price Monitor Bot (contact: admin@pattern-maker.com)',
        'AUTOTHROTTLE_ENABLED': True,
        'AUTOTHROTTLE_START_DELAY': 2,
        'AUTOTHROTTLE_MAX_DELAY': 10,
        'AUTOTHROTTLE_TARGET_CONCURRENCY': 1.0,
    }
    
    def start_requests(self):
        # Check robots.txt compliance first
        for url in self.start_urls:
            yield scrapy.Request(
                url,
                callback=self.parse_price_page,
                meta={'dont_cache': True}
            )
    
    def parse_price_page(self, response):
        """Extract pricing data with attribution"""
        price_data = {
            'product_code': response.css('.product-code::text').get(),
            'price': self._extract_price(response),
            'currency': 'USD',
            'availability': response.css('.stock-status::text').get(),
            'retailer': self.name,
            'source_url': response.url,
            'scraped_at': time.time(),
            'terms_compliance': self._check_terms_compliance(response.url)
        }
        yield price_data
    
    def _extract_price(self, response):
        """Robust price extraction with multiple selectors"""
        price_selectors = [
            '.price .amount::text',
            '.product-price-value::text', 
            '[data-price]::attr(data-price)',
            '.price-current::text'
        ]
        
        for selector in price_selectors:
            price = response.css(selector).get()
            if price:
                return self._clean_price(price)
        return None
    
    def _clean_price(self, price_text: str) -> float:
        """Convert price text to float"""
        import re
        price_match = re.search(r'\$?([0-9]+\.?[0-9]*)', price_text)
        return float(price_match.group(1)) if price_match else None
```

### Retailer-Specific Implementations

```python
# Fire Mountain Gems price scraper
class FireMountainPriceSpider(EthicalPriceSpider):
    name = 'fire_mountain_prices'
    start_urls = ['https://www.firemountaingems.com/beads/beads-by-brand/miyuki/']
    
    def parse_price_page(self, response):
        products = response.css('.product-item')
        for product in products:
            yield {
                'retailer': 'Fire Mountain Gems',
                'product_code': product.css('.product-code::text').get(),
                'name': product.css('.product-name::text').get(),
                'price': self._extract_price(product),
                'bulk_prices': self._extract_bulk_pricing(product),
                'wholesale_price': self._extract_wholesale_price(product),
                'source_url': response.urljoin(product.css('a::attr(href)').get()),
                'scraped_at': time.time()
            }

# Lima Beads price scraper  
class LimaBeadsPriceSpider(EthicalPriceSpider):
    name = 'lima_beads_prices'
    start_urls = ['https://www.limabeads.com/']
    
    def parse_price_page(self, response):
        # Implementation specific to Lima Beads structure
        pass
```

## Strategy 3: Partnership & Data Exchange

### Wholesale Account Integration
```python
# Direct wholesale account data integration
class WholesaleAccountIntegration:
    def __init__(self, retailer_config: dict):
        self.retailer = retailer_config['name']
        self.account_credentials = retailer_config['credentials']
        self.pricing_tier = retailer_config['tier']
    
    def fetch_wholesale_pricing(self) -> dict:
        """Fetch pricing from wholesale account portal"""
        # Many wholesalers provide CSV exports or account dashboards
        # This would require partnership agreements
        pass
    
    def sync_inventory_levels(self):
        """Sync available inventory from wholesale accounts"""
        pass
```

### Manufacturer Direct Integration
```python
# Miyuki manufacturer price feed integration
class MiyukiPriceFeed:
    def __init__(self, dealer_credentials: dict):
        self.dealer_id = dealer_credentials['dealer_id']
        self.api_key = dealer_credentials['api_key']
    
    def get_official_pricing(self, product_codes: list):
        """Get manufacturer pricing for authorized dealers"""
        # Requires dealer account with Miyuki
        pass
```

## Strategy 4: Hybrid Price Aggregation System

### Architecture Design
```python
# Comprehensive pricing system architecture
from dataclasses import dataclass
from typing import List, Optional
import asyncio
import aiohttp

@dataclass
class PricePoint:
    retailer: str
    product_code: str
    price: float
    currency: str = "USD"
    availability: str = "in_stock"
    quantity_breaks: Optional[dict] = None
    wholesale_price: Optional[float] = None
    scraped_at: float = 0
    source_url: str = ""

class PriceAggregationEngine:
    def __init__(self):
        self.scrapers = {}
        self.api_monitors = {}
        self.price_cache = {}
    
    def register_price_source(self, name: str, source_type: str, config: dict):
        """Register a new pricing data source"""
        if source_type == 'api':
            self.api_monitors[name] = self._create_api_monitor(config)
        elif source_type == 'scraper':
            self.scrapers[name] = self._create_scraper(config)
    
    async def collect_all_prices(self, product_codes: List[str]) -> List[PricePoint]:
        """Aggregate prices from all sources"""
        tasks = []
        
        # API sources (faster, more reliable)
        for name, monitor in self.api_monitors.items():
            tasks.append(monitor.get_prices(product_codes))
        
        # Scraping sources (slower, needs rate limiting)
        for name, scraper in self.scrapers.items():
            tasks.append(scraper.scrape_prices(product_codes))
        
        results = await asyncio.gather(*tasks, return_exceptions=True)
        return self._merge_price_data(results)
    
    def _merge_price_data(self, price_results: List[List[PricePoint]]) -> List[PricePoint]:
        """Merge and deduplicate price data from multiple sources"""
        all_prices = []
        for result_list in price_results:
            if isinstance(result_list, list):
                all_prices.extend(result_list)
        
        # Group by product_code and retailer
        grouped_prices = {}
        for price in all_prices:
            key = f"{price.product_code}_{price.retailer}"
            if key not in grouped_prices or price.scraped_at > grouped_prices[key].scraped_at:
                grouped_prices[key] = price
        
        return list(grouped_prices.values())
```

### Database Schema for Pricing
```sql
-- Add pricing tables to existing schema
CREATE TABLE bead_prices (
    id BIGSERIAL PRIMARY KEY,
    bead_id BIGINT NOT NULL REFERENCES beads(id),
    retailer_name VARCHAR(100) NOT NULL,
    price_cents INTEGER NOT NULL, -- Store as cents for precision
    currency CHAR(3) DEFAULT 'USD',
    availability VARCHAR(50) DEFAULT 'in_stock',
    wholesale_price_cents INTEGER,
    quantity_breaks JSONB, -- Store bulk pricing tiers
    source_url TEXT,
    scraped_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT unique_bead_retailer_price UNIQUE(bead_id, retailer_name, scraped_at::date)
);

CREATE INDEX idx_bead_prices_current ON bead_prices(bead_id, retailer_name, scraped_at DESC);
CREATE INDEX idx_bead_prices_lookup ON bead_prices(bead_id) WHERE scraped_at > NOW() - INTERVAL '7 days';

-- Price history tracking
CREATE TABLE price_alerts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    bead_id BIGINT NOT NULL REFERENCES beads(id),
    target_price_cents INTEGER NOT NULL,
    retailer_filter TEXT[], -- Array of preferred retailers
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## Implementation Roadmap

### Phase 1: Foundation (2 weeks)
1. **Legal compliance audit** - Review retailer ToS and robots.txt
2. **Rate limiting implementation** - Respectful crawling delays
3. **Database schema** - Add pricing tables and indexes
4. **Basic price API** - CRUD operations for price data

### Phase 2: Data Collection (4 weeks)
1. **Enhanced scrapers** - Add price extraction to existing crawlers
2. **API integration** - Implement Google Shopping API if applicable
3. **Quality assurance** - Price validation and anomaly detection
4. **Monitoring system** - Track scraper health and compliance

### Phase 3: Intelligence (4 weeks)
1. **Price analytics** - Historical trends and comparisons
2. **Alert system** - Price drop notifications
3. **Bulk pricing tiers** - Wholesale vs retail pricing
4. **API endpoints** - Expose pricing data to frontend

### Phase 4: Advanced Features (6 weeks)
1. **Price prediction** - ML models for trend forecasting
2. **Dynamic pricing** - Competitive pricing recommendations
3. **Wholesale optimization** - Best bulk purchase suggestions
4. **Integration APIs** - External pricing feeds

## JSON Feed Specification

### Pricing Data Feed Format
```json
{
  "meta": {
    "generated_at": "2025-08-30T16:30:00Z",
    "version": "1.0",
    "total_products": 1247,
    "total_retailers": 5,
    "currency": "USD"
  },
  "pricing_data": [
    {
      "product_code": "DB-0001",
      "name": "Miyuki Delica 11/0 Opaque Black",
      "brand": "Miyuki",
      "category": "seed_beads",
      "current_prices": [
        {
          "retailer": "Fire Mountain Gems",
          "price": 4.95,
          "wholesale_price": 3.71,
          "availability": "in_stock",
          "quantity_breaks": {
            "1-9": 4.95,
            "10-24": 4.45,
            "25+": 3.95
          },
          "last_updated": "2025-08-30T15:45:00Z",
          "source_url": "https://www.firemountaingems.com/..."
        },
        {
          "retailer": "Lima Beads",
          "price": 5.25,
          "availability": "low_stock",
          "last_updated": "2025-08-30T14:20:00Z"
        }
      ],
      "price_analytics": {
        "lowest_price": 4.95,
        "highest_price": 5.25,
        "average_price": 5.10,
        "price_trend_7d": "stable",
        "price_change_percent": 0.0
      }
    }
  ],
  "retailer_info": [
    {
      "name": "Fire Mountain Gems",
      "website": "https://www.firemountaingems.com",
      "wholesale_available": true,
      "shipping_info": {
        "free_shipping_threshold": 149.00,
        "standard_shipping": 8.99
      },
      "last_scraped": "2025-08-30T15:45:00Z",
      "compliance_status": "robots_txt_compliant"
    }
  ]
}
```

### API Endpoints for Pricing Data
```ruby
# Rails API endpoints for pricing functionality
class Api::V1::PricingController < Api::V1::BaseController
  # GET /api/v1/pricing/beads/:id
  def show
    bead = Catalog::Bead.find(params[:id])
    prices = bead.current_prices.includes(:retailer)
    
    render json: {
      bead: BeadSerializer.new(bead),
      pricing: prices.map { |p| PriceSerializer.new(p) },
      analytics: PriceAnalyticsService.new(bead).calculate
    }
  end
  
  # GET /api/v1/pricing/feed
  def feed
    # Generate complete pricing feed
    feed_data = PriceFeedService.new(
      retailers: params[:retailers],
      updated_since: params[:since]
    ).generate
    
    render json: feed_data
  end
  
  # POST /api/v1/pricing/alerts
  def create_alert
    alert = current_user.price_alerts.build(alert_params)
    
    if alert.save
      PriceAlertService.new(alert).activate
      render json: { success: true, alert_id: alert.id }
    else
      render json: { errors: alert.errors }, status: :unprocessable_entity
    end
  end
  
  private
  
  def alert_params
    params.require(:alert).permit(:bead_id, :target_price_cents, retailer_filter: [])
  end
end
```

## Risk Assessment & Mitigation

### Legal Risks
- **Terms of Service violations** - Monitor retailer ToS changes
- **IP blocking** - Implement proxy rotation if needed
- **Rate limiting violations** - Respect server resources

### Technical Risks
- **Website structure changes** - Implement robust selectors
- **Anti-bot measures** - Use residential proxies if needed
- **Data quality issues** - Implement validation and anomaly detection

### Mitigation Strategies
```python
# Robust scraping with failure handling
class ResilientPriceScraper:
    def __init__(self, retailer_config: dict):
        self.config = retailer_config
        self.failure_count = 0
        self.max_failures = 3
    
    async def scrape_with_fallback(self, product_url: str):
        """Scrape with multiple fallback strategies"""
        strategies = [
            self._scrape_standard,
            self._scrape_with_delay,
            self._scrape_with_proxy
        ]
        
        for strategy in strategies:
            try:
                result = await strategy(product_url)
                if result:
                    self.failure_count = 0
                    return result
            except Exception as e:
                self.failure_count += 1
                logger.warning(f"Strategy failed: {strategy.__name__}, error: {e}")
                
                if self.failure_count >= self.max_failures:
                    await self._notify_admin_intervention_needed()
                    break
        
        return None
```

## Cost-Benefit Analysis

### Development Costs
- **Phase 1**: 40 hours ($4,000-8,000)
- **Phase 2**: 80 hours ($8,000-16,000)  
- **Phase 3**: 80 hours ($8,000-16,000)
- **Phase 4**: 120 hours ($12,000-24,000)
- **Total**: $32,000-64,000 depending on complexity

### Operational Costs
- **API services**: $50-200/month (Google Shopping, Prisync, etc.)
- **Proxy services**: $100-300/month (if needed for scraping)
- **Infrastructure**: $50-150/month (additional compute, storage)
- **Legal compliance**: $2,000-5,000 (ToS review, compliance audit)

### Business Value
- **Competitive advantage** - Real-time price comparison
- **Customer value** - Best price discovery
- **Inventory optimization** - Data-driven purchasing decisions
- **Revenue opportunity** - Affiliate commission from price comparisons

## Recommended Implementation Approach

### Immediate Next Steps (Week 1)
1. **Legal review** - Audit retailer Terms of Service
2. **Pilot implementation** - Single retailer price monitoring
3. **Database schema** - Add pricing tables to existing schema
4. **Basic API** - Price CRUD operations

### MVP Features (Month 1)
1. **Price monitoring** for top 3 retailers
2. **Simple price alerts** via email
3. **Basic price history** tracking
4. **JSON feed endpoint** for external consumption

### Advanced Features (Months 2-3)
1. **Price analytics** and trend prediction
2. **Bulk pricing optimization** recommendations
3. **Real-time alerts** and notifications
4. **Comprehensive price comparison** interface

This strategy provides multiple pathways for price data acquisition while maintaining legal compliance and technical robustness. The modular approach allows for gradual implementation and risk mitigation.