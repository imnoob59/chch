#!/bin/bash

# Function to display menu and get user choice
display_menu() {
    echo "Please select the Windows Server or Windows version:"
    echo "1. Windows 10 H"
    echo "2. Windows Server 2019"
    echo "3. Windows Server 2022"
    echo "4. Windows 10"
    read -p "Enter your choice: " choice
}

# Update package repositories and upgrade existing packages
apt-get update && apt-get upgrade -y

# Install QEMU and its utilities
apt-get install qemu -y
apt install qemu-utils -y
apt install qemu-system-x86-xen -y
apt install qemu-system-x86 -y
apt install qemu-kvm -y

echo "QEMU installation completed successfully."

# Get user choice
display_menu

case $choice in
    1)
        # Windows Server 2016
        img_file="windows10h.img"
        iso_link="https://store5.gofile.io/download/web/a8d24450-d1f9-4b0e-b8d4-a0c19c0b320d/Win10_EnglishInternational_x64.iso"
        iso_file="windows10h.iso"
        ;;
    2)
        # Windows Server 2019
        img_file="windows2019.img"
        iso_link="https://go.microsoft.com/fwlink/p/?LinkID=2195167&clcid=0x409&culture=en-us&country=US"
        iso_file="windows2019.iso"
        ;;
    3)
        # Windows Server 2022
        img_file="windows2022.img"
        iso_link="https://go.microsoft.com/fwlink/p/?LinkID=2195280&clcid=0x409&culture=en-us&country=US"
        iso_file="windows2022.iso"
        ;;
    4)
        # Windows 10
        img_file="windows10.img"
        iso_link="https://bit.ly/44u1H0G"
        iso_file="windows10.iso"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo "Selected version: $img_file"

# Create a raw image file with the chosen name
qemu-img create -f raw "$img_file" 40G

echo "Image file $img_file created successfully."

# Download Virtio driver ISO
wget -O virtio-win.iso 'https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.215-1/virtio-win-0.1.215.iso'

echo "Virtio driver ISO downloaded successfully."

# Download Windows ISO with the chosen name
wget -O "$iso_file" "$iso_link"

echo "Windows ISO downloaded successfully."
