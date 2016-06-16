#!/bin/bash

# Wipes the whole device and creates a FAT32 partition
# Must be run with root privileges
#
# Usage example:
# 	sudo format.sh /dev/sdb

if [[ $# -eq 0 ]] ; then
    echo 'Please specify a device'
    exit 0
fi

TARGET_DEV=$1

umount ${TARGET_DEV}* 2> /dev/null

dd if=/dev/zero of=${TARGET_DEV} bs=512 count=1

parted $TARGET_DEV mklabel msdos
parted $TARGET_DEV mkpart primary fat32 0% 100%

/sbin/udevadm settle --exit-if-exists=${TARGET_DEV}1 && mkfs -t vfat ${TARGET_DEV}1
