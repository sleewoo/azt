
set -e

/.azt/update-repos.sh

cat >> /etc/pacman.conf <<EOF
[azt]
SigLevel = Optional TrustAll
Server = file:///.azt/repos
EOF

pacman -Sy

! pacman -S --noconfirm \
  linux-lts \
  linux-lts-headers \
  zfs-dkms

echo "`sed '/\[azt\]/,$d' < /etc/pacman.conf`" > /etc/pacman.conf

[ $? -eq 0 ] || exit $?

modprobe zfs

# this file is included in initramfs so generate it before mkinitcpio
zpool set cachefile=/etc/zfs/zpool.cache main

# add zfs to hooks and generate initramfs
sed 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base udev autodetect modconf block keyboard zfs filesystems)/' -i /etc/mkinitcpio.conf
mkinitcpio -P

mkdir -p /boot/grub

sed 's|GRUB_CMDLINE_LINUX=""|GRUB_CMDLINE_LINUX="root=ZFS=main/ROOT/default"|' -i /etc/default/grub

ZPOOL_VDEV_NAME_PATH=1 grub-mkconfig -o /boot/grub/grub.cfg

grub-install \
  --target=x86_64-efi \
  --efi-directory=/efi \
  --bootloader-id=default \
  --recheck

mkswap /dev/sda4
swapon /dev/sda4

systemctl enable zfs-import-cache
systemctl enable zfs-import.target
systemctl enable zfs-mount
systemctl enable zfs.target

systemctl enable NetworkManager
systemctl enable systemd-resolved

passwd

echo -e "\nDone! Now type exit or Ctrl-D to exit chroot and then run /.azt/reboot.sh\n"
