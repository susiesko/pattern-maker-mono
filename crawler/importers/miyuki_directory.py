#!/usr/bin/env python3
"""
Miyuki Directory Importer
Reads JSON data from the Miyuki crawler and imports it directly to the Rails database
"""

import json
import logging
import os
import psycopg2
from pathlib import Path
from typing import List, Dict, Any, Set
from datetime import datetime

logger = logging.getLogger(__name__)

class MiyukiDirectoryImporter:
    """Imports Miyuki bead data from JSON to Rails database"""
    
    def __init__(self, json_file_path: str = "data/miyuki_directory_beads.json"):
        self.json_file_path = Path(json_file_path)
        self.db_connection = None
        self.existing_product_codes: Set[str] = set()
        
    def connect_to_database(self):
        """Connect to the Rails database"""
        try:
            self.db_connection = psycopg2.connect(
                host=os.getenv('DATABASE_HOST', 'localhost'),
                port=int(os.getenv('DATABASE_PORT', '5432')),
                database='pattern_maker_development',  # Use Rails development DB
                user=os.getenv('DATABASE_USERNAME', ''),
                password=os.getenv('DATABASE_PASSWORD', '')
            )
            logger.info("✅ Connected to database successfully")
        except Exception as e:
            logger.error(f"❌ Failed to connect to database: {e}")
            raise
    
    def open_spider_simplified(self):
        """Initialize database connection (no need to pre-load existing codes)"""
        self.connect_to_database()
        logger.info(f"Starting spider, will use ON CONFLICT DO NOTHING for duplicates")
    
    def load_existing_product_codes(self):
        """Load existing product codes from database to avoid duplicates"""
        # NOTE: This method is now optional since we use ON CONFLICT DO NOTHING
        # Keeping it for compatibility but it's not required anymore
        if not self.db_connection:
            logger.warning("⚠️  No database connection available")
            return
            
        try:
            with self.db_connection.cursor() as cursor:
                cursor.execute("SELECT brand_product_code FROM beads WHERE brand_id = 1")  # Changed from brand = 'Miyuki'
                self.existing_product_codes = {row[0] for row in cursor.fetchall()}
            
            logger.info(f"📊 Loaded {len(self.existing_product_codes)} existing Miyuki product codes (for reporting only)")
            
        except Exception as e:
            logger.warning(f"⚠️  Could not load existing product codes: {e}")
            self.existing_product_codes = set()
    
    def load_json_data(self) -> List[Dict[str, Any]]:
        """Load bead data from JSON file"""
        if not self.json_file_path.exists():
            raise FileNotFoundError(f"JSON file not found: {self.json_file_path}")
            
        logger.info(f"📖 Loading data from {self.json_file_path}")
        
        with open(self.json_file_path, 'r', encoding='utf-8') as f:
            beads = json.load(f)
            
        logger.info(f"📊 Loaded {len(beads)} beads from JSON")
        return beads
    
    def check_database_schema(self):
        """Check if the required table and columns exist"""
        if not self.db_connection:
            logger.error("⚠️  No database connection for schema check")
            return False
            
        try:
            with self.db_connection.cursor() as cursor:
                # Check if beads table exists
                cursor.execute("""
                    SELECT EXISTS (
                        SELECT FROM information_schema.tables 
                        WHERE table_schema = 'public' 
                        AND table_name = 'beads'
                    )
                """)
                result = cursor.fetchone()
                table_exists = result[0] if result else False
                
                if not table_exists:
                    logger.error("❌ Table 'beads' does not exist!")
                    return False
                
                # Check if required columns exist
                cursor.execute("""
                    SELECT column_name 
                    FROM information_schema.columns 
                    WHERE table_name = 'beads' 
                    AND table_schema = 'public'
                """)
                columns = [row[0] for row in cursor.fetchall()]
                
                required_columns = [
                    'brand_product_code', 'name', 'brand_id', 'shape', 'size',
                    'color_group', 'glass_group', 'finish', 'dyed',
                    'galvanized', 'plating', 'created_at', 'updated_at'
                ]
                
                missing_columns = [col for col in required_columns if col not in columns]
                
                if missing_columns:
                    logger.error(f"❌ Missing columns in beads table: {missing_columns}")
                    logger.info(f"📋 Available columns: {columns}")
                    return False
                
                logger.info("✅ Database schema check passed")
                return True
                
        except Exception as e:
            logger.error(f"❌ Schema check failed: {e}")
            return False

    def bulk_import_beads(self) -> Dict[str, int]:
        """Main import method - bulk import all beads"""
        logger.info("🚀 Starting Miyuki Directory import...")
        
        # Check database schema first
        if not self.check_database_schema():
            raise RuntimeError("Database schema check failed - cannot proceed with import")
        
        # Load data from JSON
        beads = self.load_json_data()
        
        if not beads:
            logger.warning("⚠️  No beads found in JSON file")
            return {'imported_count': 0, 'total_count': 0, 'duplicate_count': 0}
        
        # Filter out beads with missing product codes
        valid_beads = []
        for bead in beads:
            product_code = bead.get('product_code')
            if not product_code:
                logger.warning("⚠️  Bead missing product_code, skipping")
                continue
            valid_beads.append(bead)
        
        if not valid_beads:
            logger.info("❌ No valid beads found (all missing product codes)")
            return {'imported_count': 0, 'total_count': len(beads), 'duplicate_count': 0}
        
        logger.info(f"📈 Attempting to import {len(valid_beads)} beads (duplicates will be ignored)")
        
        # Bulk insert using execute_values with ON CONFLICT DO NOTHING
        if not self.db_connection:
            logger.error("⚠️  Database connection not available")
            raise RuntimeError("No database connection")
            
        try:
            from psycopg2.extras import execute_values
            
            with self.db_connection.cursor() as cursor:
                # Prepare data tuples for bulk insert
                insert_data = [
                    (
                        bead.get('product_code'),  # brand_product_code
                        bead.get('name'),
                        1,  # brand_id (assuming Miyuki brand has ID 1)
                        bead.get('shape'),
                        bead.get('size'),
                        bead.get('color'),  # Map 'color' to 'color_group'
                        bead.get('glass_group'),
                        bead.get('finish'),
                        bead.get('dyed'),
                        bead.get('galvanized'),
                        bead.get('plating')
                    )
                    for bead in valid_beads
                ]
                
                # Count existing beads before insert (using brand_id instead of brand name)
                try:
                    cursor.execute("SELECT COUNT(*) FROM beads WHERE brand_id = 1")  # Assuming Miyuki brand_id = 1
                    result_before = cursor.fetchone()
                    count_before = result_before[0] if result_before else 0
                    logger.info(f"📊 Found {count_before} existing Miyuki beads")
                except Exception as e:
                    logger.warning(f"⚠️  Could not count existing beads: {e}")
                    count_before = 0
                
                # Bulk insert with ON CONFLICT DO NOTHING
                execute_values(
                    cursor,
                    """
                    INSERT INTO beads (
                        brand_product_code, name, brand_id, shape, size, 
                        color_group, glass_group, finish, dyed, 
                        galvanized, plating, created_at, updated_at
                    ) VALUES %s
                    ON CONFLICT (brand_product_code) DO NOTHING
                    """,
                    insert_data,
                    template="(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW(), NOW())"
                )
                
                # Count existing beads after insert
                try:
                    cursor.execute("SELECT COUNT(*) FROM beads WHERE brand_id = 1") # Changed from brand = 'Miyuki' to brand_id = 1
                    result_after = cursor.fetchone()
                    count_after = result_after[0] if result_after else 0
                except Exception as e:
                    logger.warning(f"⚠️  Could not count beads after insert: {e}")
                    count_after = count_before  # Fallback
                
                imported_count = count_after - count_before
                duplicate_count = len(valid_beads) - imported_count
                
            # Commit all changes
            self.db_connection.commit()
            logger.info(f"💾 Bulk insert completed!")
            logger.info(f"✅ New beads imported: {imported_count}")
            logger.info(f"🔄 Duplicates ignored: {duplicate_count}")
            
            return {
                'imported_count': imported_count,
                'total_count': len(beads),
                'duplicate_count': duplicate_count
            }
            
        except Exception as e:
            logger.error(f"❌ Bulk insert failed: {e}")
            try:
                self.db_connection.rollback()
                logger.info("🔄 Transaction rolled back")
            except Exception as rollback_error:
                logger.error(f"❌ Rollback failed: {rollback_error}")
            raise
    
    def rename_json_with_timestamp(self):
        """Rename the JSON file with a timestamp when processing is complete"""
        if not self.json_file_path.exists():
            logger.warning(f"⚠️  JSON file {self.json_file_path} not found for renaming")
            return
            
        # Create timestamp in format: YYYYMMDD_HHMMSS
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Create new filename: original_name_timestamp.json
        original_stem = self.json_file_path.stem  # filename without extension
        original_suffix = self.json_file_path.suffix  # .json
        new_filename = f"{original_stem}_{timestamp}{original_suffix}"
        new_path = self.json_file_path.parent / new_filename
        
        try:
            self.json_file_path.rename(new_path)
            logger.info(f"📁 Renamed JSON file: {self.json_file_path.name} → {new_filename}")
        except Exception as e:
            logger.error(f"❌ Failed to rename JSON file: {e}")

    def close_connection(self):
        """Close database connection"""
        if self.db_connection:
            self.db_connection.close()
            logger.info("🔌 Database connection closed")

def main():
    """Main function to run the importer"""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s [%(name)s] %(levelname)s: %(message)s'
    )
    
    importer = MiyukiDirectoryImporter()
    
    try:
        # Connect and load existing data
        importer.connect_to_database()
        importer.load_existing_product_codes()
        
        # Import beads
        result = importer.bulk_import_beads()
        
        # Rename JSON file
        importer.rename_json_with_timestamp()
        
        logger.info(f"🎉 Import completed!")
        logger.info(f"📊 Total beads in file: {result['total_count']}")
        logger.info(f"✅ New beads imported: {result['imported_count']}")
        logger.info(f"🔄 Duplicates skipped: {result['duplicate_count']}")
        
    except Exception as e:
        logger.error(f"💥 Import failed: {e}")
        raise
    finally:
        importer.close_connection()

if __name__ == '__main__':
    main() 