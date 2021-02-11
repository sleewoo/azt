
set -e

/.azt/update-repos.sh

# add packages to be installed (kernel and zfs packages will be installed automatically, do not add here)
pacstrap /mnt \
  base \
  grub \
  efibootmgr \
  iwd \
  networkmanager \
  broadcom-wl \
  openssh \
  vim \
  bash-completion \
  which \
;

echo `hostid` > /mnt/etc/hostid
echo -e "\nInstalled a brand new system! Now run /.azt/post-install.sh\n"

arch-chroot /mnt
