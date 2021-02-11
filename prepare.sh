
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

# sgdisk --zap-all $DISK
# sgdisk -n2:1M:+512M  -t2:EF00 $DISK
# sgdisk -n3:0:+2G     -t3:8300 $DISK
# sgdisk -n4:0:+8G     -t4:8200 $DISK
# sgdisk -n5:0:0       -t5:BF00 $DISK
# sleep 3

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
  main $DISK-part5

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
mkfs.ext4 /dev/sda3
mkdir -p /mnt/boot
mount /dev/sda3 /mnt/boot

# preparing EFI partition
mkdosfs -F 32 -s 1 -n EFI /dev/sda2
mkdir -p /mnt/efi
mount /dev/sda2 /mnt/efi

cp -av /.azt /mnt

echo -e "\nAll preparations done! Now run /.azt/install.sh\n"
