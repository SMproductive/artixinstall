#chroot
#locale
ln -sf /usr/share/zoneinfo/Europe/Vienna /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_AT.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

#bootloader
yes | pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=efi --removable
grub-mkconfig -o /boot/grub/grub.cfg

#networking
HOSTNAME=anonym
echo $HOSTNAME >/etc/hostname
echo -e "127.0.0.1 \tlocalhost \n::1 \t\tlocalhost \n127.0.1.1 \t$HOSTNAME.localdomain $HOSTNAME" >>/etc/hosts
echo "hostname='$HOSTNAME'" > /etc/config.d/hostname
yes | pacman -S dhcpcd iwd-openrc

yes | pacman -S connman-openrc
rc-update add connmand
clear

#users
echo root password:
passwd
clear
echo new username:
read username
useradd -m $username -G users,wheel,audio,video,power
passwd $username

#pacman config
echo "
#
# ARCHLINUX
#

#[testing]
#Include = /etc/pacman.d/mirrorlist-arch

[extra]
Include = /etc/pacman.d/mirrorlist-arch

#[community-testing]
#Include = /etc/pacman.d/mirrorlist-arch

[community]
Include = /etc/pacman.d/mirrorlist-arch

#[multilib-testing]
#Include = /etc/pacman.d/mirrorlist-arch

[multilib]
Include = /etc/pacman.d/mirrorlist-arch" >> /etc/pacman.conf

#gue and programs
cd /home/"$username"
yes | pacman -S git sudo alacritty zsh go firefox vim chromium pcmanfm-gtk3 slock feh ttf-font-awesome ttf-opensans adobe-source-code-pro-fonts
yes | pacman -S xdm-openrc xorg-server xf86-video-intel xorg-xbacklight

mkdir suckless
cd suckless
git clone https://git.suckless.org/dwm
git clone https://git.suckless.org/slstatus
cd ..

#configurations
mkdir .config
chown "$username":"$username" .config
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
git clone https://github.com/SMproductive/configurations
	#ownership
chown "$username":"$username" configurations
chown "$username":"$username" configurations/*
	#suckless
cp configurations/slstatusConfig.h suckless/slstatus/config.h
cp configurations/dwmConfig.h suckless/dwm/config.h
cd suckless/dwm
make install
cd ..
cd slstatus
make install
cd ../..
	#login
ln -P configurations/xsession .xsession
chown "$username":"$username" .xsession
	#alacritty
mkdir .config/alacritty
ln -P configurations/alacritty.yml .config/alacritty/alacritty.yml
chown "$username":"$username" .config/alacritty/alacritty.yml
	#gtk
cp -r configurations/gtk-3.0 .config/gtk-3.0
chown "$username":"$username" .config/gtk-3.0/*
	#zsh
ln -P configurations/zshrc .zshrc
chown "$username":"$username" .zshrc
	#vim
ln -P configurations/vimrc .vimrc
chown "$username":"$username" .vimrc
	#iptables
iptables-restore configurations/iptables.rules
exit
