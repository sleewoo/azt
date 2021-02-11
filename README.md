
# AZT

### A very opinionated template for installing ArchLinux on ZFS Root

- Step 01: Build custom ISO

    Boot an ISO image from https://archlinux.org/download/ (make sure to have at least 8GB RAM).

    Inside booted system:

    ```
    git clone https://github.com/sleewoo/azt.git
    ./azt/archiso-builder.sh
    ```

    If everything went well the ISO written to `/.azt/out/archlinux-DATE-ARCH.iso` file.

- Step 02: Install

    Boot custom ISO built in previous step.

    Edit `/.azt/prepare.sh` to adjust disk partitioning, `zfs` pools/datasets etc.

    Edit `/.azt/install.sh` to adjust packages to be installed.

    Run `/.azt/prepare.sh /dev/disk/by-id/DISK_ID`

    After `prepare` success run `/.azt/install.sh`

    If everything went well the script will be chrooted into freshly installed system.

    Inside chroot run `/.azt/post-install.sh` to finalize installation.

    After `post-install` success type `exit` or `Ctrl-D` to exit chroot.

    At the final run `/.azt/reboot.sh` to properly teardown and boot into the new system!
