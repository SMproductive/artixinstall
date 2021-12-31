#chroot
#locale
ln -sf /usr/share/zoneinfo/Europe/Vienna /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_AT.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

#bootloader
pacman -S grub efibootmgr --noconfirm
grub-install --target=x86_64-efi --efi-directory=/efi --removable
grub-mkconfig -o /boot/grub/grub.cfg
clear

#networking
echo Enter hostname:
read HOSTNAME
echo $HOSTNAME >/etc/hostname
echo -e "127.0.0.1 \tlocalhost \n::1 \t\tlocalhost \n127.0.1.1 \t$HOSTNAME.localdomain $HOSTNAME" >>/etc/hosts
echo "hostname='$HOSTNAME'" > /etc/config.d/hostname
pacman -S dhcpcd iwd-openrc --noconfirm

pacman -S connman-openrc --noconfirm
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
pacman -Sy archlinux-keyring --noconfirm
pacman -Sy man alsa pulseaudio pavucontrol git sudo alacritty zsh grml-zsh-config go firefox vim chromium pcmanfm-gtk3 slock feh ttf-font-awesome ttf-opensans adobe-source-code-pro-fonts yarn dmenu papirus-icon-theme --noconfirm
pacman -S xdm-openrc xorg-server xf86-video-intel xorg-xbacklight --noconfirm

mkdir suckless
cd suckless
git clone https://git.suckless.org/dwm
git clone https://git.suckless.org/slstatus
cd ..

#configurations
mkdir .config
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
git clone https://github.com/SMproductive/configurations
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
	#alacritty
mkdir .config/alacritty
ln -P configurations/alacritty.yml .config/alacritty/alacritty.yml
	#gtk
cp -r configurations/gtk-3.0 .config/gtk-3.0
	#zsh
ln -P configurations/zshrc .zshrc
	#vim
ln -P configurations/vimrc .vimrc
	#vimplug
curl -fLo /home/"$username"/.vim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	#tapping of touchpad
echo '
Section "InputClass"
	Identifier "touchpad"
	Driver "libinput"
	MatchIsTouchpad "on"
	Option "Tapping" "on"
EndSection' > /etc/X11/xorg.conf.d/30-touchpad.conf
	#iptables
pacman -S iptables-openrc --noconfirm
iptables-restore configurations/iptables.rules
/etc/init.d/iptables save

chown -hR "$username":"$username" .
chsh -s /bin/zsh $username
rc-update add xdm
rc-update add iwd
exit
