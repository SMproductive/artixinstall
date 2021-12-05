#partitioning
pacman -S parted --noconfirm
parted /dev/sda mklabel gpt
parted /dev/sda mkpart efi fat32 0 512M
parted /dev/sda mkpart root ext4 512M 99%
parted /dev/sda mkpart swap linux-swap 99% 100%
parted /dev/sda set 1 esp on
parted /dev/sda set 1 boot on
parted /dev/sda set 3 swap on

#formatting
mkswap /dev/sda3
mkfs.fat -F32 /dev/sda1
y | mkfs.ext4 /dev/sda2

#mounting
swapon /dev/sda3
mount /dev/sda2 /mnt
mkdir /mnt/efi
mount /dev/sda1 /mnt/efi

#installation
basestrap /mnt base base-devel openrc elogind-openrc
basestrap /mnt linux linux-firmware
fstabgen -U /mnt >> /mnt/etc/fstab

cp chrootShit.sh /mnt
cp mirrorlist-arch /mnt/etc/pacman.d/mirrorlist-arch

artix-chroot /mnt ./chrootShit.sh
rm /mnt/chrootShit.sh

poweroff
