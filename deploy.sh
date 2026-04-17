#!/bin/bash

set -euo pipefail

# Usage: ./deploy.sh <GIT_SHA> <DOMAIN_NAME>
# Example: ./deploy.sh a1b2c3d4e5f6 securedock.example.com

GIT_SHA=$1
DOMAIN_NAME=$2

echo "Deploying SecureDock Platform with Git SHA: ${GIT_SHA} to ${DOMAIN_NAME}"

# Ensure Docker is running
if ! systemctl is-active --quiet docker;
then
    echo "Docker is not running. Starting Docker..."
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# Log in to GitHub Container Registry (GHCR)
# Assumes GITHUB_TOKEN is available as an environment variable or via docker login
# In a real scenario, this might be handled by a service principal or a more secure method
# For simplicity, we assume the GH Actions runner has already logged in, or a manual login was done.
# docker login ghcr.io -u $GITHUB_ACTOR -p $GITHUB_TOKEN # This would be for manual login

# Pull the latest images based on the Git SHA
echo "Pulling frontend image: ghcr.io/${GITHUB_REPOSITORY_OWNER}/securedock-frontend:${GIT_SHA}"
docker pull ghcr.io/${GITHUB_REPOSITORY_OWNER}/securedock-frontend:${GIT_SHA}

echo "Pulling backend image: ghcr.io/${GITHUB_REPOSITORY_OWNER}/securedock-backend:${GIT_SHA}"
docker pull ghcr.io/${GITHUB_REPOSITORY_OWNER}/securedock-backend:${GIT_SHA}

# Stop and remove old containers, then start new ones
echo "Stopping and removing old containers..."
sudo docker-compose -f compose/docker-compose.prod.yml down

echo "Starting new containers..."
# Use DOMAIN_NAME for Nginx configuration if needed, passed as env var to compose
DOMAIN_NAME=${DOMAIN_NAME} sudo docker-compose -f compose/docker-compose.prod.yml up -d

echo "Deployment complete for Git SHA: ${GIT_SHA}"

# Optional: Run health checks
# curl -f https://${DOMAIN_NAME}/health || echo "Health check failed!"
