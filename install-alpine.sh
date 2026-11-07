#!/bin/sh
# wget -qO- https://raw.githubusercontent.com/adamflorizone/scripts/refs/heads/main/install-alpine.sh | sh

TARGET_DISK="/dev/sda"

# 1. Check if the drive has any existing partitions
if lsblk -nlo TYPE "$TARGET_DISK" 2>/dev/null | grep -q "part"; then
    echo "ABORT: $TARGET_DISK is not empty. Existing partitions found."
    exit 1
fi

echo "Drive $TARGET_DISK is empty. Proceeding with installation..."

# 2. Generate the answerfile with your GitHub SSH keys
cat << 'EOF' > /tmp/alpine-answers
KEYMAPOPTS="us us"
HOSTNAMEOPTS="-n my-alpine"
INTERFACESOPTS="auto lo
iface lo inet loopback
auto eth0
iface eth0 inet dhcp"
DNSOPTS="-d local"
TIMEZONEOPTS="-z UTC"
PROXYOPTS="none"
APKREPOSOPTS="-1"
NTPOPTS="-c chrony"
SSHDOPTS="-c openssh"
ROOTSSHKEY="https://github.com/adamflorizone.keys"
DISKOPTS="-m sys /dev/sda"
EOF

# 3. Run the installer to wipe the disk and install
export ERASE_DISKS="$TARGET_DISK"
setup-alpine -e -f /tmp/alpine-answers

# 4. Mount the new system and secure SSH
mkdir -p /mnt/target
mount "${TARGET_DISK}3" /mnt/target

mkdir -p /mnt/target/etc/ssh/sshd_config.d
# Inject the comprehensive SSH security configuration
cat << 'EOF_SSH' > /mnt/target/etc/ssh/sshd_config.d/00-custom-security.conf
PasswordAuthentication no
KbdInteractiveAuthentication no
UseDNS no
EOF_SSH

umount /mnt/target
echo "Installation secure and complete. Rebooting..."
reboot
