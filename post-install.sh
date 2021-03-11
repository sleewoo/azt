
set -e

/.azt/update-repos.sh

cat >> /etc/pacman.conf <<EOF
[azt]
SigLevel = Optional TrustAll
Server = file:///.azt/repos
EOF

pacman -Sy

# do not edit linux package, instead consider to update it after install
! pacman -S --noconfirm \
  linux \
  linux-headers \
  zfs-dkms

echo "`sed '/\[azt\]/,$d' < /etc/pacman.conf`" > /etc/pacman.conf

[ $? -eq 0 ] || exit $?

modprobe zfs

# this file is included in initramfs so generate it before mkinitcpio
zpool set cachefile=/etc/zfs/zpool.cache main

# add zfs to hooks and generate initramfs
sed 's/^HOOKS/#HOOKS/;1s/^/\nHOOKS=(base udev autodetect modconf block keyboard consolefont zfs filesystems)\n\n/' -i /etc/mkinitcpio.conf
mkinitcpio -P

mkdir -p /boot/grub

sed 's|^GRUB_CMDLINE_LINUX|#GRUB_CMDLINE_LINUX|;1s|^|\nGRUB_CMDLINE_LINUX_DEFAULT="loglevel=3"\nGRUB_CMDLINE_LINUX="root=ZFS=main/ROOT/default"\n|' -i /etc/default/grub

ZPOOL_VDEV_NAME_PATH=1 grub-mkconfig -o /boot/grub/grub.cfg

grub-install \
  --target=x86_64-efi \
  --efi-directory=/efi \
  --bootloader-id=default \
  --recheck

mkswap /dev/sda7

cat >> /etc/fstab <<EOF
# uncomment line below to enable swap
# UUID=`ls -l /dev/disk/by-uuid | grep /sda7 | cut -d' ' -f9` none swap defaults,discard 0 0
EOF

! sed '1s/^/en_US.UTF-8 UTF-8\n/' -i /etc/locale.gen
! locale-gen

cat > /etc/locale.conf <<EOF
LANG=en_US.UTF-8
EOF

cat > /etc/vconsole.conf <<EOF
FONT=ter-c28b
EOF

# uncomment to fix uncontrolled wake on MBP
#cat >> /etc/tmpfiles.d/100-fix-wake.conf <<EOF
##    Path                  Mode UID  GID  Age Argument
#w    /proc/acpi/wakeup     -    -    -    -   XHC1LID0
#EOF

systemctl enable zfs-import-cache
systemctl enable zfs-import.target
systemctl enable zfs-mount
systemctl enable zfs.target

systemctl enable NetworkManager

passwd

echo -e "\nDone! Now type exit or Ctrl-D to exit chroot and then run /.azt/reboot.sh\n"
