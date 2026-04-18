#!/bin/bash

set -euo pipefail

# Arguments:
# $1: GITHUB_REPOSITORY_OWNER (e.g., your-github-username)
# $2: IMAGE_NAME_FRONTEND (e.g., securedock-frontend)
# $3: IMAGE_NAME_BACKEND (e.g., securedock-backend)
# $4: PREVIOUS_GITHUB_SHA (commit SHA of the version to rollback to)
# $5: DOMAIN_NAME (your registered domain name)

GITHUB_REPOSITORY_OWNER=$1
IMAGE_NAME_FRONTEND=$2
IMAGE_NAME_BACKEND=$3
PREVIOUS_GITHUB_SHA=$4
DOMAIN_NAME=$5

REGISTRY="ghcr.io"

echo "Attempting to rollback SecureDock Platform to Git SHA: ${PREVIOUS_GITHUB_SHA}"

# Ensure Docker is running
sudo systemctl start docker

# Pull the previous images from GitHub Container Registry
echo "Pulling previous frontend image: ${REGISTRY}/${GITHUB_REPOSITORY_OWNER}/${IMAGE_NAME_FRONTEND}:${PREVIOUS_GITHUB_SHA}"
sudo docker pull ${REGISTRY}/${GITHUB_REPOSITORY_OWNER}/${IMAGE_NAME_FRONTEND}:${PREVIOUS_GITHUB_SHA}
sudo docker tag ${REGISTRY}/${GITHUB_REPOSITORY_OWNER}/${IMAGE_NAME_FRONTEND}:${PREVIOUS_GITHUB_SHA} ${REGISTRY}/${GITHUB_REPOSITORY_OWNER}/${IMAGE_NAME_FRONTEND}:latest

echo "Pulling previous backend image: ${REGISTRY}/${GITHUB_REPOSITORY_OWNER}/${IMAGE_NAME_BACKEND}:${PREVIOUS_GITHUB_SHA}"
sudo docker pull ${REGISTRY}/${GITHUB_REPOSITORY_OWNER}/${IMAGE_NAME_BACKEND}:${PREVIOUS_GITHUB_SHA}
sudo docker tag ${REGISTRY}/${GITHUB_REPOSITORY_OWNER}/${IMAGE_NAME_BACKEND}:${PREVIOUS_GITHUB_SHA} ${REGISTRY}/${GITHUB_REPOSITORY_OWNER}/${IMAGE_NAME_BACKEND}:latest

# Stop and remove current containers, then start the rolled-back ones
echo "Stopping current containers and starting rolled-back versions..."
sudo docker-compose -f /home/ubuntu/securedock-platform/compose/docker-compose.prod.yml down || true
sudo DOMAIN_NAME=${DOMAIN_NAME} docker-compose -f /home/ubuntu/securedock-platform/compose/docker-compose.prod.yml up -d

echo "Rollback to ${PREVIOUS_GITHUB_SHA} complete!"
