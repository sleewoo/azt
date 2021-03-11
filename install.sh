
set -e

/.azt/update-repos.sh

# add packages to be installed (kernel and zfs packages will be installed automatically, do not add here)
pacstrap /mnt \
  base \
  grub \
  efibootmgr \
  linux-firmware \
  networkmanager \
  git \
  openssh \
  vim \
  bash-completion \
  sudo \
  which \
  terminus-font \
;

echo `hostid` > /mnt/etc/hostid
echo -e "\nInstalled a brand new system! Now run /.azt/post-install.sh\n"

arch-chroot /mnt
