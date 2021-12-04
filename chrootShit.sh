#chroot
artix-chroot /mnt
ln -sf /usr/share/zoneinfo/Europe/Vienna /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_AT.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=efi --removable
grub-mkconfig -o /boot/grub/grub.cfg

HOSTNAME=anonym
echo $HOSTNAME >/etc/hostname
echo -e "127.0.0.1 \tlocalhost \n::1 \t\tlocalhost \n127.0.1.1 \t$HOSTNAME.localdomain $HOSTNAME" >>/etc/hosts

echo "hostnam='$HOSTNAME'" > /etc/config.d/hostname
pacman -S dhcpcd iwd

pacman -S connman-openrc
rc-update add connmand

echo add the user by yourself
