#!/bin/bash

set -euo pipefail

# Arguments:
# $1: GITHUB_REPOSITORY_OWNER (e.g., your-github-username)
# $2: IMAGE_NAME_FRONTEND (e.g., securedock-frontend)
# $3: IMAGE_NAME_BACKEND (e.g., securedock-backend)
# $4: GITHUB_SHA (commit SHA for tagging images)
# $5: DOMAIN_NAME (your registered domain name)

GITHUB_REPOSITORY_OWNER=$1
IMAGE_NAME_FRONTEND=$2
IMAGE_NAME_BACKEND=$3
GITHUB_SHA=$4
DOMAIN_NAME=$5

REGISTRY="ghcr.io"

echo "Deploying SecureDock Platform..."

# Ensure Docker is running
sudo systemctl start docker

# Pull the latest images from GitHub Container Registry
# Using the commit SHA for specific versioning
echo "Pulling frontend image: ${REGISTRY}/${GITHUB_REPOSITORY_OWNER}/${IMAGE_NAME_FRONTEND}:${GITHUB_SHA}"
sudo docker pull ${REGISTRY}/${GITHUB_REPOSITORY_OWNER}/${IMAGE_NAME_FRONTEND}:${GITHUB_SHA}
sudo docker tag ${REGISTRY}/${GITHUB_REPOSITORY_OWNER}/${IMAGE_NAME_FRONTEND}:${GITHUB_SHA} ${REGISTRY}/${GITHUB_REPOSITORY_OWNER}/${IMAGE_NAME_FRONTEND}:latest

echo "Pulling backend image: ${REGISTRY}/${GITHUB_REPOSITORY_OWNER}/${IMAGE_NAME_BACKEND}:${GITHUB_SHA}"
sudo docker pull ${REGISTRY}/${GITHUB_REPOSITORY_OWNER}/${IMAGE_NAME_BACKEND}:${GITHUB_SHA}
sudo docker tag ${REGISTRY}/${GITHUB_REPOSITORY_OWNER}/${IMAGE_NAME_BACKEND}:${GITHUB_SHA} ${REGISTRY}/${GITHUB_REPOSITORY_OWNER}/${IMAGE_NAME_BACKEND}:latest

# Stop and remove old containers, then start new ones using docker-compose.prod.yml
echo "Stopping and removing old containers..."
sudo docker-compose -f /home/ubuntu/securedock-platform/compose/docker-compose.prod.yml down || true

echo "Starting new containers..."
# Pass DOMAIN_NAME as an environment variable for Nginx configuration if needed
sudo DOMAIN_NAME=${DOMAIN_NAME} docker-compose -f /home/ubuntu/securedock-platform/compose/docker-compose.prod.yml up -d

echo "Deployment complete!"

# Optional: Run health checks
# sudo docker-compose -f /home/ubuntu/securedock-platform/compose/docker-compose.prod.yml ps
# curl -s http://localhost/status || curl -s http://localhost/api/status
