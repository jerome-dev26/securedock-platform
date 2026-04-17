# DevSecOps Project Blueprint for AWS Free Tier

**Author:** Manus AI  
**Date:** 2026-04-16

## Executive Summary

The best way to build a **single project that genuinely covers most DevSecOps domains** on a limited budget is to create a **production-style secure application delivery platform** around one useful application, rather than trying to assemble unrelated tools. My recommendation is a project I would title **SecureDock Platform**: a Dockerized web application deployed on an AWS EC2 instance, fronted by Nginx, reachable through your Namecheap domain, and delivered through a CI/CD pipeline with integrated security scanning, image provenance, secret hygiene, configuration validation, runtime hardening, logging, monitoring, backup, and incident-response playbooks.

This project is useful in practice because it is not only a learning lab. It can host a real personal or small-team service, such as a portfolio and API, an internal documentation portal, a lightweight client dashboard, or a secure notes/task application. Architecturally, it stays within the reach of a low-cost AWS setup while still exposing you to the **full DevSecOps lifecycle** from code to cloud to operations.

AWS currently documents that new customers can use AWS Free Tier under either a **Free account plan** or a **Paid account plan**, with credits and always-free services depending on eligibility, and advises users to review plan details and eligible services carefully.[1] AWS also states that EC2 security groups act as a **virtual firewall** controlling inbound and outbound traffic and that there is **no additional charge** for using them.[2] That makes EC2 plus tight security groups a practical base for a low-cost DevSecOps project.

## Why This Is the Right Project

If your goal is to “cover all areas of DevSecOps,” the project needs to demonstrate more than deployment. It should show how you manage source control, coding standards, dependency risk, container security, infrastructure configuration, domain and TLS, CI/CD, secret handling, operating system hardening, web server hardening, observability, backup, and recovery.

A single-EC2, Docker-based platform is the correct compromise because it is realistic enough to teach the right practices while remaining affordable and maintainable. Docker’s official Ubuntu installation documentation supports running Docker Engine on Ubuntu, which aligns well with EC2 Ubuntu instances.[3] GitHub documents a workflow pattern for building and publishing Docker images, and also supports generating **artifact attestations** to strengthen supply-chain security.[4] Trivy documents itself as an **all-in-one open-source security scanner** and explicitly supports CI/CD integration as well as container image scanning.[5]

| Criterion | Recommended choice | Why it fits your constraints |
|---|---|---|
| Cloud runtime | **AWS EC2 Ubuntu** | Simple, free-tier-friendly starting point, broad learning value |
| Web entry point | **Nginx** | Reverse proxy, TLS termination, headers, rate limiting |
| Packaging | **Docker + Docker Compose** | Easy local-to-server parity and isolated deployments |
| Domain | **Namecheap domain** | Can point root and subdomains to EC2 with A records.[6] |
| Access | **PuTTY for SSH on Windows** | Matches your stated preference |
| CI/CD | **GitHub Actions** | Strong ecosystem and native container workflows.[4] |
| Image storage | **GHCR or Docker Hub** | Easy integration with GitHub Actions |
| Security scanning | **Trivy, Semgrep, Gitleaks, Hadolint, ZAP baseline** | Broad coverage across code, secrets, images, and web testing |
| Host hardening | **UFW, Fail2ban, least-open ports** | Practical security controls for a single VM |
| Runtime observability | **Prometheus-style exporters or lightweight logs/alerts** | Teaches operate and monitor stages |

## The Project Definition

I recommend implementing the project as follows.

> **Project name:** SecureDock Platform  
> **Purpose:** A secure, containerized web application platform deployed on AWS EC2 with automated CI/CD, integrated security controls, runtime hardening, observability, and incident-response readiness.

The application itself can be simple. A small but useful choice would be a **client portal or internal ops dashboard** with a frontend and backend. The actual business functionality matters less than the delivery platform, but using a real app keeps the project practical and reusable. You can later replace the sample application without redesigning the whole DevSecOps stack.

## Scope Coverage Across DevSecOps Domains

To ensure this project truly covers the field, the implementation should map each major DevSecOps discipline to a concrete deliverable.

