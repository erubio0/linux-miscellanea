#!/bin/bash
#
# Simple utility for formatting removable devices with a FAT32 partition. Uses Zenity for dialogs if available, or Whiptail instead.
#
# Installation instructions (including download & applications menu entry creation):
#
#	cd /usr/local/bin && sudo wget -O format.sh https://github.com/erubio0/linux-miscellanea/raw/master/format.sh && sudo chmod 755 format.sh && sudo sh -c "grep -A7 begin\_ format.sh | sed -e 's/^# //' -e 1d > /usr/share/applications/format.desktop"
#
# Uninstallation instructions:
#
#	sudo rm /usr/share/applications/format.desktop /usr/local/bin/format.sh
#
#_.desktop file begin_
# [Desktop Entry]
# Type=Application
# Name=Format
# Comment=Removable devices format utility
# Exec=/usr/local/bin/format.sh
# Terminal=true
# Categories=Utility;
#_file end_

# Removable devices detection script taken from: http://unix.stackexchange.com/a/60335
REMOVABLE_DEVS=$(
	grep -Hv ^0$ /sys/block/*/removable |
	sed s/removable:.*$/device\\/uevent/ |
	xargs grep -H ^DRIVER=sd |
	sed s/device.uevent.*$/size/ |
	xargs grep -Hv ^0$ |
	cut -d / -f 4
)

if [ "$REMOVABLE_DEVS" == "" ]; then
	zenity --error --text="No removable devices found" 2> /dev/null || \
	whiptail --title "Error" --msgbox "No removable devices found" 8 50
	exit 0
fi

DEVICES=()

for DEV in $REMOVABLE_DEVS; do
	MODEL=`sed -e s/\ *$//g </sys/block/${DEV}/device/model`
	DEVICES=("${DEVICES[@]}" $DEV)
	DEVICES=("${DEVICES[@]}" "$MODEL")
done

if hash zenity 2>/dev/null; then
	TARGET_DEV=$(zenity --list --title="Device selection" --text="WARNING!! All data will be lost!\nChoose the device you want to format" --column="Device" --column="Model" "${DEVICES[@]}" 2> /dev/null)
	exitstatus=$?
else
	TARGET_DEV=$(whiptail --title "Device selection" --menu "\n             WARNING!! All data will be lost!\n           Choose the device you want to format" 15 60 $(( ${#DEVICES[@]} / 2 )) "${DEVICES[@]}" 3>&1 1>&2 2>&3)
	exitstatus=$?
fi

if [ $exitstatus = 0 ] && [ "$TARGET_DEV" != "" ]; then
	TARGET_DEV="/dev/${TARGET_DEV}"
	if hash zenity 2>/dev/null; then
		SUDO_PWD=$(zenity --forms --title "Authentication required" --text="Please authenticate to provide administrative privileges" --add-password="[sudo] Password for user $USER" 2> /dev/null)
		exitstatus=$?
	else
		SUDO_PWD=$(whiptail --title "Authentication required" --passwordbox "\nPlease authenticate to provide administrative privileges\n\n[sudo] Password for user $USER:" 10 60 3>&1 1>&2 2>&3)
		exitstatus=$?
	fi
	if [ $exitstatus = 0 ]; then
		if ! sudo -kSp '' [ 1 ] <<< $SUDO_PWD 2>/dev/null
		then
			zenity --error --text="Invalid password" 2> /dev/null || whiptail --title "Error" --msgbox "Invalid password" 8 50
			exit 1
		fi
		(
			sudo -Sp '' umount ${TARGET_DEV}* <<< $SUDO_PWD 2> /dev/null
			echo "25"; echo "# Erasing current partition table..."
			sudo dd if=/dev/zero of=${TARGET_DEV} bs=512 count=1 2> /dev/null
			echo "50"; echo "# Creating new partition..."
			sudo parted $TARGET_DEV mklabel msdos 2> /dev/null
			sudo parted $TARGET_DEV mkpart primary fat32 0% 100% 2> /dev/null
			echo "75"; echo "# Formatting new partition..."
			sudo /sbin/udevadm settle --exit-if-exists=${TARGET_DEV}1 && sudo mkfs -t vfat ${TARGET_DEV}1 2> /dev/null
			echo "100"; echo "# Operation finished"
		) | ( zenity --progress percentage=0 2> /dev/null || whiptail --gauge "Formatting device..." 6 60 0 )
	else
	    exit 0
	fi
else
    exit 0
fi
