#!/bin/bash

mountpoint="/mnt/root"

# unmount drive if script is started again
umount -R $mountpoint 

# install install-scripts
pacman -Sy --needed --noconfirm arch-install-scripts

# choose disk and format it
sync
lsblk
read -rp 'Name of the drive: ' drive

if [[ $(mount | grep -c "$drive") -eq 0 ]];
then
	cfdisk "$drive"
	mkfs.fat -F32 "$drive"1
	mkfs.ext4 -O "^has_journal" "$drive"2

	# mount root partition to system
	mkdir -p "$mountpoint"
	mount "$drive"2 "$mountpoint"
	
	# install packages to disk
	release=$(head -n 1 /etc/os-release)
	packages=(linux-firmware base base-devel grub efibootmgr networkmanager exfat-utils mtools ntfs-3g amd-ucode intel-ucode gnuplot wxmaxima luakit qutebrowser xf86-video-vesa xf86-video-ati xf86-video-intel xf86-video-amdgpu xf86-video-nouveau kitty lxqt sddm kate ktorrent kcalc mpv kpatience veracrypt git vim nano partitionmanager bpytop htop openssh openssl sqlmap nmap arp-scan youtube-dl zsh zsh-syntax-highlighting zsh-autosuggestions zsh-completions bash-completion python-pip python bluez fatresize jfsutils lsof wget arandr neofetch arch-install-scripts tar xz bzip2 gzip zstd speedtest-cli)
	if [[ "$release" == 'NAME="Arch Linux"' ]]; 
	then
		pacstrap -c "$mountpoint" linux linux-headers "${packages[@]}"
	elif [[ "$release" == 'NAME="Artix Linux"' ]];
	then
		pacstrap -c "$mountpoint" linux linux-headers "${packages[@]}"
	elif [[ "$release" = 'NAME="Manjaro Linux"' ]]; 
	then 
		pacstrap -c "$mountpoint" linux-latest linux-latest-headers "${packages[@]}"
	fi

	# mount boot partition to system
	mkdir -p "$mountpoint"/efi
	mount "$drive"1 "$mountpoint"/efi
	
	# generate fstab
	genfstab -U "$mountpoint" >> "$mountpoint"/etc/fstab
	$EDITOR "$mountpoint"/etc/fstab
	
	# copy .zshrc and the config file to disk 
	cp config.sh "$mountpoint"/root
	cp --force .zshrc "$mountpoint"/root
	cp --force .bashrc "$mountpoint"/root
fi
