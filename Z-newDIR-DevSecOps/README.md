# SecureDock Platform

This repository contains the full implementation of the SecureDock Platform, a DevSecOps project designed to demonstrate secure application delivery on AWS EC2 using Docker, Nginx, GitHub Actions, and various security tools.

## Project Structure

```
securedock-platform/
├── app/
│   ├── frontend/             # Frontend application code (HTML, JS, CSS)
│   └── backend/              # Backend application code (Python Flask)
├── nginx/                    # Nginx configuration files
│   ├── nginx.conf
│   └── conf.d/
├── docker/                   # Dockerfiles for frontend and backend
│   ├── Dockerfile.frontend
│   └── Dockerfile.backend
├── compose/                  # Docker Compose files for local and production environments
│   ├── docker-compose.yml
│   └── docker-compose.prod.yml
├── .github/
│   └── workflows/            # GitHub Actions CI/CD workflows
│       ├── ci.yml
│       └── deploy.yml
├── scripts/                  # Deployment, rollback, backup, and host hardening scripts
│   ├── deploy.sh
│   ├── rollback.sh
│   ├── backup.sh
│   ├── harden-host.sh
│   └── aws_secrets_manager.sh
├── security/                 # Security-related documentation and configurations
│   ├── threat-model.md
│   ├── incident-response.md
│   ├── hardening-checklist.md
│   └── zap-baseline.md
├── docs/                     # Project documentation (deployment guide, architecture, etc.)
│   ├── architecture.md
│   ├── runbook.md
│   ├── onboarding.md
│   ├── devsecops_project_guide.md
│   ├── linkedin_tools_analysis.md
│   └── deployment_guide.md
└── README.md
```

## Getting Started

Refer to the `docs/deployment_guide.md` for a detailed, step-by-step guide on how to deploy and manage this project.
