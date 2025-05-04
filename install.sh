#!/bin/bash
# Auto Install CachyOS + XFCE Desktop
# GitHub: https://github.com/[USERNAME]/cachyos-vps-installer

set -e  # Exit on error

# Konfigurasi (sesuaikan jika perlu)
ISO_URL="https://mirror.cachyos.org/ISO/desktop/250422/cachyos-desktop-linux-250422.iso"
TARGET_DISK="/dev/vda"
USERNAME="masanto"
PASSWORD="@P3kunc3nn"
RDP_PORT="6969"

# Langkah 1: Tulis ISO ke disk
echo "📦 Menulis ISO ke disk ($TARGET_DISK)..."
wget -O- "$ISO_URL" | dd of="$TARGET_DISK" bs=4M status=progress

# Langkah 2: Konfigurasi sistem
echo "⚙️ Konfigurasi user dan desktop..."
mount "${TARGET_DISK}1" /mnt

arch-chroot /mnt /bin/bash <<EOF
# Setup user & password
useradd -m -G wheel "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$PASSWORD" | chpasswd

# Install paket
pacman -Syu --noconfirm xfce4 xfce4-goodies xrdp firefox

# Konfigurasi RDP
sed -i "s/port=3389/port=$RDP_PORT/" /etc/xrdp/xrdp.ini
echo "exec startxfce4" > /home/$USERNAME/.xinitrc
chown $USERNAME:$USERNAME /home/$USERNAME/.xinitrc

# Enable services
systemctl enable xrdp sshd
EOF

# Bersihkan dan reboot
umount /mnt
echo "✅ Instalasi selesai! Sistem akan reboot..."
reboot
