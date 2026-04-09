#!/bin/bash
# Update the system
dnf update -y

# Install Apache (httpd)
dnf install httpd -y

# Start and enable Apache
systemctl enable --now httpd

# Create a basic landing page
echo "Hello from $(hostname) running Rocky Linux" > /var/www/html/index.html

# --- Local Firewall Configuration ---
# Open Port 80 for the L7 Load Balancer
firewall-cmd --permanent --add-service=http
# Open Port 6060 for your L4 Data Traffic
firewall-cmd --permanent --add-port=6060/tcp
# Reload to apply changes
firewall-cmd --reload