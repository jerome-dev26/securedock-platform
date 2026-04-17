#!/bin/bash

set -euo pipefail

echo "Starting EC2 host hardening..."

# 1. Update and upgrade packages
echo "Updating and upgrading packages..."
sudo apt update && sudo apt upgrade -y

# 2. Install UFW (Uncomplicated Firewall)
echo "Installing UFW..."
sudo apt install ufw -y

# Configure UFW rules
echo "Configuring UFW rules..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh # Allow SSH (port 22)
sudo ufw allow http # Allow HTTP (port 80)
sudo ufw allow https # Allow HTTPS (port 443)

# Enable UFW
sudo ufw --force enable
echo "UFW enabled and configured."

# 3. Install Fail2ban
echo "Installing Fail2ban..."
sudo apt install fail2ban -y

# Configure Fail2ban (create a local configuration file to override defaults)
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
# You might want to customize jail.local further, e.g., increase bantime, findtime

# Restart Fail2ban to apply changes
sudo systemctl enable fail2ban
sudo systemctl restart fail2ban
echo "Fail2ban installed and configured."

# 4. Disable password authentication for SSH (if not already done)
echo "Disabling SSH password authentication..."
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

# 5. Disable root login for SSH
echo "Disabling SSH root login..."
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config

# Restart SSH service to apply changes
sudo systemctl restart sshd
echo "SSH hardened."

# 6. Remove unnecessary packages (example)
# sudo apt autoremove -y

echo "EC2 host hardening complete."
