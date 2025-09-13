#!/bin/bash -ex

# Update & Upgrade OS
apt-get update -y
apt-get upgrade -y

# Install unzip (needed for AWS CLI)
apt-get install -y unzip

# Install AWS CLI v2
echo "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws/

# Install Docker
echo "Installing Docker..."
apt-get install -y docker.io
usermod -aG docker ubuntu
newgrp docker
systemctl enable docker
systemctl start docker

# Install Java JDK (for Jenkins) – use stable LTS
echo "Installing OpenJDK 17..."
apt-get install -y openjdk-17-jdk
java -version

# Install Jenkins
echo "Installing Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

apt-get update -y
apt-get install -y jenkins

# Post Installation
echo "Installation complete!"
