#!/bin/bash

set -euo pipefail

BACKUP_DIR="/var/backups/securedock"
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/securedock_backup_${TIMESTAMP}.tar.gz"

echo "Starting SecureDock Platform backup..."

# Create backup directory if it doesn't exist
sudo mkdir -p ${BACKUP_DIR}

# Example: Backup a SQLite database (if used)
# If you use a persistent volume for your database, you might want to stop the database container first
# or use a tool like `pg_dump` for PostgreSQL.
# For this example, we'll assume a simple file-based backup or placeholder.

# Example: Copy application data (e.g., user uploads, config files)
# Adjust this to your actual application's persistent data paths
# For now, we'll just create a dummy file to show the backup process
echo "Simulating application data backup..."
sudo touch /tmp/app_data_to_backup_${TIMESTAMP}.txt

# Create a tarball of relevant data
# This is a placeholder. You would include actual persistent data volumes here.
# For example, if your backend uses a SQLite DB at /app/data/app.db inside its container,
# and that's mounted to /home/ubuntu/securedock-platform/data/app.db on the host,
# you would include /home/ubuntu/securedock-platform/data/ in your tar command.

echo "Creating tarball of application data..."
sudo tar -czvf ${BACKUP_FILE} /tmp/app_data_to_backup_${TIMESTAMP}.txt

echo "Backup created: ${BACKUP_FILE}"

# Optional: Upload to S3 (requires AWS CLI configured)
# AWS_BUCKET_NAME="your-securedock-backup-bucket"
# echo "Uploading backup to S3://${AWS_BUCKET_NAME}..."
# sudo aws s3 cp ${BACKUP_FILE} s3://${AWS_BUCKET_NAME}/
# echo "Backup uploaded to S3."

# Clean up old backups (e.g., keep last 7 days)
# find ${BACKUP_DIR} -type f -name "securedock_backup_*.tar.gz" -mtime +7 -delete

echo "Backup process complete."
