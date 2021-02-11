
set -e

# cleanup
rm -fr /mnt/.azt

umount /mnt/efi
umount /mnt/boot
umount -l /mnt/dev

zfs umount -a
zfs umount main/ROOT/default

zpool export main

reboot
