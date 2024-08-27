
## NFS Server Installation and Configuration Guide

## Overview

This guide provides instructions on how to install an NFS server on Ubuntu using an automated script or manually. It also includes troubleshooting tips and client configuration for both Linux and Windows.

## Table of Contents

1. [Using the Installation Script](#using-the-installation-script)
2. [Manual Installation](#manual-installation)
3. [NFS Client Configuration](#nfs-client-configuration)
   - [Linux Client](#linux-client)
   - [Windows Client](#windows-client)
4. [Troubleshooting NFS](#troubleshooting-nfs)

## Using the Installation Script

### Prerequisites

- Ensure you have root or sudo privileges.
- Make sure the system is up to date.

### Installation Steps

1. **Download the script:**

   Save the following script as `nfs-server.sh`:

   \`\`\`bash
   #!/bin/bash
   # Script contents provided in the question.
   \`\`\`

2. **Make the script executable:**

   \`\`\`bash
   chmod +x nfs-server.sh
   \`\`\`

3. **Run the script:**

   \`\`\`bash
   sudo ./nfs-server.sh
   \`\`\`

4. **Choose your options:**

   - Option 1: Install the NFS server and add mount points during installation.
   - Option 2: Add new mount points to an existing NFS server.
   - Option 3: Exit the script.

### Notes:

- If the script is rerun, it will not overwrite existing NFS configurations.
- The script will handle the creation of directories, setting permissions, and configuring the `/etc/exports` file.

## Manual Installation

### Step 1: Install the NFS Server

1. **Update your system:**

   \`\`\`bash
   sudo apt-get update
   sudo apt-get upgrade -y
   \`\`\`

2. **Install NFS server packages:**

   \`\`\`bash
   sudo apt-get install nfs-kernel-server -y
   \`\`\`

3. **Start and enable the NFS service:**

   \`\`\`bash
   sudo systemctl start nfs-kernel-server
   sudo systemctl enable nfs-kernel-server
   \`\`\`

### Step 2: Configure Exported Directories

1. **Create directories for sharing:**

   \`\`\`bash
   sudo mkdir -p /mnt/nfs_share_linux
   sudo chown nobody:nogroup /mnt/nfs_share_linux
   sudo chmod 777 /mnt/nfs_share_linux
   \`\`\`

2. **Edit the `/etc/exports` file:**

   Add the following lines to the `/etc/exports` file to configure NFS shares:

   \`\`\`bash
   /mnt/nfs_share_linux *(rw,sync,no_root_squash,insecure,no_subtree_check)
   /mnt/nfs_share_windows 192.168.1.0/24(rw,sync,no_root_squash,all_squash,anonuid=65534,anongid=65534)
   \`\`\`

3. **Export the NFS shares:**

   \`\`\`bash
   sudo exportfs -a
   sudo exportfs -v
   \`\`\`

### Step 3: Firewall Configuration

If IPTables, UFW, or any other firewall is active, ensure that the necessary ports are open:

- **For NFS:**
  - TCP/UDP 2049 (NFS)
  - TCP/UDP 111 (RPCBind)

### Step 4: Verify the NFS Server Status

\`\`\`bash
sudo systemctl status nfs-kernel-server
\`\`\`

## NFS Client Configuration

### Linux Client

1. **Install NFS client:**

   \`\`\`bash
   sudo apt-get install nfs-common -y
   \`\`\`

2. **Mount the NFS share:**

   \`\`\`bash
   sudo mount -t nfs <server_ip>:/mnt/nfs_share_linux /mnt/local_mount_point
   \`\`\`

3. **To make the mount persistent across reboots, add the following to `/etc/fstab`:**

   \`\`\`bash
   <server_ip>:/mnt/nfs_share_linux /mnt/local_mount_point nfs defaults 0 0
   \`\`\`

### Windows Client

1. **Enable NFS client:**

   - Go to `Control Panel -> Programs -> Turn Windows features on or off`.
   - Check `Services for NFS`.

2. **Mount the NFS share:**

   \`\`\`cmd
   mount \\<server_ip>\mnt\nfs_share_windows Z:
   \`\`\`

3. **Map the NFS share as a network drive:**

   - Open `This PC`.
   - Click on `Map Network Drive`.
   - Enter `\\<server_ip>\mnt\nfs_share_windows`.

## Troubleshooting NFS

### Common Issues

1. **Exportfs reports "No file systems exported":**

   - Ensure that the `/etc/exports` file is correctly configured.
   - Run `sudo exportfs -a` and check for errors.

2. **Permissions errors:**

   - Verify that the shared directory permissions are set to allow NFS access.
   - Use `sudo chown nobody:nogroup` and `sudo chmod 777` for troubleshooting.

3. **Firewall blocking NFS:**

   - Make sure the necessary ports (2049, 111) are open in the firewall.
   - Use `sudo ufw allow from <client_ip> to any port 2049` to allow NFS access.

4. **NFS client unable to mount:**

   - Verify that the NFS server is running with `sudo systemctl status nfs-kernel-server`.
   - Ensure the correct network block or IP is specified in the `/etc/exports` file.

### Logs and Debugging

- **Check NFS logs:**

  \`\`\`bash
  sudo journalctl -xe | grep nfs
  \`\`\`

- **Verify exported file systems:**

  \`\`\`bash
  sudo exportfs -v
  \`\`\`
