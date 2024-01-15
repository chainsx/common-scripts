#!/bin/sh

ARCH=$(arch)
TARGET=aarch64
ROOTFS=root
VERSION=jammy
SOFTADDR=http://mirrors.ustc.edu.cn/ubuntu-ports
MIRROR=http://mirrors.ustc.edu.cn

echo You are running this scipt on a $ARCH mechine....

if [ "$ARCH" != "$TARGET" ];then
sudo apt-get install qemu-user-static
else
echo "You are running this script on a aarch64 mechine, progress...."
fi

sudo apt install debootstrap debian-keyring
mkdir $ROOTFS
sudo debootstrap --foreign --no-check-gpg --arch=arm64 $VERSION ./$ROOTFS $SOFTADDR

if [ "$ARCH" != "$TARGET" ];then
sudo cp /usr/bin/qemu-aarch64-static $ROOTFS/usr/bin
else
echo "You are running this script on a aarch64 mechine, progress...."
fi

LC_ALL=C LANGUAGE=C LANG=C chroot ./$ROOTFS /debootstrap/debootstrap --second-stage
LC_ALL=C LANGUAGE=C LANG=C chroot ./$ROOTFS dpkg --configure -a

LC_ALL=C LANGUAGE=C LANG=C chroot ./$ROOTFS apt-get update
LC_ALL=C LANGUAGE=C LANG=C chroot ./$ROOTFS apt-get install -y sudo ssh net-tools ethtool wireless-tools network-manager iputils-ping rsyslog alsa-utils busybox kmod --no-install-recommends

#sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/' root/etc/apt/sources.list

cat <<EOF | chroot $ROOTFS adduser user && addgroup user adm && addgroup user sudo && addgroup user audio
user
user
pi
0
0
0
0
y
EOF

# 创建用户
# 用户名：user
# 密码：user

LC_ALL=C LANGUAGE=C LANG=C chroot $ROOTFS dpkg --add-architecture armhf
LC_ALL=C LANGUAGE=C LANG=C chroot $ROOTFS apt-get update
LC_ALL=C LANGUAGE=C LANG=C chroot $ROOTFS apt-get install libc6:armhf -y

chroot $ROOTFS apt clean

if [ "$ARCH" != "$TARGET" ];then
sudo rm $ROOTFS/usr/bin/qemu-aarch64-static
else
echo "You are running this script on a aarch64 mechine, progress...."
fi

echo '127.0.0.1	board' >> $ROOTFS/etc/hosts

cat /dev/null > $ROOTFS/etc/hostname
echo 'board' >> $ROOTFS/etc/hostname

echo "user ALL=(ALL) NOPASSWD: ALL" >> root/etc/sudoers.d/010_user-nopassword

cat /dev/null > $ROOTFS/etc/fstab

cat <<EOF >> $ROOTFS/etc/fstab
LABEL=boot      /boot           vfat    defaults          0       0
LABEL=rootfs    /               ext4    defaults,noatime  0       1
EOF

