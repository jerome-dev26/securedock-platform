#!/bin/bash

set -euo pipefail

echo "Starting EC2 host hardening and essential software installation..."

# 1. Update and Upgrade System Packages
echo "Updating and upgrading system packages..."
sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y

# 2. Install UFW (Uncomplicated Firewall) and configure basic rules
echo "Installing and configuring UFW..."
sudo apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh # Allows SSH on default port 22
sudo ufw allow http # Allows HTTP on default port 80
sudo ufw allow https # Allows HTTPS on default port 443
sudo ufw --force enable
sudo ufw status verbose

# 3. Install Fail2ban
echo "Installing Fail2ban..."
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# 4. Secure SSH Configuration
echo "Securing SSH configuration..."
# Disable password authentication
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
# Disable root login
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
# Allow only key-based authentication (ensure your key is working before this!)
sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config

sudo systemctl restart sshd

# 5. Install Falco for Runtime Security Monitoring
echo "Installing Falco for runtime security monitoring..."
# Add the Falco GPG key
curl -s https://falco.org/repo/falcosecurity-3672BA8F.asc | sudo gpg --dearmor -o /usr/share/keyrings/falco-archive-keyring.gpg
# Add the Falco repository
echo "deb [signed-by=/usr/share/keyrings/falco-archive-keyring.gpg] https://download.falco.org/packages/deb stable main" | sudo tee /etc/apt/sources.list.d/falco-stable.list
# Update apt and install Falco
sudo apt update -y
sudo apt install falco -y

# Verify Falco installation
sudo systemctl status falco
sudo falco --version

echo "EC2 host hardening and essential software installation complete."