| DevSecOps area | What your project will demonstrate |
|---|---|
| Planning and architecture | Threat model, trust boundaries, attack surface review |
| Source control | Branching strategy, pull requests, code review gates |
| Secure coding | Linting, SAST, dependency hygiene, code ownership |
| Secrets management | No secrets in repo, server-side environment files, GitHub secrets |
| Build security | Pinned actions, reproducible image builds, artifact attestations |
| Container security | Minimal images, non-root user, image scanning, health checks |
| IaC and config security | Compose validation, optional Terraform + Checkov later |
| CI/CD | Automated test, scan, build, publish, deploy pipeline |
| Infrastructure security | Security groups, SSH controls, firewalling, OS patching |
| Web security | Nginx TLS, headers, rate limiting, request controls |
| DAST | ZAP baseline against staging or protected target |
| Observability | Logs, metrics, uptime checks, alerts |
| Resilience | Backups, rollback, disaster recovery notes |
| Operations | Runbooks, rotation, patch management, incident workflow |
| Compliance mindset | Audit trail, provenance, artifact history, documented procedures |

## Recommended Architecture

The architecture should remain intentionally simple in version one. Overengineering too early usually harms learning.

The system should use one EC2 Ubuntu host running Docker Engine and Docker Compose. Nginx should run either directly on the host or, preferably for portability, as a dedicated reverse-proxy container. The application backend and frontend should run in separate containers on an internal Docker network. Only ports **80** and **443** should be exposed publicly. Port **22** should be restricted to your IP address whenever possible, because AWS security groups are specifically intended to control this traffic.[2]

Your Namecheap domain should point to the EC2 public IP using A records. Namecheap documents that this is done from **Domain List**, then **Manage**, then **Advanced DNS**, then **Host Records**, where you add an **A Record** for `@`, `www`, or another subdomain and save the changes. Namecheap also notes that new records normally take about **30 minutes** to take effect.[6]

```text
Internet
   |
Namecheap DNS
   |
AWS EC2 Ubuntu
   |
Nginx reverse proxy
   |-----------------------|
Frontend container     Backend API container
                           |
                     SQLite or PostgreSQL container
```

## The Best Low-Cost Implementation Path

Because you are working with AWS Free Tier, the most sensible sequence is to start with one instance and one environment. Do **not** begin with Kubernetes. That would add operational complexity before you have mastered the core controls.

The project should begin in **three maturity levels**.

| Stage | Objective | What you build |
|---|---|---|
| Stage 1 | Working secure MVP | EC2, Docker, Nginx, domain, TLS, manual deployment |
| Stage 2 | Real DevSecOps pipeline | GitHub Actions, scans, image registry, auto deploy |
| Stage 3 | Operational maturity | Monitoring, backups, rollback, incident runbooks |

This staging matters because DevSecOps is not just tool installation. It is the progressive tightening of controls without destroying delivery speed.

## Detailed Tooling Stack

The stack below is the one I would personally choose for a portfolio-worthy project that still remains practical.

| Layer | Tool | Role |
|---|---|---|
| Source control | GitHub | Repository, PRs, workflow automation |
| Runtime host | AWS EC2 Ubuntu | Main compute node |
| Container runtime | Docker Engine | Container execution on server[3] |
| Orchestration | Docker Compose | Multi-container deployment |
| Reverse proxy | Nginx | TLS termination, proxying, headers |
| Registry | GHCR | Store versioned images |
| CI/CD | GitHub Actions | Build, scan, attest, deploy[4] |
| SAST | Semgrep | Static code analysis |
| Secret scanning | Gitleaks | Credential detection |
| Docker linting | Hadolint | Dockerfile quality and security |
| Container/IaC scanning | Trivy | Image, filesystem, misconfiguration, secret scanning[5] |
| DAST | OWASP ZAP baseline | Runtime web checks |
| TLS certificates | Let’s Encrypt via Certbot or acme companion | HTTPS |
| Host firewall | UFW + AWS security groups | Defense in depth |
| Login protection | Fail2ban | Brute-force reduction |
| Logging | Docker logs + journald + Nginx logs | Operational visibility |
| Monitoring | Uptime Kuma or basic exporters | Uptime and health visibility |
| Backup | Cron + encrypted archive to S3 or local snapshot policy | Recovery |

## Repository Layout

Your repository should look deliberate and professional. A strong layout would be the following.

