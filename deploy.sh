#!/bin/bash

# Build the app
npm run build

# Sync with S3
aws s3 sync dist/ s3://will-it-rain-on-thursday

# Invalidate CloudFront cache (if using CloudFront)
aws cloudfront create-invalidation --distribution-id YOUR_DISTRIBUTION_ID --paths "/*" 