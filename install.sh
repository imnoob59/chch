#!/bin/bash
# Auto Install CachyOS + XFCE Desktop (With SSH Password Login)
# GitHub: https://github.com/[USERNAME]/cachyos-vps-installer

set -e  # Exit on error

# ===== KONFIGURASI =====
ISO_URL="https://mirror.cachyos.org/ISO/desktop/250422/cachyos-desktop-linux-250422.iso"
TARGET_DISK="/dev/vda"
USERNAME="masanto"
PASSWORD="@P3kunc3nn"
RDP_PORT="6969"

# ===== INSTALASI UTAMA =====
echo "📦 Writing ISO to disk ($TARGET_DISK)..."
wget -O- "$ISO_URL" | dd of="$TARGET_DISK" bs=4M status=progress

echo "⚙️ Mounting partition..."
mount "${TARGET_DISK}1" /mnt

# ===== SYSTEM CONFIGURATION =====
arch-chroot /mnt /bin/bash <<EOF
# User & password setup
useradd -m -G wheel "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$PASSWORD" | chpasswd

# Install packages
pacman -Syu --noconfirm xfce4 xfce4-goodies xrdp firefox

# RDP Configuration
sed -i "s/port=3389/port=$RDP_PORT/" /etc/xrdp/xrdp.ini
echo "exec startxfce4" > /home/$USERNAME/.xinitrc
chown $USERNAME:$USERNAME /home/$USERNAME/.xinitrc

# ===== SECURITY =====
# 1. SSH Configuration (WITH PASSWORD LOGIN)
sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config  # Modified line

# 2. Firewall setup
pacman -S --noconfirm ufw
ufw allow $RDP_PORT/tcp
ufw allow ssh
ufw --force enable

# 3. Enable services
systemctl enable xrdp sshd
EOF

# ===== CLEANUP =====
umount /mnt
echo "✅ Installation complete! System will reboot..."
echo "🔒 Security Features:"
echo "- SSH Root Login: DISABLED"
echo "- SSH Password Auth: ENABLED"
echo "- Firewall UFW: ACTIVE (port $RDP_PORT & 22 open)"
reboot
