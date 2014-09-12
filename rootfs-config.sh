#!/bin/sh
# see: http://www.acmesystems.it/emdebian_grip_armhf

#Target directory for the rootfs chroot image
TARGET_ROOTFS_DIR="rootfs"

#Directories used to mount some microSD partitions 
echo "Create mount directories"
mkdir $TARGET_ROOTFS_DIR/media/mmc_p1
mkdir $TARGET_ROOTFS_DIR/media/data

#Set the target board hostname
filename=$TARGET_ROOTFS_DIR/etc/hostname
echo Creating $filename
echo isrtc > $filename

#Set the defalt name server
filename=$TARGET_ROOTFS_DIR/etc/resolv.conf
echo Creating $filename
echo nameserver 8.8.8.8 > $filename
echo nameserver 8.8.4.4 >> $filename

#Set the default network interfaces
filename=$TARGET_ROOTFS_DIR/etc/network/interfaces
echo Updating $filename
echo allow-hotplug eth0 eth1 >> $filename
echo iface eth0 inet dhcp >> $filename
echo hwaddress ether 00:04:25:12:34:56 >> $filename
echo iface eth1 inet dhcp >> $filename
echo hwaddress ether 00:04:25:23:45:67 >> $filename

#Set a terminal to the debug port
filename=$TARGET_ROOTFS_DIR/etc/inittab
echo Updating $filename
echo T0:2345:respawn:/sbin/getty -L ttyS0 115200 vt100 >> $filename

#Set how to mount the microSD partitions
filename=$TARGET_ROOTFS_DIR/etc/fstab
echo Creating $filename
echo /dev/mmcblk0p1 /boot vfat noatime 0 1 > $filename
echo /dev/mmcblk0p2 / ext4 noatime 0 1 >> $filename
echo /dev/mmcblk0p3 /media/data ext4 noatime 0 1 >> $filename
echo proc /proc proc defaults 0 0 >> $filename

#Add Debian security repository
filename=$TARGET_ROOTFS_DIR/etc/apt/sources.list
echo Creating $filename
echo deb http://security.debian.org/ wheezy/updates main  >> $filename

#Add the standard Debian non-free repositories useful to load
#closed source firmware (i.e. WiFi dongle firmware)
echo deb http://http.debian.net/debian/ wheezy main contrib non-free >> $filename

