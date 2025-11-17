#!/bin/bash
# Script to install Apache Tomcat on Ubuntu

# Variables
TOMCAT_VERSION=10.1.24
TOMCAT_USER=tomcat
INSTALL_DIR=/opt/tomcat

# Update system
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Java (required for Tomcat)
echo "Installing Java..."
sudo apt install default-jdk -y

# Create Tomcat user
echo "Creating Tomcat user..."
sudo useradd -m -U -d $INSTALL_DIR -s /bin/false $TOMCAT_USER

# Download Tomcat
echo "Downloading Tomcat..."
wget https://downloads.apache.org/tomcat/tomcat-10/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz -P /tmp

# Extract and move to install directory
echo "Installing Tomcat..."
sudo mkdir -p $INSTALL_DIR
sudo tar xf /tmp/apache-tomcat-$TOMCAT_VERSION.tar.gz -C $INSTALL_DIR
sudo mv $INSTALL_DIR/apache-tomcat-$TOMCAT_VERSION/* $INSTALL_DIR
sudo rm -rf $INSTALL_DIR/apache-tomcat-$TOMCAT_VERSION

# Set permissions
echo "Setting permissions..."
sudo chown -R $TOMCAT_USER:$TOMCAT_USER $INSTALL_DIR

# Create systemd service file
echo "Creating systemd service..."
sudo tee /etc/systemd/system/tomcat.service > /dev/null <<EOF
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking
User=$TOMCAT_USER
Group=$TOMCAT_USER
Environment="JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))"
Environment="CATALINA_PID=$INSTALL_DIR/temp/tomcat.pid"
Environment="CATALINA_HOME=$INSTALL_DIR"
Environment="CATALINA_BASE=$INSTALL_DIR"
ExecStart=$INSTALL_DIR/bin/startup.sh
ExecStop=$INSTALL_DIR/bin/shutdown.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start Tomcat
echo "Starting Tomcat service..."
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat

echo "Tomcat installation completed!"
echo "Access Tomcat at: http://<your-server-ip>:8080"
