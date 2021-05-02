#!/bin/bash

                        ######
#    # ###### #    #    #     #  ####   ####  #####
##   # #      #    #    #     # #    # #    #   #
# #  # #####  #    #    ######  #    # #    #   #
#  # # #      # ## #    #   #   #    # #    #   #
#   ## #      ##  ##    #    #  #    # #    #   #
#    # ###### #    #    #     #  ####   ####    #

UEFI=1
BIOS=2

DELL=1
OTHER=2

INTEL=1
NVIDIA=2
NOUVEAU=3

#disk
DISK=$(cat disk.txt)
#bootlayout
BOOTLAYOUT=$(cat bootlayout.txt)
#efi folder name
EFI=$(cat efi.txt)

#Austian time zone time
ln -sf /usr/share/zoneinfo/Europe/Vienna /etc/localtime
hwclock --systohc

#Generating locales
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_AT.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

#network configuration
echo Enter the hostname here:
read HOSTNAME
echo $HOSTNAME >/etc/hostname
echo -e "127.0.0.1 \tlocalhost \n::1 \t\tlocalhost \n127.0.1.1 \t$HOSTNAME.localdomain $HOSTNAME" >>/etc/hosts
#pacman update database
pacman -Syu

#GRUB
pacman -S grub os-prober
os-prober
#bootloader for UEFI with GPT
if [ $BOOTLAYOUT = $UEFI ]; then
    pacman -S efibootmgr
    clear
    #which pc
    echo -e "1: UEFI for Dell \n2: UEFI for other"
    read BRAND
    #dell pc
    if [ $BRAND = $DELL ]; then
        grub-install --target=x86_64-efi --efi-directory=/$EFI --removable
    #other pc
    elif [ $BRAND = $OTHER ]; then
        grub-install --target=x86_64-efi --efi-directory=/$EFI --bootloader-id=GRUB
    fi
#bootloader for BIOS with MBR
elif [ $BOOTLAYOUT = $BIOS ]; then
    grub-install --target=i386-pc $DISK
fi
#grub main configuration
grub-mkconfig -o /boot/grub/grub.cfg
clear

echo "Now the installation of the bootable system is done!
So let's move on the user configuration."
echo Enter password for root:
passwd
clear
#new user
echo new username:
read USERNAME
useradd -m $USERNAME -G users,wheel,audio,video,power
#passwor for new user
echo Enter password for new user:
passwd $USERNAME
clear
#OpenRC
pacman -S connman-openrc
rc-update add connmand

echo install some essential packages
pacman -S dhcpcd
echo Do it yourself!!
sleep 5
exit
