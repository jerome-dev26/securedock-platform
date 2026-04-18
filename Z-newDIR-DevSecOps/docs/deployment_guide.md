# SecureDock Platform: Detailed Deployment Guide

**Author:** Manus AI  
**Date:** 2026-04-17

## 1. Introduction

This guide provides a comprehensive, step-by-step walkthrough for deploying the SecureDock Platform, a DevSecOps project designed to demonstrate secure application delivery on AWS EC2 using Docker, Nginx, GitHub Actions, and various security tools. It incorporates the latest DevSecOps practices, including SBOM generation with Syft, image signing with Cosign, and runtime security monitoring with Falco.

## 2. Prerequisites

Before you begin, ensure you have the following:

*   **AWS Account**: An active AWS account with access to the free tier services.
*   **Namecheap Domain**: A registered domain name with Namecheap.
*   **GitHub Account**: A GitHub account to host your project repository and run GitHub Actions.
*   **Local Machine Tools**: Git, Docker, PuTTY (for Windows users) or a standard SSH client (for Linux/macOS).
*   **Project Code**: The `securedock-platform` project files, including the `devsecops_project_guide.md` and the implementation pack generated previously.

## 3. Phase 1: AWS EC2 Instance Setup

This phase covers setting up your virtual machine on AWS.

### 3.1. Launch EC2 Instance

