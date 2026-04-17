#!/bin/bash

set -euo pipefail

# Usage: ./backup.sh

BACKUP_DIR="/var/backups/securedock"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/securedock_backup_${TIMESTAMP}.tar.gz"

echo "Starting backup of SecureDock Platform data..."

# Create backup directory if it doesn't exist
sudo mkdir -p ${BACKUP_DIR}

# Example: Backup SQLite database (if used)
# If using a persistent volume for the database, ensure it's mounted and accessible
# For SQLite, you might want to stop the backend service briefly or use a read-only transaction
# For PostgreSQL/MySQL, use pg_dump/mysqldump

# For simplicity, assuming a SQLite file within the backend container's volume
# This is a basic example and might need adjustment based on actual database setup

# Find the backend container ID
BACKEND_CONTAINER_ID=$(sudo docker-compose -f compose/docker-compose.prod.yml ps -q backend)

if [ -z "$BACKEND_CONTAINER_ID" ]; then
    echo "Backend container not found. Skipping database backup."
else
    echo "Copying database file from backend container..."
    # Assuming the database file is at /app/sql_app.db inside the container
    sudo docker cp ${BACKEND_CONTAINER_ID}:/app/sql_app.db ${BACKUP_DIR}/sql_app.db
    echo "Database file copied to ${BACKUP_DIR}/sql_app.db"
fi

# Archive relevant application data and configurations
# This example includes the database file and Nginx configs
sudo tar -czvf ${BACKUP_FILE} -C ${BACKUP_DIR} sql_app.db ./nginx/nginx.conf ./nginx/conf.d/

# Clean up copied database file
if [ -f "${BACKUP_DIR}/sql_app.db" ]; then
    sudo rm ${BACKUP_DIR}/sql_app.db
fi

echo "Backup created: ${BACKUP_FILE}"

# Optional: Upload to S3 or another remote storage
# aws s3 cp ${BACKUP_FILE} s3://your-backup-bucket/

# Optional: Clean up old backups (e.g., keep last 7 days)
# find ${BACKUP_DIR} -type f -name "securedock_backup_*.tar.gz" -mtime +7 -delete
