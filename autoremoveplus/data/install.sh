#!/bin/bash

# Update and upgrade the system
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker with the recommended installation script
curl -fsSL https://get.docker.com | sh

# Add Docker repository to enable automatic updates
sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable'

# Start and enable Docker service
sudo systemctl start docker && sudo systemctl enable docker

# Install Samba
sudo apt-get install -y samba

# Create user jack with password
sudo smbpasswd -a jack && sudo smbpasswd -a -s

# Add storage share to smb.conf
sudo tee -a /etc/samba/smb.conf <<EOF
[storage]
  comment = Storage Share
  path = /mnt/storage
  browseable = yes
  writable = yes
  force user = jack
  force group = jack
  create mask = 0777
  directory mask = 0777
EOF

# Test smb.conf for errors
if ! sudo testparm; then
  echo "Error: smb.conf is invalid. Exiting."
  exit 1
fi

# Restart and enable Samba service
sudo service smbd restart && sudo systemctl enable smbd && sudo systemctl start smbd
