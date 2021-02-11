
# reflector service is updating mirrorlist, disabling
systemctl stop reflector.service

# needed cause zfs-dkms does not compile with latest gcc at date
cat > /etc/pacman.d/mirrorlist <<"EOF"
Server = https://archive.archlinux.org/repos/2021/02/01/$repo/os/$arch
EOF

pacman -Syy
