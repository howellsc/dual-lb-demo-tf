#!/bin/bash
# Update the system
dnf update -y

# Install Apache (httpd)
dnf install httpd policycoreutils-python-utils -y

# REMOVE the default "Listen 80" from the main httpd.conf
# This prevents the "multiple Listeners" syntax error
sed -i 's/^Listen 80/# Listen 80/' /etc/httpd/conf/httpd.conf

# Configure Ports and VirtualHosts
# We must tell Apache to listen on 8500, 6500, and 6501 explicitly
cat <<EOF > /etc/httpd/conf.d/multi_port.conf
Listen 8500
Listen 6500
Listen 6501

<VirtualHost *:8500>
    DocumentRoot "/var/www/html/port8500"
    <Directory "/var/www/html/port8500">
        AllowOverride None
        Require all granted
    </Directory>
    ErrorDocument 200 "Response from $(hostname) running Rocky Linux on Port 90"
    RewriteEngine On
    RewriteRule ^.*$ - [R=200,L]
</VirtualHost>

<VirtualHost *:6500>
    DocumentRoot "/var/www/html/port6500"
    ErrorDocument 200 "Response from $(hostname) running Rocky Linux on Port 6500"
    RewriteEngine On
    RewriteRule ^.*$ - [R=200,L]
</VirtualHost>

<VirtualHost *:6501>
    DocumentRoot "/var/www/html/port6501"
    ErrorDocument 200 "Response from $(hostname) running Rocky Linux on Port 6501"
    RewriteEngine On
    RewriteRule ^.*$ - [R=200,L]
</VirtualHost>
EOF

# 3. Create dummy directories for the DocumentRoots
mkdir -p /var/www/html/port{8500,6500,6501}

semanage port -a -t http_port_t -p tcp 8500 || semanage port -m -t http_port_t -p tcp 8500
semanage port -a -t http_port_t -p tcp 6500 || semanage port -m -t http_port_t -p tcp 6500
semanage port -a -t http_port_t -p tcp 6501 || semanage port -m -t http_port_t -p tcp 6501

# Start and enable Apache
systemctl enable --now httpd

# Create a basic landing page
# echo "Hello from $(hostname) running Rocky Linux" > /var/www/html/index.html

# --- Local Firewall Configuration ---
# Open Port 8500 for the L7 Load Balancer
firewall-cmd --permanent --add-port=8500/tcp
# Open Port 6060 for your L4 Data Traffic
firewall-cmd --permanent --add-port=6060/tcp
# Open Port 6061 for your L4 Data Traffic
firewall-cmd --permanent --add-port=6061/tcp
# Reload to apply changes
firewall-cmd --reload