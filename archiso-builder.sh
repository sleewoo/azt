
set -e

src="$(cd `dirname $BASH_SOURCE[0]`; pwd)"

mkdir -p /.azt
cd       /.azt
cp -fv   "$src"/*.sh .

# make sure to have at least 8GB RAM,
# building archiso needs around 5GB
mount -o remount,size=75% /run/archiso/cowspace

./update-repos.sh

pacman -S --noconfirm \
  archiso \
  wget

cp -a /usr/share/archiso/configs/releng .

mkdir -p repos

wget -P repos https://archzfs.com/archzfs/x86_64/zfs-dkms-2.0.2-1-x86_64.pkg.tar.zst
wget -P repos https://archzfs.com/archzfs/x86_64/zfs-utils-2.0.2-1-x86_64.pkg.tar.zst

repo-add repos/azt.db.tar.gz repos/*.pkg.tar.zst

cat >> releng/pacman.conf <<EOF
[azt]
SigLevel = Optional TrustAll
Server = file:///.azt/repos
EOF

cat >> releng/packages.x86_64 <<EOF
linux-headers
zfs-dkms
EOF

mkdir             releng/airootfs/.azt
cp -av *.sh repos releng/airootfs/.azt

mkarchiso -v releng