1.  Log in to your AWS Management Console.
2.  Navigate to the EC2 Dashboard.
3.  Click **"Launch instance"**.
4.  **Name and tags**: Give your instance a meaningful name, e.g., `securedock-server`.
5.  **Application and OS Images (Amazon Machine Image - AMI)**: Select `Ubuntu Server 22.04 LTS (HVM), SSD Volume Type` (64-bit x64). This is typically free-tier eligible.
6.  **Instance type**: Choose `t2.micro` (free-tier eligible).
7.  **Key pair (login)**: Create a new key pair or choose an existing one. If creating a new one, download the `.pem` file. **Keep this file secure.** If you are using PuTTY on Windows, you will need to convert this `.pem` file to a `.ppk` file using PuTTYgen (see section 3.3).
8.  **Network settings**: Click **"Edit"**.
    *   **VPC**: Use the default VPC.
    *   **Subnet**: Choose any available subnet.
    *   **Auto-assign public IP**: Enable.
    *   **Firewall (security groups)**: Create a new security group.
        *   **Security group name**: `securedock-sg`
        *   **Description**: `Security group for SecureDock Platform`
        *   **Inbound security group rules**: Add the following rules:
            *   **SSH**: Type `SSH`, Source `My IP` (this will auto-detect your current public IP. **Crucially, restrict this to your IP only for security.** If your IP changes, you'll need to update this rule).
            *   **HTTP**: Type `HTTP`, Source `Anywhere`.
            *   **HTTPS**: Type `HTTPS`, Source `Anywhere`.
9.  **Configure storage**: Keep the default 8 GiB `gp2` volume (free-tier eligible).
10. **Advanced details**: No changes needed for initial setup.
11. Click **"Launch instance"**.

### 3.2. Retrieve Public IP Address

Once the instance is running, note down its **Public IPv4 address**. You will need this for DNS configuration and SSH access.

### 3.3. Generate/Convert SSH Key Pair (for PuTTY users)

If you are on Windows and plan to use PuTTY:

1.  Download and install PuTTY and PuTTYgen if you haven't already.
2.  Open PuTTYgen.
3.  Click **"Load"** and select your downloaded `.pem` file (you might need to select "All Files" to see it).
4.  Click **"Save private key"** and confirm saving without a passphrase (or add one if you prefer, but remember it).
5.  Save the `.ppk` file to a secure location.

### 3.4. Initial SSH Connection

1.  **Linux/macOS**: Open your terminal and run:
    ```bash
    ssh -i /path/to/your-key-pair.pem ubuntu@<EC2_Public_IP>
    ```
    Replace `/path/to/your-key-pair.pem` with the actual path to your `.pem` file and `<EC2_Public_IP>` with your instance's public IP address.

2.  **Windows (PuTTY)**:
    *   Open PuTTY.
    *   In the **"Host Name (or IP address)"** field, enter `ubuntu@<EC2_Public_IP>`.
    *   Navigate to **Connection > SSH > Auth**.
    *   Click **"Browse..."** and select your `.ppk` file.
    *   Click **"Open"**.

    You should now be connected to your EC2 instance.

## 4. Phase 2: Host Hardening and Essential Software Installation

This phase prepares your EC2 instance for the SecureDock Platform.

### 4.1. Transfer Project Files to EC2

First, you need to get your `securedock-platform` project files onto the EC2 instance. From your local machine, use `scp`:

```bash
scp -i /path/to/your-key-pair.pem -r /path/to/securedock-platform ubuntu@<EC2_Public_IP>:/home/ubuntu/
```

This will copy the entire `securedock-platform` directory to your EC2 instance's home directory.

### 4.2. Run Host Hardening Script

SSH into your EC2 instance and execute the hardening script:

```bash
cd /home/ubuntu/securedock-platform/scripts
chmod +x harden-host.sh
sudo ./harden-host.sh
```

This script will:
*   Update and upgrade system packages.
*   Install and configure UFW (Uncomplicated Firewall) to allow SSH, HTTP, and HTTPS traffic.
*   Install and configure Fail2ban to protect against brute-force attacks.
*   Disable SSH password authentication and root login.

**Important**: After running `harden-host.sh`, ensure your SSH connection is still active. If your IP address changes, you might be locked out and need to update the AWS Security Group inbound rule for SSH.

### 4.3. Install Docker and Docker Compose

While the `harden-host.sh` script handles some basics, Docker and Docker Compose need to be installed separately. The official Docker documentation provides the most up-to-date instructions [3]. Here's a summary:

```bash
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  \"$(. /etc/os-release && echo "$VERSION_CODENAME")\" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update

# Install Docker Engine, containerd, and Docker Compose plugin
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Add your user to the docker group to run Docker commands without sudo
sudo usermod -aG docker $USER

# Apply the new group membership (you might need to log out and back in, or restart your SSH session)
newgrp docker

# Verify Docker installation
docker run hello-world
```

### 4.4. Install AWS CLI and `jq`

These are needed for the `aws_secrets_manager.sh` script.

```bash
sudo apt install awscli jq -y
```

### 4.5. Configure AWS CLI (Optional, for Secrets Manager)

If you plan to use AWS Secrets Manager, you'll need to configure the AWS CLI on your EC2 instance. This typically involves setting up an IAM role for the EC2 instance with permissions to access Secrets Manager, rather than storing credentials directly on the instance.

For testing purposes, you can configure it manually:

```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and default region
```

**Security Note**: For production, assign an IAM role to the EC2 instance with the necessary permissions to read secrets from AWS Secrets Manager. This is more secure than storing credentials directly.

## 5. Phase 3: Namecheap Domain Configuration

This phase connects your domain to your EC2 instance.

### 5.1. Create A Records

1.  Log in to your Namecheap account.
2.  Go to your **Domain List** and click **"Manage"** next to your domain.
3.  Navigate to the **"Advanced DNS"** tab.
4.  In the **"Host Records"** section, add the following records:
    *   **Type**: `A Record`, **Host**: `@`, **Value**: `<EC2_Public_IP>`
    *   **Type**: `A Record`, **Host**: `www`, **Value**: `<EC2_Public_IP>`
    *   **Type**: `A Record`, **Host**: `api`, **Value**: `<EC2_Public_IP>` (if you plan to expose a direct API subdomain)
    *   **Type**: `A Record`, **Host**: `status`, **Value**: `<EC2_Public_IP>` (for an optional status page)
5.  Click the green checkmark to save changes.

### 5.2. Verify DNS Propagation

DNS changes can take up to 30 minutes (or sometimes longer) to propagate globally [6]. You can check the propagation using online tools like `whatsmydns.net` or by running `dig <your_domain.com>` in your terminal.

## 6. Phase 4: GitHub Repository Setup

This phase sets up your source code management and CI/CD triggers.

### 6.1. Create a New GitHub Repository

1.  Go to GitHub and create a new private repository (e.g., `securedock-platform`).
2.  Do **not** initialize it with a README or license file.

### 6.2. Push SecureDock Project Code

From your local `securedock-platform` directory:

```bash
git init
git add .
git commit -m "Initial commit of SecureDock Platform"
git branch -M main
git remote add origin https://github.com/<YOUR_GITHUB_USERNAME>/securedock-platform.git
git push -u origin main
```

### 6.3. Configure GitHub Secrets

For your GitHub Actions workflows to function, you need to configure several repository secrets. Go to your GitHub repository **Settings > Secrets and variables > Actions > New repository secret** and add the following:

*   `EC2_HOST`: Your EC2 instance's Public IPv4 address.
*   `EC2_USERNAME`: `ubuntu` (or your EC2 user).
*   `EC2_SSH_KEY`: The **private key** content of your `.pem` file (copy-paste the entire content, including `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----`). **Ensure this is kept highly secure.**
*   `DOMAIN_NAME`: Your Namecheap domain (e.g., `securedock.example.com`).
*   `SEMGREP_APP_TOKEN`: Your Semgrep App Token (if you use Semgrep Cloud Platform for advanced features).
*   `SEMGREP_DEPLOYMENT_ID`: Your Semgrep Deployment ID.
*   `COSIGN_PRIVATE_KEY`: The private key for Cosign image signing. You'll need to generate this separately (e.g., `cosign generate-key-pair`). Store the private key here and the public key for verification.
*   `COSIGN_PASSWORD`: The password for your Cosign private key.

## 7. Phase 5: CI/CD Pipeline Execution (GitHub Actions)

Your CI/CD pipelines are now ready to run.

### 7.1. Trigger CI Workflow

Pushing code to `main` or opening a pull request will automatically trigger the `ci.yml` workflow. Monitor its execution in GitHub Actions.

This workflow performs:
*   Linting (Frontend/Backend).
*   SAST with Semgrep.
*   Secret scanning with Gitleaks.
*   Dockerfile linting with Hadolint.
*   Container image vulnerability scanning with Trivy.
*   **SBOM generation with Syft** for both frontend and backend images.
*   Builds Docker images.

Review the scan results in the GitHub Security tab (Code scanning alerts) and the workflow logs.

### 7.2. Trigger CD Workflow

The `deploy.yml` workflow is triggered on pushes to `main` or when a version tag (e.g., `v1.0.0`) is pushed.

To trigger a deployment:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

This workflow performs:
*   Logs into GitHub Container Registry (GHCR).
*   Builds and pushes Docker images to GHCR.
*   Generates **artifact attestations**.
*   **Signs images with Cosign**.
*   Deploys the application to your EC2 instance via SSH, executing the `deploy.sh` script.

Monitor the `deploy.yml` workflow in GitHub Actions. Ensure it completes successfully.

## 8. Phase 6: Post-Deployment Verification and Operations

After deployment, verify that everything is working as expected.

### 8.1. Verify Application Access

Open your web browser and navigate to your domain (e.g., `https://securedock.example.com`). You should see your frontend application. Test any backend API endpoints (e.g., `https://api.securedock.example.com/`).

### 8.2. Verify Nginx Configuration

Check that HTTPS is enforced, HTTP requests are redirected, and security headers are present. You can use browser developer tools or online security header checkers.

### 8.3. Verify Falco is Running

SSH into your EC2 instance and check Falco's status:

```bash
sudo systemctl status falco
```

Look for `active (running)`. You can also check Falco logs for any alerts:

```bash
sudo tail -f /var/log/syslog | grep falco
```

### 8.4. Basic Log Monitoring

Check Docker container logs:

```bash
sudo docker-compose -f /home/ubuntu/securedock-platform/compose/docker-compose.prod.yml logs -f
```

Check Nginx access and error logs:

```bash
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### 8.5. Test Backup and Rollback Scripts

**Backup:**

```bash
cd /home/ubuntu/securedock-platform/scripts
chmod +x backup.sh
sudo ./backup.sh
```

Verify that a backup file is created in `/var/backups/securedock/`.

**Rollback:**

To test rollback, you would typically deploy a known-bad version or an older version, then use the `rollback.sh` script with a previous Git SHA.

```bash
# Example: Rollback to a previous SHA (replace with an actual previous SHA)
cd /home/ubuntu/securedock-platform/scripts
chmod +x rollback.sh
sudo ./rollback.sh <PREVIOUS_GIT_SHA> <YOUR_DOMAIN_NAME>
```

Verify that the application reverts to the older version.

## 9. Conclusion and Next Steps

You have successfully deployed a DevSecOps-enabled application platform. This project provides a strong foundation for learning and demonstrating various DevSecOps practices.

**Next Steps:**

*   **Implement a real application**: Replace the placeholder frontend and backend with your actual application code.
*   **Enhance security**: Explore advanced Falco rules, integrate DAST tools like OWASP ZAP more deeply, and set up more robust secret management with AWS Secrets Manager and IAM roles.
*   **Monitoring and Alerting**: Set up Prometheus/Grafana or AWS CloudWatch for more comprehensive monitoring and alerting.
*   **Infrastructure as Code**: Migrate EC2 instance and security group creation to Terraform.
*   **Staging Environment**: Create a separate staging environment for testing before production deployments.

## References

[1]: https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/free-tier.html "Explore AWS services with AWS Free Tier - AWS Billing"
[2]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-security-groups.html "Amazon EC2 security groups for your EC2 instances"
[3]: https://docs.docker.com/engine/install/ubuntu/ "Install Docker Engine on Ubuntu"
[4]: https://docs.github.com/en/actions/use-cases-and-examples/publishing-packages/publishing-docker-images "Publishing Docker images - GitHub Docs"
[5]: https://trivy.dev/latest/docs/getting-started/installation/ "Installation - Trivy"
[6]: https://www.namecheap.com/support/knowledgebase/article.aspx/319/2237/how-can-i-set-up-an-a-address-record-for-my-domain/ "How can I set up an A (address) record for my domain? - Namecheap"
[7]: https://docs.sigstore.dev/cosign/overview/ "Cosign Documentation"
[8]: https://github.com/anchore/syft "Syft GitHub Repository"
[9]: https://falco.org/docs/ "Falco Documentation"
[10]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-methods.html "Connect to a Linux instance using EC2 Instance Connect - Amazon EC2"