```text
securedock-platform/
├── app/
│   ├── frontend/
│   └── backend/
├── nginx/
│   ├── nginx.conf
│   └── conf.d/
├── docker/
│   ├── Dockerfile.frontend
│   └── Dockerfile.backend
├── compose/
│   ├── docker-compose.yml
│   ├── docker-compose.prod.yml
│   └── .env.example
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── deploy.yml
├── scripts/
│   ├── deploy.sh
│   ├── rollback.sh
│   ├── backup.sh
│   └── harden-host.sh
├── security/
│   ├── threat-model.md
│   ├── incident-response.md
│   ├── hardening-checklist.md
│   └── zap-baseline.md
├── docs/
│   ├── architecture.md
│   ├── runbook.md
│   └── onboarding.md
└── README.md
```

This layout shows hiring managers or interviewers that you understand that **security artifacts belong in the same engineering lifecycle as application code**.

## CI/CD Pipeline Design

GitHub’s documentation shows that GitHub Actions can build and publish Docker images, log into a registry, and generate artifact attestations for image provenance.[4] Your pipeline should use that capability, but keep the workflow modular.

The CI/CD path should look like this.

| Pipeline stage | Required action | Security control |
|---|---|---|
| Pull request opened | Lint, unit test, SAST, secret scan | Blocks risky code early |
| Merge to main | Build images, run Trivy, publish image | Prevents vulnerable images from shipping |
| Release tag | Generate signed artifact provenance/attestation | Supply-chain evidence[4] |
| Deploy job | Pull tagged image on EC2 and restart Compose | Controlled immutable release |
| Post-deploy | Smoke test and health check | Verifies runtime success |

A practical gating policy is to fail the build on **critical secrets**, **high-confidence SAST findings**, and **critical container vulnerabilities** for internet-facing releases. For medium issues, create tickets and track remediation.

## Security Controls You Should Implement

A real DevSecOps project becomes convincing only when security controls are visible in code, infrastructure, and operations.

### 1. Identity, access, and secrets

GitHub repository secrets should hold deployment credentials, registry credentials if needed, and notification hooks. Never store secrets in the repository. Gitleaks should run on every pull request to catch accidental leaks. On the EC2 server, runtime secrets should live in a root-owned `.env` file outside the application source tree, with strict file permissions.

### 2. Host hardening

The EC2 host should be hardened immediately after provisioning. SSH should use key-based access only. Because you prefer PuTTY, use **PuTTYgen** to convert the AWS PEM key into PPK format for Windows-based access, but keep the private key encrypted locally. If you later want to reduce direct SSH dependence, AWS documents **EC2 Instance Connect** as an option through the console, CLI, or an SSH client, and notes that it can push a temporary SSH public key for connection.[7]

### 3. Network hardening

AWS says security groups are stateful and allow you to control inbound and outbound traffic to EC2 instances.[2] In this project, inbound rules should normally be restricted to `80/tcp`, `443/tcp`, and `22/tcp` from your own IP only. Internally, backend and database ports should never be exposed to the public internet.

### 4. Web-layer hardening

Nginx should enforce HTTPS, redirect HTTP to HTTPS, set security headers, hide version disclosure, and apply request limits. If the app exposes authentication, add rate limiting on login endpoints and consider basic geo/IP filtering if relevant.

### 5. Container hardening

Your application images should run as non-root users, use minimal base images where practical, set explicit health checks, and avoid baking secrets into images. Trivy should scan built images before deployment.[5]

### 6. Secure supply chain

GitHub explicitly recommends pinning actions to a **commit SHA**, rather than a mutable tag, because tags or branches may change without warning.[4] That single control is often missed by beginners and is a valuable mark of maturity.

> “GitHub recommends pinning actions to a commit SHA. To get a newer version, you will need to update the SHA. You can also reference a tag or branch, but the action may change without warning.” — GitHub Docs[4]

### 7. Runtime validation

A lightweight DAST pass with OWASP ZAP baseline against your staging URL should check the externally reachable application after deployment. This is not a replacement for manual testing, but it closes an important gap in many beginner pipelines.

## Nginx Design Recommendations

Since you specifically asked to use Nginx, it should do more than simple proxying. It should become part of your security architecture.

| Nginx responsibility | Why it matters |
|---|---|
| TLS termination | Centralized certificate handling |
| Reverse proxying | Keeps app containers off public ports |
| Header control | Adds HSTS, X-Frame-Options, X-Content-Type-Options, CSP |
| Rate limiting | Helps reduce brute-force and abuse |
| Request size limits | Reduces some attack paths |
| Access logging | Supports incident investigation |
| Upstream health handling | Improves resilience |

