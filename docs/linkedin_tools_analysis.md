# DevSecOps Tools and Activities Analysis

Based on the LinkedIn post by saed, the following tools and activities were identified:

| Activity | Identified Tools | Purpose |
|---|---|---|
| Image/Filesystem Scanning | **Trivy**, **Grype** | Scan images, filesystems, and repos before deploy to catch CVEs and bad base images. |
| Secret Scanning | **Gitleaks** | Scan commits and repos for secrets (e.g., .env files) before they become incidents. |
| GitOps / Source of Truth | **ArgoCD** | Ensure Git is the source of truth, detect drift, and correct manual changes. |
| Admission Control | **Kyverno**, **OPA Gatekeeper** | Enforce rules at admission time before bad workloads enter the cluster. |
| Secrets Management | **External Secrets**, **Secrets Store CSI Driver**, **Vault**, **AWS Secrets Manager** | Manage secrets securely instead of plain Kubernetes objects. |
| Image Signing / Provenance | **Cosign** | Sign images and verify they came from a trusted build path. |
| Software Bill of Materials (SBOM) | **Syft** | Generate SBOM to see what is inside your image and what dependency introduced risk. |
| Runtime Security | **Falco**, **Tetragon** | Watch runtime behavior and alert when a workload starts acting suspiciously. |
| Identity & Access | **Workload Identity**, **IRSA** | Provide short-lived access without hardcoded cloud credentials. |
| Incident Response | **Audit logs**, **Image provenance**, **Deployment history** | Provide fast answers under pressure during an incident. |

## Integration Strategy for SecureDock Project

Since the SecureDock project is currently based on a single EC2 instance with Docker Compose (not Kubernetes), some tools like ArgoCD, Kyverno, and OPA Gatekeeper are not directly applicable. However, we can integrate the following:

1.  **Trivy**: Already in the plan, but can be expanded to scan the filesystem and repos.
2.  **Gitleaks**: Already in the plan for secret scanning.
3.  **Cosign**: Can be added to sign the Docker images built in GitHub Actions.
4.  **Syft**: Can be added to generate SBOMs for the images.
5.  **AWS Secrets Manager**: Can be used to store and retrieve secrets for the EC2 instance instead of local `.env` files.
6.  **Falco**: Can be installed on the EC2 host for runtime security monitoring.
7.  **Audit Logs**: Ensure Nginx and Docker logs are properly collected and analyzed.
