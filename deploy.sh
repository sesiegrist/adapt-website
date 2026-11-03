#!/usr/bin/env bash
# Build the site and sync it to an S3 bucket configured for static website hosting.
# Usage: ./deploy.sh BUCKET_NAME [AWS_PROFILE]
# Requires: zola, aws cli, and credentials with s3:PutObject / s3:DeleteObject on the bucket.
set -euo pipefail
BUCKET="${1:?bucket name required}"
PROFILE="${2:-default}"
zola build
aws s3 sync public/ "s3://${BUCKET}/" --delete --profile "$PROFILE" \
  --cache-control "max-age=300"
echo "Deployed to http://${BUCKET}.s3-website-$(aws configure get region --profile "$PROFILE").amazonaws.com/"