In interviews, being able to explain **why the app containers sit behind Nginx** is often more important than the exact syntax of the config.

## Docker Strategy

Docker’s official Ubuntu documentation confirms the supported installation path for Docker Engine on Ubuntu.[3] In this project, Docker should be used for **consistency and immutability**, not just convenience.

You should have separate images for frontend and backend, a Compose file for local development, and a production override for the EC2 deployment. Keep builds deterministic, use explicit versions, and tag images with commit SHA plus release tag. That makes rollback straightforward.

A good release convention is:

| Tag type | Example | Purpose |
|---|---|---|
| Commit tag | `ghcr.io/you/securedock-backend:sha-1a2b3c4` | Precise rollback target |
| Release tag | `ghcr.io/you/securedock-backend:v1.0.0` | Human-readable release |
| Environment tag | `ghcr.io/you/securedock-backend:prod` | Convenience pointer, not source of truth |

## Domain and TLS Plan

The Namecheap domain should be used because it makes the platform feel real and it demonstrates external DNS ownership. Namecheap documents that you can create A records from the **Advanced DNS** page, including `@` for the root domain and `www` for the subdomain.[6]

A clean DNS layout would be the following.

| Record | Points to | Use |
|---|---|---|
| `@` | EC2 public IP | Main site |
| `www` | EC2 public IP or CNAME to root | Human-friendly alias |
| `api` | EC2 public IP | Backend/API endpoint |
| `status` | EC2 public IP | Optional uptime dashboard |

For TLS, use Let’s Encrypt. If you keep Nginx on the host, Certbot is simple. If you containerize Nginx fully, use an ACME-compatible companion or script. The important part is not the tool choice; it is **automated renewal** and **documented recovery steps**.

## How PuTTY Fits In

You explicitly mentioned PuTTY, and that is perfectly fine for this project if you are working from Windows. In a portfolio context, I would position it this way: **PuTTY is your admin access client, not your deployment mechanism**.

That distinction matters. Manual SSH access through PuTTY should be reserved for bootstrap, emergency maintenance, verification, and incident handling. Regular deployments should be executed by the CI/CD pipeline, not by manually logging in and copying files. That separation is a hallmark of mature DevSecOps.

## Step-by-Step Build Plan

The most effective path is to build the project in an ordered sequence.

### Phase A: Provision and baseline the server

Create the EC2 instance, attach the appropriate security group, and verify whether your AWS account is still within the relevant free-tier eligibility or credits model.[1] Install Docker Engine on Ubuntu according to Docker’s supported installation guidance.[3] Install Docker Compose plugin, Nginx if you prefer host-based reverse proxying, UFW, Fail2ban, and Git.

### Phase B: Deploy the sample application manually

Containerize a simple frontend and backend. Use Compose to run them. Place Nginx in front of them. Confirm the application works via the EC2 public IP first. Only after that should you configure Namecheap DNS and TLS.

### Phase C: Add the security toolchain

Add Semgrep, Gitleaks, Hadolint, Trivy, and a minimal ZAP baseline job. Trivy installation and CI/CD integration are documented by the project itself.[5] Fail builds on secrets and severe findings. Publish scan artifacts for review.

### Phase D: Add registry publishing and provenance

GitHub’s workflow examples document logging into `ghcr.io`, building and pushing images, and generating an artifact attestation.[4] Implement this next so that your deployment consumes immutable, pre-scanned images from the registry.

### Phase E: Automate deployment

Use GitHub Actions SSH deployment to the server or a pull-based deployment strategy. My recommendation is a pull-based script on the server that receives a version, logs in to the registry if necessary, pulls the tagged images, and restarts Compose. That keeps deployment logic centralized.

### Phase F: Add observability and resilience

Add uptime monitoring, log rotation, backup scripts, and a rollback procedure. You do not need enterprise observability to demonstrate operational maturity; you need reliable, documented, testable procedures.

## A Strong Minimum Viable Feature Set

If you want this project to be portfolio-ready quickly, these are the minimum features I would insist on.

| Category | Minimum requirement |
|---|---|
| App delivery | Frontend + backend containerized and deployed |
| Web security | HTTPS, redirect, basic headers, rate limiting |
| CI | Tests, linting, Semgrep, Gitleaks, Hadolint |
| Container security | Trivy image scan before release |
| CD | Tag-based deployment from registry |
| Access security | Key-only SSH, restricted port 22 |
| Documentation | README, architecture, threat model, runbook |
| Recovery | Backup script and rollback script |

