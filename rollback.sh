#!/bin/bash

set -euo pipefail

# Usage: ./rollback.sh <PREVIOUS_GIT_SHA> <DOMAIN_NAME>
# Example: ./rollback.sh f6e5d4c3b2a1 securedock.example.com

PREVIOUS_GIT_SHA=$1
DOMAIN_NAME=$2

echo "Rolling back SecureDock Platform to Git SHA: ${PREVIOUS_GIT_SHA} on ${DOMAIN_NAME}"

# Ensure Docker is running
if ! systemctl is-active --quiet docker;
then
    echo "Docker is not running. Starting Docker..."
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# Pull the previous images based on the Git SHA
echo "Pulling previous frontend image: ghcr.io/${GITHUB_REPOSITORY_OWNER}/securedock-frontend:${PREVIOUS_GIT_SHA}"
docker pull ghcr.io/${GITHUB_REPOSITORY_OWNER}/securedock-frontend:${PREVIOUS_GIT_SHA}

echo "Pulling previous backend image: ghcr.io/${GITHUB_REPOSITORY_OWNER}/securedock-backend:${PREVIOUS_GIT_SHA}"
docker pull ghcr.io/${GITHUB_REPOSITORY_OWNER}/securedock-backend:${PREVIOUS_GIT_SHA}

# Stop and remove current containers, then start containers with previous images
echo "Stopping and removing current containers..."
sudo docker-compose -f compose/docker-compose.prod.yml down

echo "Starting containers with previous images..."
# Use DOMAIN_NAME for Nginx configuration if needed, passed as env var to compose
DOMAIN_NAME=${DOMAIN_NAME} sudo docker-compose -f compose/docker-compose.prod.yml up -d

echo "Rollback complete to Git SHA: ${PREVIOUS_GIT_SHA}"

# Optional: Run health checks
# curl -f https://${DOMAIN_NAME}/health || echo "Health check failed!"
