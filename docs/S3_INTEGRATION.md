# S3 Integration for Scraped Data Storage

This document explains how to set up and use S3 storage for your scraped bead data.

## Overview

The Fire Mountain Gems spider has been enhanced to automatically upload scraped data to AWS S3 after saving it locally. This provides:

- **Cloud backup** of your scraped data
- **Timestamped organization** with automatic folder structure
- **Metadata tagging** for easy identification
- **Fallback to local-only** if S3 is not configured

## Setup Instructions

### 1. Install Python Dependencies

Make sure boto3 is installed in your Python environment:

```bash
cd crawler
pip install -r requirements.txt
```

### 2. Configure AWS Credentials

#### Option A: Environment File (Recommended for Development)
1. Copy the example `.env` file:
   ```bash
   cp .env .env.local
   ```

2. Edit `.env` with your actual AWS credentials:
   ```bash
   AWS_ACCESS_KEY_ID=your_actual_access_key
   AWS_SECRET_ACCESS_KEY=your_actual_secret_key
   AWS_S3_BUCKET=your-bucket-name
   AWS_REGION=us-east-1
   ```

#### Option B: Environment Variables
Set these environment variables in your shell:
```bash
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_S3_BUCKET=your_bucket_name
export AWS_REGION=us-east-1  # Optional, defaults to us-east-1
```

#### Option C: AWS CLI Configuration
If you have AWS CLI installed, you can use:
```bash
aws configure
```

### 3. Create S3 Bucket

Make sure your S3 bucket exists and you have write permissions:

```bash
# Create bucket (if it doesn't exist)
aws s3 mb s3://your-bucket-name --region us-east-1

# Verify permissions
aws s3 ls s3://your-bucket-name
```

## Usage

### Running the Spider

Use the enhanced runner script:

```bash
cd crawler
python run_fire_mountain_gems.py
```

The script will:
1. ✅ Check S3 configuration
2. 🕷️ Run the spider and scrape data
3. 💾 Save data locally to `beads.json`
4. 📤 Upload to S3 (if configured)
5. 📋 Display summary and results

### S3 File Organization

Files are automatically organized in S3 with this structure:

```
s3://your-bucket/
└── scraped-data/
    └── miyuki_directory/
        └── feed-{timestamp}.json # HHMMSS timestamp
```

### Data Format

The uploaded JSON includes metadata:

```json
{
  "metadata": {
    "spider": "fire_mountain_gems",
    "scraped_at": "2025-01-31T14:30:22.123456",
    "total_results": 245,
    "source": "Fire Mountain Gems"
  },
  "beads": [
    {
      "name": "DB-0001 Miyuki Delica...",
      "product_code": "DB-0001",
      "brand": "Miyuki",
      "type": "Delica",
      "size": "11/0",
      "image_url": "https://...",
      "source_url": "https://..."
    }
  ]
}
```

## Troubleshooting

### Common Issues

1. **"AWS credentials not found"**
   - Check your `.env` file has correct values
   - Verify environment variables are set
   - Try `aws configure list` to check AWS CLI setup

2. **"Access Denied" errors**
   - Verify your AWS user has S3 write permissions
   - Check bucket policy allows your user
   - Ensure bucket exists in the correct region

3. **"Skipping S3 upload - boto3 not available"**
   - Install boto3: `pip install boto3>=1.35.0`
   - Check `requirements.txt` includes boto3

4. **"Bucket does not exist"**
   - Create the bucket: `aws s3 mb s3://your-bucket-name`
   - Check bucket name is correct in configuration

### Verification

To verify S3 upload worked:

```bash
# List recent uploads
aws s3 ls s3://your-bucket-name/scraped-data/fire_mountain_gems/ --recursive

# Download a file to check contents
aws s3 cp s3://your-bucket-name/scraped-data/fire_mountain_gems/2025/01/31/143022/beads.json ./downloaded.json
```

## Rails Integration

The Rails S3StorageService is also available for Ruby-based operations:

```ruby
# In Rails console
success = S3StorageService.upload_scraped_data(
  '/path/to/local/beads.json', 
  'fire_mountain_gems'
)

# Check configuration
S3StorageService.configured?
```

## Security Notes

- Never commit real AWS credentials to version control
- Use IAM users with minimal required permissions
- Consider using AWS IAM roles in production
- Rotate access keys regularly
- Use separate buckets for different environments (dev/staging/prod)

## Cost Considerations

- S3 storage costs are typically very low for JSON files
- PUT requests have minimal cost
- Consider lifecycle policies to archive old data
- Use S3 Standard-IA for infrequently accessed data

## Next Steps

1. Set up your AWS credentials and bucket
2. Run a test crawl: `python run_fire_mountain_gems.py`
3. Verify files appear in S3
4. Consider setting up S3 lifecycle policies
5. Add monitoring/alerting for failed uploads