If you complete just this minimum properly, it will already be stronger than many so-called DevSecOps demo projects online.

## Threat Model Summary

A meaningful project should explicitly state what threats it is trying to reduce.

| Threat | Example | Your control |
|---|---|---|
| Secret leakage | API key committed to repo | Gitleaks, secret review, `.env.example` only |
| Vulnerable image | Outdated OS packages in image | Trivy gating |
| Malicious build dependency | Mutable workflow action tag | Pin actions to commit SHA[4] |
| Exposed admin surface | SSH open to all IPs | Restrict security group to your IP[2] |
| Web exploitation | Missing security headers | Nginx hardening |
| Abuse or brute force | Login endpoint hammering | Nginx rate limiting + Fail2ban |
| Bad deployment | Broken image rolled to prod | Health checks + rollback script |
| Silent failure | App down without visibility | Uptime checks and alerts |
| Data loss | Host issue or operator error | Scheduled backups |

## Optional Advanced Enhancements

After the core project works, you can evolve it without changing the basic platform.

| Enhancement | Value added |
|---|---|
| Terraform for EC2, SG, and IAM | Infrastructure as code maturity |
| Checkov or tfsec | IaC policy scanning |
| Cosign signing | Stronger artifact trust model |
| SBOM generation | Better supply-chain visibility |
| Wazuh or Falco | Runtime detection exposure |
| AWS S3 encrypted backups | Better persistence and recovery |
| CloudWatch integration | Native AWS operational visibility |
| Blue/green deployment pattern | Safer releases |
| Staging environment on second host later | Environment separation |

I would not add these until your stage-one platform is stable.

## What to Avoid

Many DevSecOps projects become weaker because they try to impress with too many tools. In your case, the following would be mistakes.

First, do not jump directly into Kubernetes. Second, do not expose database ports publicly. Third, do not make PuTTY your normal deployment method. Fourth, do not open SSH to the whole internet if your IP is reasonably stable. Fifth, do not treat scanning as a checkbox; define what severities break the build. Sixth, do not skip documentation. A real DevSecOps engineer is judged as much by **operability and clarity** as by raw tooling.

## The Portfolio Narrative You Can Use

If you build this properly, you will be able to describe the project in a compelling way:

> I designed and implemented a production-style DevSecOps platform on AWS EC2 using Docker, Nginx, GitHub Actions, and a Namecheap-managed domain. I integrated SAST, secret scanning, container scanning, web-layer controls, provenance-aware image publishing, automated deployment, runtime hardening, and operational runbooks. The platform is designed to host a real application while demonstrating secure delivery from code to cloud.

That is a much stronger narrative than saying you “used Docker and AWS.”

## Final Recommendation

My firm recommendation is that you build **one serious project** instead of several disconnected mini-projects. Use your AWS account and Namecheap domain to create a **secure container platform for a real web application**. Put **Nginx, Docker, GitHub Actions, Trivy, Semgrep, Gitleaks, and operational runbooks** at the center of the design. Use **PuTTY** only as an administrative access method, not as the foundation of your deployment workflow.

This approach gives you a project that is simultaneously **portfolio-grade, interview-ready, budget-aware, and genuinely useful in production-like operation**.

If you want, the next logical step is for me to turn this blueprint into a **complete implementation pack** consisting of a repository structure, Dockerfiles, Nginx config, GitHub Actions workflows, EC2 setup steps, and a rollout checklist.

## References

[1]: https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/free-tier.html "Explore AWS services with AWS Free Tier - AWS Billing"
[2]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-security-groups.html "Amazon EC2 security groups for your EC2 instances"
[3]: https://docs.docker.com/engine/install/ubuntu/ "Install Docker Engine on Ubuntu"
[4]: https://docs.github.com/en/actions/use-cases-and-examples/publishing-packages/publishing-docker-images "Publishing Docker images - GitHub Docs"
[5]: https://trivy.dev/latest/docs/getting-started/installation/ "Installation - Trivy"
[6]: https://www.namecheap.com/support/knowledgebase/article.aspx/319/2237/how-can-i-set-up-an-a-address-record-for-my-domain/ "How can I set up an A (address) record for my domain? - Namecheap"
[7]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-methods.html "Connect to a Linux instance using EC2 Instance Connect - Amazon EC2"
