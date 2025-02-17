#!/bin/bash

# Update the apt package index
sudo apt update

# Install packages to allow apt to use a repository over HTTPS
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release -y

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable Docker repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the apt package index again
sudo apt update

# Install the latest version of Docker Engine and containerd
sudo apt install docker-ce docker-ce-cli containerd.io -y

# Create container for database
sudo docker compose -f docker-compose-db.yaml up -d

# Create container for application
export BACKEND_PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
sudo sed -i "s/BACKEND_PUBLIC_IP/$BACKEND_PUBLIC_IP/g" docker-compose-app.yaml
sudo docker compose -f docker-compose-app.yaml up -d
