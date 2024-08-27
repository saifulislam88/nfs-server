#!/bin/bash

# Function to install NFS server and optionally add mount points
install_nfs_server_and_add_mount() {
  echo "Installing NFS server..."
  sudo apt-get update
  sudo apt install net-tools -y
  sudo apt install nfs-kernel-server -y
  sudo systemctl start nfs-kernel-server
  sudo systemctl enable nfs-kernel-server
  echo "NFS server installed and started."

  # Option to create a Linux mount point
  read -p "Do you want to create a Linux mount point? (y/n): " linux_choice
  if [[ $linux_choice == "y" ]]; then
    linux_directory=$(create_directory "Linux" "linux")
    linux_network_block=$(get_network_block "Linux")
    echo "$linux_directory $linux_network_block(rw,sync,no_root_squash,insecure,no_subtree_check)" | sudo tee -a /etc/exports
  fi

  # Option to create a Windows mount point
  read -p "Do you want to create a Windows mount point? (y/n): " windows_choice
  if [[ $windows_choice == "y" ]]; then
    windows_directory=$(create_directory "Windows" "windows")
    windows_network_block=$(get_network_block "Windows")
    echo "$windows_directory $windows_network_block(rw,sync,no_root_squash,all_squash,anonuid=65534,anongid=65534)" | sudo tee -a /etc/exports
  fi
}

# Function to prompt for creating a directory
create_directory() {
  read -p "Enter the directory name for $1 mount point (e.g., /mnt/nfs_share_$2): " directory
  directory=$(echo "$directory" | xargs) # Trim any leading/trailing whitespace
  sudo mkdir -p "$directory"
  sudo chown nobody:nogroup "$directory"
  sudo chmod 777 "$directory"
  echo "$directory"
}

# Function to prompt for network block with hints
get_network_block() {
  read -p "Enter the network block for $1 (e.g., * for all, 192.168.0.0/24): " network_block
  echo "$network_block"  # No quotes, to ensure `*` is treated correctly by NFS
}

# Function to add additional mount points after installation
add_mount_point() {
  # Option to create a Linux mount point
  read -p "Do you want to create a Linux mount point? (y/n): " linux_choice
  if [[ $linux_choice == "y" ]]; then
    linux_directory=$(create_directory "Linux" "linux")
    linux_network_block=$(get_network_block "Linux")
    echo "$linux_directory $linux_network_block(rw,sync,no_root_squash,insecure,no_subtree_check)" | sudo tee -a /etc/exports
  fi

  # Option to create a Windows mount point
  read -p "Do you want to create a Windows mount point? (y/n): " windows_choice
  if [[ $windows_choice == "y" ]]; then
    windows_directory=$(create_directory "Windows" "windows")
    windows_network_block=$(get_network_block "Windows")
    echo "$windows_directory $windows_network_block(rw,sync,no_root_squash,all_squash,anonuid=65534,anongid=65534)" | sudo tee -a /etc/exports
  fi
}

# Function to handle script options
handle_options() {
  echo "Select an option:"
  echo "1. Install NFS server and add mount points"
  echo "2. Add new mount points"
  echo "3. Exit"
  read -p "Enter your choice [1-3]: " choice
  case $choice in
    1)
      install_nfs_server_and_add_mount
      ;;
    2)
      add_mount_point
      ;;
    3)
      exit 0
      ;;
    *)
      echo "Invalid choice. Exiting."
      exit 1
      ;;
  esac
}

# Run the selected option
handle_options

# Start and enable NFS server
sudo systemctl start nfs-kernel-server
sudo systemctl enable nfs-kernel-server

# Export the file systems
sudo exportfs -a
sudo exportfs -avr
sudo exportfs -v

# Display status of NFS server
sudo systemctl status nfs-kernel-server --no-pager

echo -e "\e[31mCaution: If IPTables/Firewall/UFW is active on this NFS server, ensure that NFS ports are added to the rules. Alternatively, disable IPTables/Firewall/UFW permanently if it is not required.\e[0m"

