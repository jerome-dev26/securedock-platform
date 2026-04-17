# SecureDock Platform

A secure, containerized web application platform deployed on AWS EC2 with automated CI/CD, integrated security controls, runtime hardening, observability, and incident-response readiness.

This project demonstrates a comprehensive DevSecOps approach, covering aspects from secure coding and secret management to automated deployment, runtime hardening, and operational resilience.

## Project Structure

- `app/`: Contains the sample frontend and backend applications.
- `nginx/`: Nginx configuration files.
- `docker/`: Dockerfiles for building application images.
- `compose/`: Docker Compose configurations for development and production.
- `.github/workflows/`: GitHub Actions CI/CD workflows.
- `scripts/`: Utility scripts for deployment, rollback, backup, and host hardening.
- `security/`: Security-related documentation (threat model, incident response, hardening checklists).
- `docs/`: General project documentation (architecture, runbooks).

## Getting Started

Refer to the `docs/architecture.md` and `docs/runbook.md` for detailed setup and operational instructions.

## DevSecOps Principles Applied

This project embodies the following DevSecOps principles:

- **Shift Left Security**: Integrating security scans (SAST, secret scanning, container scanning) early in the development lifecycle.
- **Infrastructure as Code (IaC)**: Defining infrastructure and application configurations in code.
- **Automated CI/CD**: Streamlining the build, test, and deployment processes with security gates.
- **Containerization**: Using Docker for consistent and isolated application environments.
- **Observability**: Implementing logging and monitoring for operational visibility.
- **Resilience**: Planning for backups, rollback strategies, and incident response.
- **Least Privilege**: Restricting access and permissions to the minimum necessary.

## Components

- **Cloud Provider**: AWS (EC2 Free Tier)
- **Domain Management**: Namecheap
- **Web Server**: Nginx
- **Containerization**: Docker & Docker Compose
- **CI/CD**: GitHub Actions
- **Security Scanners**: Semgrep, Gitleaks, Hadolint, Trivy, OWASP ZAP Baseline
- **Access**: PuTTY (for initial setup and emergency access)

## License

This project is open-source and available under the MIT License.
