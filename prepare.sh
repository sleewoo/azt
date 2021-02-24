
set -e

DISK=$1

if [ -z "$DISK" ]; then
  echo -e "\nPlease provide Disk ID\n"
  exit 1
fi

if [ ! -e $DISK ]; then
  echo -e "\n$DISK does not exists\n"
  exit 1
fi

mount -o remount,size=50% /run/archiso/cowspace
modprobe zfs

# sgdisk --zap-all             $DISK
# sgdisk -n2:1M:+256M -t2:EF00 $DISK # efi
# sgdisk -n5:0:+1791M -t5:8300 $DISK # boot
# sgdisk -n6:0:+12G   -t6:8300 $DISK # unused
# sgdisk -n7:0:+16G   -t7:8200 $DISK # swap
# sgdisk -n8:0:0      -t8:BF00 $DISK # system
# sleep 1

# creating main pool
zpool create -f   \
  -o ashift=12     \
  -O encryption=aes-256-gcm     \
  -O keylocation=prompt \
  -O keyformat=passphrase     \
  -O acltype=posixacl \
  -O canmount=off \
  -O compression=lz4     \
  -O dnodesize=auto \
  -O normalization=formD \
  -O relatime=on     \
  -O xattr=sa \
  -O mountpoint=/ \
  -R /mnt     \
  main $DISK-part8

# creating datasets
zfs create -o canmount=off -o mountpoint=none main/ROOT
zfs create -o canmount=noauto -o mountpoint=/ main/ROOT/default
zfs mount main/ROOT/default

zfs create                                 main/home
zfs create -o mountpoint=/root             main/home/root
zfs create -o canmount=off                 main/var
zfs create -o canmount=off                 main/var/lib
zfs create                                 main/var/log
zfs create                                 main/var/spool
zfs create -o com.sun:auto-snapshot=false  main/var/cache
zfs create -o com.sun:auto-snapshot=false  main/var/tmp
zfs create -o com.sun:auto-snapshot=false  main/var/lib/docker
zfs create -o com.sun:auto-snapshot=false  main/tmp

chmod 700 /mnt/root

chmod 1777 \
  /mnt/tmp \
  /mnt/var/tmp

# testing/validating zfs pool/datasets
zpool export main
zpool import -d /dev/disk/by-id -R /mnt main -N
zfs load-key main
zfs mount main/ROOT/default
zfs mount -a

# preparing boot partition
mkfs.ext4 $DISK-part5
mkdir -p /mnt/boot
mount $DISK-part5 /mnt/boot

# preparing EFI partition
mkdosfs -F 32 -s 1 -n EFI $DISK-part2
mkdir -p /mnt/efi
mount $DISK-part2 /mnt/efi

cp -av /.azt /mnt

echo -e "\nAll preparations done! Now run /.azt/install.sh\n"
