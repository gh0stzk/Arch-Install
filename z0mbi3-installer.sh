#!/bin/env bash
			
			
#----------------------------------------
#          Setting some vars
#----------------------------------------

clear
loadkeys la-latin1
setfont ter-v18b

TIZO=$(curl https://ipapi.co/timezone)
IDIOMA=$(curl https://ipapi.co/languages | awk -F "," '{print $1}' | sed 's/-/_/g' | sed "s|$|.UTF-8|")
CRE='\033[0;31m'
CYE='\033[0;33m'
CGR='\033[0;32m'
CBL='\033[0;94m'
CNC='\033[0m'
CHROOT="arch-chroot /mnt"
OK='\n\033[0;32m OK...\033[0m'

#----------------------------------------
#          Logo z0mbi3              
#----------------------------------------

    clear
	echo
	echo
	echo 
	echo "                      %%%                "
	echo "               %%%%%//%%%%%              "
	echo "             %%************%%%           "
	echo "          (%%//############*****%%       "
	echo "        %%%%%**###&&&&&&&&&###**//       "
    echo "        %%(**##&&&#########&&&##**       "
    echo "        %%(**##*****#####*****##**%%%    "
    echo "        %%(**##     *****     ##**       "
    echo "           //##   @@**   @@   ##//       "
    echo "             ##     **###     ##         "
    echo "             #######     #####//         "
    echo "               ###**&&&&&**###           "
    echo "               &&&         &&&           "
    echo "               &&&////   &&              "
    echo "                  &&//@@@**              "
    echo "                    ..***                "
    echo "                         z0mbi3 Script   "
    echo -e "${CGR}\n\n\n   Loading...${CNC}"
    sleep 5
    clear
    
#----------------------------------------
#          Check BIOS
#----------------------------------------
    
    while true
	do
	    if [ -d /sys/firmware/efi/efivars ]; then
        echo "This script only works with BIOS/MBR.."
        sleep 2
			exit
		else
			break
		fi
	done
	
center()
{

    local terminal_width=$(tput cols)     # query the Terminfo database: number of columns
    local text="${1:?}"                   # text to center
    local glyph="${2:-=}"                 # glyph to compose the border
    local padding="${3:-2}"               # spacing around the text

    local text_width=${#text}             

    local border_width=$(( (terminal_width - (padding * 2) - text_width) / 2 ))

    local border=                         # shape of the border

    # create the border (left side or right side)
    for ((i=0; i<border_width; i++))
    do
        border+="${glyph}"
    done

    # a side of the border may be longer (e.g. the right border)
    if (( ( terminal_width - ( padding * 2 ) - text_width ) % 2 == 0 ))
    then
        # the left and right borders have the same width
        local left_border=$border
        local right_border=$left_border
    else
        # the right border has one more character than the left border
        # the text is aligned leftmost
        local left_border=$border
        local right_border="${border}${glyph}"
    fi

    # space between the text and borders
    local spacing=

    for ((i=0; i<$padding; i++))
    do
        spacing+=" "
    done

    # displays the text in the center of the screen, surrounded by borders.
    printf "${left_border}${spacing}${CYE}${text}${CNC}${spacing}${right_border}\n\n"
}
	#center "Example text" "~"
	#center "Example text" "=" 6
	
#----------------------------------------
#          Check Internet
#----------------------------------------
	
center "Test Internet Connection"
	if ping archlinux.org -c 1 >/dev/null 2>&1; then
			echo -e "Wait.... ${CGR}OK..${CNC}"
			sleep 2
		else
			echo "Error: Looks like you are not connected to internet.."
			echo "Leaving now...."
		exit
	fi
clear
		
#----------------------------------------
#          Getting Information   
#----------------------------------------


center "Get Relevant Info"    	
	while true
		do 
			read -rp "Enter your username: " USR
			if [[ "${USR}" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]]
			then 
				break
			fi 
			echo -e "Incorrect!! Only lowercase letters are allowed.\n"
		done  
	
	while
			echo
			read -rsp "Enter your password: " PASSWD
			echo
			read -rsp "Confirm your password: " CONF_PASSWD
			echo
			[ "$PASSWD" != "$CONF_PASSWD" ]
		do 
			echo "Passwords do not match!!"; 
		done
			echo "Correct password"
		
	while        
			echo
			read -rsp "Enter password for ROOT: " PASSWDR
			echo
			read -rsp "Confirm your password: " CONF_PASSWDR
			echo
			[ "$PASSWDR" != "$CONF_PASSWDR" ]
		do 
			echo "Passwords do not match!!"; 
		done
			echo "Correct password"
		
		
			echo		
	while true
		do 
			read -rp "Enter the name of your machine: " HNAME
			if [[ "${HNAME}" =~ ^[a-z][a-z0-9_.-]{0,62}[a-z0-9]$ ]]
			then 
				break 
			fi
			echo -e "Incorrect!! Cannot include capital letters or special symbols\n"
		done	    
    
  
			partroot="$(findmnt -Dn -M /mnt -o SOURCE)"
			echo
			lsblk -d -e 7,11 -o NAME,SIZE,MOUNTPOINTS
			echo "------------------------------"
			echo
			PS3="Choose the DISK (NOT partition) where Arch Linux will be installed: "
		select drive in $(lsblk -nd -e 7,11 -o NAME) 
		do
			if [ "$drive" ]; then
				break
			fi
		done
clear
		
center "Get Relevant Info"
   
		platopts=("Intel" "AMD" "VM")
		PS3="Choose your CPU (1, 2 o 3): "
	select opt in "${platopts[@]}"; do 
		case "$REPLY" in
			1) plattitle='Intel';packa='intel-ucode';gp='intel_agp i915';break;;
			2) plattitle='AMD';packa='amd-ucode';gp='amdgpu';break;;
			3) plattitle='VM';packa='qemu-guest-agent';gp='vmwgfx';break;;
			*) echo "Invalid option!! try again.";continue;;
		esac
	done

		echo
		kernel_options=("Linux" "Linux LTS" "Linux Zen")
		PS3="Choose your Kernel (1, 2 o 3): "
	select opt in "${kernel_options[@]}"; do
		case "$REPLY" in
			1) kerneltitle='Linux (Arch Default)';kernelpack='linux';break;;
			2) kerneltitle='Linux LTS';kernelpack='linux-lts';break;;
			3) kerneltitle='Linux Zen';kernelpack='linux-zen';break;;
			*) echo "Invalid option!! try again.";continue;;
		esac
	done

		echo
		graf_options=("Intel" "AMD" "NVIDIA" "VM")
		PS3="Choose Graphic Driver (1, 2, 3 o 4): "
	select opt in "${graf_options[@]}"; do
		case "$REPLY" in
			1) graftitle='Intel';grafpack='xf86-video-intel vulkan-intel';break;;
			2) graftitle='AMD';grafpack='xf86-video-amdgpu';break;;
			3) graftitle='NVIDIA';grafpack='nvidia';break;;
			4) graftitle='Maquina Virtual';grafpack='xf86-video-vmware';break;;
			*) echo "Invalid option!! try again.";continue;;
		esac
	done

		echo
		red_options=("DHCPCD" "NetworkManager")
		PS3="Select the client to manage the Internet (1 o 2): "
	select opt in "${red_options[@]}"; do
		case "$REPLY" in
			1) redtitle='DHCPCD';redpack='dhcpcd';esys='dhcpcd.service';break;;
			2) redtitle='NetworkManager';redpack='networkmanager';esys='NetworkManager';break;;
			*) echo "Invalid option!! try again.";continue;;
		esac
	done	

		echo
		audioopts=("PipeWire" "PulseAudio")
		PS3="Select the sound (1 o 2): "
	select opt in "${audioopts[@]}"; do
		case "$REPLY" in
			1) audiotitle='PipeWire';audiopack='pipewire pipewire-pulse';break;;
			2) audiotitle='PulseAudio';audiopack='pulseaudio';break;;
			*) echo "Invalid option!! try again.";continue;;
		esac
	done

		echo
		PS3="You want to install YAY as AUR Helper?: "
	select YAYH in "Yes" "No"
		do
			if [ $YAYH ]; then
				break
			fi
		done
    
		echo
		PS3="Restore dotfiles?: "
	select DOTS in "Yes" "No"
		do
			if [ $DOTS ]; then
				break
			fi
		done
		
		echo
		PS3="Mount my personal NTFS Windows storage?: "
	select MPW in "Yes" "No"
		do
			if [ $MPW ]; then
				break
			fi
		done
		
		echo
		PS3="Install XFCE desktop?: "
	select DEXFCE in "Yes" "No"
		do
			if [ $DEXFCE ]; then
				break
			fi
		done
    
    
			# Detectando tarjeta WiFi
			if [ "$(lspci -d ::280)" ]; then
				WIFI=y
			fi 
clear
	
		echo
		echo -e "\n --------------------"
		echo
		
		echo -e " User:      ${CBL}$USR${CNC}"
		echo -e " Hostname:  ${CBL}$HNAME${CNC}"
		echo -e " CPU:       ${CBL}$plattitle${CNC}"
		echo -e " Kernel:    ${CBL}$kerneltitle${CNC}"
		echo -e " Graphics:  ${CBL}$graftitle${CNC}"
		echo -e " Internet:  ${CBL}$redtitle${CNC}"
		echo -e " Souns:     ${CBL}$audiotitle${CNC}"
    
		if [ "${YAYH}" = "Yes" ]; then
			echo -e " Yay:       ${CGR}Si${CNC}"
		else
			echo -e " Yay:       ${CRE}No${CNC}"
		fi
		
		if [ "${DOTS}" = "Yes" ]; then
			echo -e " Dotfiles:  ${CGR}Si${CNC}"
		else
			echo -e " Dotfiles:  ${CRE}No${CNC}"
		fi
		
		if [ "${DEXFCE}" = "Yes" ]; then
			echo -e " Xfce:      ${CGR}Si${CNC}"
		else
			echo -e " Xfce:      ${CRE}No${CNC}"
		fi
		
		if [ "${MPW}" = "Yes" ]; then
			echo -e " Personal storage:  ${CGR}Si${CNC}"
		else
			echo -e " Personal storage:  ${CRE}No${CNC}"
		fi
		
		echo		
		echo -e " Arch Linux will be installed on the disk ${CYE}[${CNC}${CRE}$drive${CNC}${CYE}]${CNC} in the partition ${CYE}[${CNC}${CBL}${partroot}${CNC}${CYE}]${CNC}"
    	echo
		echo
		
	while true; do
		read -rp " Do you wish to continue with installation? [y/N]: " yn
		case $yn in
			[Yy]* ) break;;
			[Nn]* ) exit;;
			* ) echo " Error: you only need to type 'y' or 'n'";;
		esac
	done
clear

#----------------------------------------
#          Pacstrap base system
#----------------------------------------

center "Installing Base System"
	sed -i 's/#Color/Color/; s/#ParallelDownloads = 5/ParallelDownloads = 10/; /^ParallelDownloads =/a ILoveCandy' /etc/pacman.conf
	reflector --verbose --latest 5 --country 'United States' --age 6 --sort rate --save /etc/pacman.d/mirrorlist
	echo
	pacstrap /mnt base base-devel $kernelpack linux-firmware $packa $redpack reflector cpupower grub os-prober ntfs-3g zsh
	echo -e "${OK}"
	sleep 2
clear

#----------------------------------------
#          Generating FSTAB
#----------------------------------------
    
center "Generating FSTAB"
	genfstab -U /mnt >> /mnt/etc/fstab
	echo -e "${OK}"
	sleep 2
clear

#----------------------------------------
#          Timezone, Lang & Keyboard
#----------------------------------------
	
center "Configuring Timezone And Locales"
	$CHROOT ln -sf /usr/share/zoneinfo/"$TIZO" /etc/localtime
	$CHROOT hwclock --systohc
	echo
	sed -i 's/#'"${IDIOMA}"'/'"${IDIOMA}"'/' /mnt/etc/locale.gen
	$CHROOT locale-gen
	echo "LANG=$IDIOMA" >> /mnt/etc/locale.conf
	echo "KEYMAP=la-latin1" >> /mnt/etc/vconsole.conf
	echo -e "${OK}"
	sleep 2
clear

#----------------------------------------
#          Hostname & Hosts
#----------------------------------------

center "Configuring Network"
	echo "${HNAME}" >> /mnt/etc/hostname
	cat >> /mnt/etc/hosts <<EOL		
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HNAME}.localdomain ${HNAME}
EOL
	echo -e "${OK}"
	sleep 2
clear

#----------------------------------------
#          Users & Passwords
#----------------------------------------
    
center "Users And Passwords"
	echo "root:$PASSWDR" | $CHROOT chpasswd
	$CHROOT useradd -m -g users -G wheel -s /usr/bin/zsh "${USR}"
	echo "$USR:$PASSWD" | $CHROOT chpasswd
	sed -i 's/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/; /^root ALL=(ALL:ALL) ALL/a '"${USR}"' ALL=(ALL:ALL) ALL' /mnt/etc/sudoers
	echo "Defaults insults" >> /mnt/etc/sudoers
	echo -e " ${CBL}root${CNC} : ${CRE}$PASSWDR${CNC}\n ${CYE}$USR${CNC} : ${CRE}$PASSWD${CNC}"
	echo -e "${OK}"
	sleep 5
clear

#----------------------------------------
#          Install GRUB
#----------------------------------------

center "Installing GRUB"
	$CHROOT grub-install --target=i386-pc /dev/"$drive"
	echo
	sed -i 's/quiet/noibrs noibpb nopti nospectre_v2 nospectre_v1 l1tf=off nospec_store_bypass_disable no_stf_barrier mds=off tsx=on tsx_async_abort=off mitigations=off nowatchdog/; s/#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER/' /mnt/etc/default/grub
	sed -i "s/MODULES=()/MODULES=(${gp})/" /mnt/etc/mkinitcpio.conf
	echo
	$CHROOT grub-mkconfig -o /boot/grub/grub.cfg
	echo -e "${OK}"
	sleep 2
clear  

#----------------------------------------
#          Optimizations
#----------------------------------------

center "Making some Speedups And Optimizations"

	echo -e "${CYE}Pimp my pacman${CNC}"
	sed -i 's/#Color/Color/; s/#ParallelDownloads = 5/ParallelDownloads = 10/; /^ParallelDownloads =/a ILoveCandy' /mnt/etc/pacman.conf
	echo -e "${OK}"
	sleep 2
    
	echo -e "\n${CYE}Tunning ext4 file system for SSD and SpeedUp${CNC}"
	sed -i 's/relatime/noatime,commit=120,barrier=0/' /mnt/etc/fstab
	$CHROOT tune2fs -O fast_commit "$partroot" >/dev/null
	echo -e "${OK}"
	sleep 2
    
	echo -e "\n${CYE}Optimizing make flags for speedup compiling times${CNC}\n"
	echo -e "You have ${CBL}$(nproc)${CNC} cores."
	sed -i 's/march=x86-64/march=native/; s/mtune=generic/mtune=native/; s/-O2/-O3/; s/#MAKEFLAGS="-j2/MAKEFLAGS="-j'"$(nproc)"'/' /mnt/etc/makepkg.conf
	echo -e "${OK}"
	sleep 2
    
	echo -e "\n${CYE}Configuring CPU to performance mode${CNC}"
	sed -i "s/#governor='ondemand'/governor='performance'/" /mnt/etc/default/cpupower
	echo -e "${OK}"
	sleep 2
    
	echo -e "\n${CYE}Changing kernel scheduler to mq-deadline${CNC}"
	cat >> /mnt/etc/udev/rules.d/60-ssd.rules <<EOL
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
EOL
	echo -e "${OK}"
	sleep 2

	echo -e "\n${CYE}Changing swappiness${CNC}"
	cat >> /mnt/etc/sysctl.d/99-swappiness.conf <<EOL
vm.swappiness=1
vm.vfs_cache_pressure=50
EOL
	echo -e "${OK}"
	sleep 2

	echo -e "\n${CYE}Disabling Journal logs..${CNC}"
	sed -i 's/#Storage=auto/Storage=none/' /mnt/etc/systemd/journald.conf
	echo -e "${OK}"
	sleep 2
    
	echo -e "\n${CYE}Disabling innecessary kernel modules${CNC}"
	cat >> /mnt/etc/modprobe.d/blacklist.conf <<EOL
blacklist iTCO_wdt
blacklist mousedev
blacklist mac_hid
blacklist uvcvideo
EOL
	echo -e "${OK}"
	sleep 2
		
	echo -e "\n${CYE}Disabling innecessary services${CNC}\n"
	$CHROOT systemctl mask lvm2-monitor.service systemd-random-seed.service
	echo -e "${OK}"
	sleep 2
		
	echo -e "\n${CYE}Speedup Networking with Cloudflare's DNS${CNC}"
	if $CHROOT pacman -Qi dhcpcd > /dev/null ; then
	echo "noarp" >> /mnt/etc/dhcpcd.conf
	echo "static domain_name_servers=1.1.1.1 1.0.0.1" >> /mnt/etc/dhcpcd.conf
	else
	echo "[global-dns-domain-*]" >> /mnt/etc/NetworkManager/conf.d/dns-servers.conf
	echo "servers=1.1.1.1,1.0.0.1" >> /mnt/etc/NetworkManager/conf.d/dns-servers.conf
	fi
	echo -e "${OK}"
	sleep 2
    
	if [ "${MPW}" == "Yes" ]; then
	echo -e "\n${CYE}Mounting my personal storage${CNC}\n"
	cat >> /mnt/etc/fstab <<EOL		
# My sTuFF
UUID=01D3AE59075CA1F0		/run/media/$USR/windows	ntfs-3g		auto,rw,users,hide_hid_files,noatime,umask=000 0 0
EOL
	cat /mnt/etc/fstab
	sleep 5
	echo -e "${OK}"
	sleep 2
	fi
	
clear
	
#----------------------------------------
#          Refreshing Mirrors
#----------------------------------------

center "Refreshing mirrors"
	$CHROOT reflector --verbose --latest 5 --country 'United States' --age 6 --sort rate --save /etc/pacman.d/mirrorlist
	echo
	$CHROOT pacman -Syy
	echo -e "${OK}"
	sleep 2
clear

#----------------------------------------
#          Installing Packages
#----------------------------------------

center "Installing Audio & Video"
	sleep 2	
	$CHROOT pacman -S xorg-server xorg-xinput xorg-xsetroot $grafpack $audiopack --noconfirm
	clear
	
center "Installing Multimedia Codecs And Archiver Utilities"
	$CHROOT pacman -S ffmpeg ffmpegthumbnailer aom libde265 x265 x264 libmpeg2 xvidcore libtheora libvpx sdl jasper openjpeg2 libwebp unarchiver lha lrzip lzip p7zip lbzip2 arj lzop cpio unrar unzip zip unarj xdg-utils --noconfirm
	clear
	
center "Installing support for mounting volumes and removable media devices"
	$CHROOT pacman -S libmtp gvfs-nfs dosfstools usbutils gvfs gvfs-mtp net-tools xdg-user-dirs gtk-engine-murrine --noconfirm
	clear
	
center "Installing Apps i use"
	$CHROOT pacman -S android-file-transfer bleachbit cmatrix dunst gimp gcolor3 geany gparted htop lxappearance minidlna neovim thunar thunar-archive-plugin tumbler ranger simplescreenrecorder transmission-gtk ueberzug viewnior yt-dlp zathura zathura-pdf-poppler retroarch retroarch-assets-xmb retroarch-assets-ozone bspwm nitrogen pacman-contrib rofi sxhkd pass xclip firefox firefox-i18n-es-mx pavucontrol playerctl xarchiver numlockx polkit-gnome papirus-icon-theme ttf-joypixels terminus-font scrot grsync git --noconfirm
	clear
	
center "Installing LightDM & Greeter"
	$CHROOT pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings --noconfirm
	sed -i 's/#greeter-setup-script=/greeter-setup-script=\/usr\/bin\/numlockx on/' /mnt/etc/lightdm/lightdm.conf
	rm -f /mnt/etc/lightdm/lightdm-gtk-greeter.conf
	cat >> /mnt/etc/lightdm/lightdm-gtk-greeter.conf <<EOL
[greeter]
icon-theme-name = Qogir-ubuntu
background = /run/media/$USR/windows/Imagenes/Wallpapers/hb5qhio1hjk71.jpg
user-background = false
default-user-image = /run/media/$USR/windows/Imagenes/Som3shiT/Dzndj8HUt7EcgEBD.png
indicators = ~host;~spacer;~clock;~spacer;~session;~power
position = 50%,center 83%,center
screensaver-timeout = 0
theme-name = Dracula
font-name = UbuntuMono Nerd Font 11
EOL
clear
    
    if [ "$DEXFCE" = "Yes" ]; then
center "Installing XFCE.."
		$CHROOT pacman -S xfce4 --noconfirm
		clear
	fi
	
center "Installing WIFI Tools"
	if [ "$WIFI" = "y" ]; then
		$CHROOT pacman -S wpa_supplicant wireless_tools --noconfirm
	else
		echo -e "You dont have wifi.. Not installing.."
	fi
		sleep 2
clear
		
#----------------------------------------
#          AUR Packages
#----------------------------------------

		if [ "${YAYH}" == "Yes" ]; then
		
center "Installing YAY.. And AUR Packages"
	sleep 2
	echo "cd && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd && rm -rf yay" | $CHROOT su "$USR"
clear


center "zramswap checkupdates-aur picom-jonaburg-git polybar termite xtitle"
	sleep 2
	echo "cd && yay -S zramswap checkupdates-aur picom-jonaburg-git polybar termite xtitle --noconfirm --removemake --cleanafter" | $CHROOT su "$USR"
clear

center "spotify spotify-adblock mpv popcorn-time"
	sleep 2
	echo "cd && yay -S spotify spotify-adblock-git mpv-git popcorntime-bin --noconfirm --removemake --cleanafter" | $CHROOT su "$USR"
clear

center "Whatsapp & Telegram"
	sleep 2
	echo "cd && yay -S whatsapp-nativefier telegram-desktop-bin --noconfirm --removemake --cleanafter" | $CHROOT su "$USR"
clear

center "Iconos fonts & stacer"
	sleep 2
	echo "cd && yay -S stacer nerd-fonts-jetbrains-mono nerd-fonts-ubuntu-mono qogir-icon-theme --noconfirm --removemake --cleanafter" | $CHROOT su "$USR"
clear
		fi

#----------------------------------------
#          Enable Services & other stuff
#----------------------------------------

center "Enabling Services"
	$CHROOT systemctl enable ${esys} lightdm cpupower systemd-timesyncd.service
	$CHROOT systemctl enable zramswap
		
	cat >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf <<EOL
Section "InputClass"
		Identifier	"system-keyboard"
		MatchIsKeyboard	"on"
		Option	"XkbLayout"	"latam"
EndSection
EOL
	echo "xdg-user-dirs-update" | $CHROOT su "$USR"
	
#----------------------------------------
#          Reverting No Pasword Privileges
#----------------------------------------

	sed -i 's/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /mnt/etc/sudoers
	echo -e "${OK}"
	sleep 2
clear

#----------------------------------------
#          My DOTFILES
#----------------------------------------

	if [ "${DOTS}" == "Yes" ]; then
	
center "Generating my XORG config files"
	sleep 2
	cat >> /mnt/etc/X11/xorg.conf.d/20-intel.conf <<EOL		
Section "Device"
	Identifier	"Intel Graphics"
	Driver		"Intel"
	Option		"AccelMethod"	"sna"
	Option		"DRI"		"3"
	Option		"TearFree"	"true"
EndSection
EOL
	echo -e "${CGR}20-intel.conf${CNC} generated in --> /etc/X11/xorg.conf.d\n"
		  
	cat >> /mnt/etc/X11/xorg.conf.d/10-monitor.conf <<EOL
Section "Monitor"
	Identifier	"HP"
	Option		"DPMS"	"true"
EndSection

Section "ServerFlags"
	Option	"StandbyTime"	"120"
	Option	"SuspendTime"	"120"
	Option	"OffTime"	"120"
	Option	"BlankTime"	"0"
EndSection
	
Section "ServerLayout"
	Identifier	"ServerLayout0"
EndSection
EOL
	echo -e "${CGR}10-monitor.conf${CNC} generated in --> /etc/X11/xorg.conf.d\n"
		
	cat >> /mnt/etc/drirc <<EOL
<driconf>

	<device driver="i915">
		<application name="Default">
			<option name="stub_occlusion_query" value="true" />
			<option name="fragment_shader" value="true" />
		</application>
	</device>
	
</driconf>
EOL
	echo -e "${CGR}drirc${CNC} generated in --> /etc"
	sleep 2
clear

center "Restoring my dotfiles"
	mkdir /mnt/dots
	mount -U 6bca691d-82f3-4dd5-865b-994f99db54e1 -w /mnt/dots
	echo "rsync -vrtlpX /dots/dotfiles/ /home/$USR/" | $CHROOT su "$USR"
	$CHROOT mv /home/"$USR"/.themes/Dracula /usr/share/themes
	$CHROOT rm -rf /home/"$USR"/.themes
	$CHROOT cp /dots/stuff/zfetch /usr/bin/
	echo -e "${OK}"
	sleep 5
clear
	fi

#----------------------------------------
#          Cleaning Garbage
#----------------------------------------

center "Cleaning system for first start"
	sleep 2
	rm -rf /mnt/home/"$USR"/.cache/yay/
	rm -rf /mnt/home/"$USR"/.cache/electron/
	rm -rf /mnt/home/"$USR"/.cache/go-build/
	rm -rf /mnt/home/"$USR"/.cargo/
	rm -rf /mnt/usr/lib/firmware/{amd,amdgpu,amd-ucode,mellanox,mwlwifi,netronome,nvidia,radeon,rtlwifi}
	rm -rf /mnt/usr/share/icons/{Qogir-manjaro,Qogir-manjaro-dark,Papirus-Light}
	rm -f /mnt/usr/share/applications/{avahi-discover.desktop,bssh.desktop,bvnc.desktop,compton.desktop,picom.desktop,qv4l2.desktop,qvidcap.desktop,spotify.desktop,thunar-bulk-rename.desktop,thunar-settings.desktop,xfce4-about.desktop}
	rm -f /mnt/opt/whatsapp-nativefier/locales/{am.pak,ar.pak,bg.pak,bn.pak,ca.pak,cs.pak,da.pak,de.pak,el.pak,en-GB.pak,et.pak,fa.pak,fi.pak,fil.pak,fr.pak,gu.pak,he.pak,hi.pak,hr.pak,hu.pak,id.pak,it.pak,ja.pak,kn.pak,ko.pak,lt.pak,lv.pak,ml.pak,mr.pak,ms.pak,nb.pak,nl.pak,pl.pak,pt-BR.pak,pt-PT.pak,ro.pak,ru.pak,sk.pak,sl.pak,sr.pak,sv.pak,sw.pak,ta.pak,te.pak,th.pak,tr.pak,uk.pak,vi.pak,zh-CN.pak,zh-TW.pak}
	rm -f /mnt/usr/lib/firmware/{iwlwifi-100-5.ucode,iwlwifi-105-6.ucode,iwlwifi-135-6.ucode,iwlwifi-1000-3.ucode,iwlwifi-1000-5.ucode,iwlwifi-2000-6.ucode,iwlwifi-2030-6.ucode,iwlwifi-3160-7.ucode,iwlwifi-3160-8.ucode,iwlwifi-3160-9.ucode,iwlwifi-3160-10.ucode,iwlwifi-3160-12.ucode,iwlwifi-3160-13.ucode,iwlwifi-3160-16.ucode,iwlwifi-3160-17.ucode,iwlwifi-3168-21.ucode,iwlwifi-3168-22.ucode,iwlwifi-3168-27.ucode,iwlwifi-3168-29.ucode,iwlwifi-3945-2.ucode,iwlwifi-4965-2.ucode,iwlwifi-5000-1.ucode,iwlwifi-5000-2.ucode,iwlwifi-5000-5.ucode,iwlwifi-5150-2.ucode,iwlwifi-6000-4.ucode,iwlwifi-6000g2a-5.ucode,iwlwifi-6000g2a-6.ucode,iwlwifi-6000g2b-5.ucode,iwlwifi-6000g2b-6.ucode,iwlwifi-6050-4.ucode,iwlwifi-6050-5.ucode,iwlwifi-7260-7.ucode,iwlwifi-7260-8.ucode,iwlwifi-7260-9.ucode,iwlwifi-7260-10.ucode,iwlwifi-7260-12.ucode,iwlwifi-7260-13.ucode,iwlwifi-7260-16.ucode,iwlwifi-7260-17.ucode,iwlwifi-7265-8.ucode,iwlwifi-7265-9.ucode,iwlwifi-7265-10.ucode,iwlwifi-7265-12.ucode,iwlwifi-7265-13.ucode,iwlwifi-7265-16.ucode,iwlwifi-7265-17.ucode,iwlwifi-7265D-10.ucode,iwlwifi-7265D-12.ucode,iwlwifi-7265D-13.ucode,iwlwifi-7265D-16.ucode,iwlwifi-7265D-17.ucode,iwlwifi-7265D-21.ucode,iwlwifi-7265D-22.ucode,iwlwifi-7265D-27.ucode,iwlwifi-7265D-29.ucode,iwlwifi-8000C-13.ucode,iwlwifi-8000C-16.ucode,iwlwifi-8000C-21.ucode,iwlwifi-8000C-22.ucode,iwlwifi-8000C-27.ucode,iwlwifi-8000C-31.ucode,iwlwifi-8000C-34.ucode,iwlwifi-8000C-36.ucode,iwlwifi-8265-21.ucode,iwlwifi-8265-22.ucode,iwlwifi-8265-27.ucode,iwlwifi-8265-31.ucode,iwlwifi-8265-34.ucode,iwlwifi-8265-36.ucode,iwlwifi-9000-pu-b0-jf-b0-33.ucode,iwlwifi-9000-pu-b0-jf-b0-34.ucode,iwlwifi-9000-pu-b0-jf-b0-38.ucode,iwlwifi-9000-pu-b0-jf-b0-41.ucode,iwlwifi-9000-pu-b0-jf-b0-43.ucode,iwlwifi-9000-pu-b0-jf-b0-46.ucode,iwlwifi-9260-th-b0-jf-b0-33.ucode,iwlwifi-9260-th-b0-jf-b0-34.ucode,iwlwifi-9260-th-b0-jf-b0-38.ucode,iwlwifi-9260-th-b0-jf-b0-41.ucode,iwlwifi-9260-th-b0-jf-b0-43.ucode,iwlwifi-9260-th-b0-jf-b0-46.ucode,iwlwifi-cc-a0-46.ucode,iwlwifi-cc-a0-48.ucode,iwlwifi-cc-a0-50.ucode,iwlwifi-cc-a0-53.ucode,iwlwifi-cc-a0-55.ucode,iwlwifi-cc-a0-59.ucode,iwlwifi-cc-a0-62.ucode,iwlwifi-cc-a0-63.ucode,iwlwifi-Qu-b0-hr-b0-48.ucode,iwlwifi-Qu-b0-hr-b0-50.ucode,iwlwifi-Qu-b0-hr-b0-53.ucode,iwlwifi-Qu-b0-hr-b0-55.ucode,iwlwifi-Qu-b0-hr-b0-59.ucode,iwlwifi-Qu-b0-hr-b0-62.ucode,iwlwifi-Qu-b0-hr-b0-63.ucode,iwlwifi-Qu-b0-jf-b0-48.ucode,iwlwifi-Qu-b0-jf-b0-50.ucode,iwlwifi-Qu-b0-jf-b0-53.ucode,iwlwifi-Qu-b0-jf-b0-55.ucode,iwlwifi-Qu-b0-jf-b0-59.ucode,iwlwifi-Qu-b0-jf-b0-62.ucode,iwlwifi-Qu-b0-jf-b0-63.ucode,iwlwifi-Qu-c0-hr-b0-48.ucode,iwlwifi-Qu-c0-hr-b0-50.ucode,iwlwifi-Qu-c0-hr-b0-53.ucode,iwlwifi-Qu-c0-hr-b0-55.ucode,iwlwifi-Qu-c0-hr-b0-59.ucode,iwlwifi-Qu-c0-hr-b0-62.ucode,iwlwifi-Qu-c0-hr-b0-63.ucode,iwlwifi-Qu-c0-jf-b0-48.ucode,iwlwifi-Qu-c0-jf-b0-50.ucode,iwlwifi-Qu-c0-jf-b0-53.ucode,iwlwifi-Qu-c0-jf-b0-55.ucode,iwlwifi-Qu-c0-jf-b0-59.ucode,iwlwifi-Qu-c0-jf-b0-62.ucode,iwlwifi-Qu-c0-jf-b0-63.ucode,iwlwifi-QuZ-a0-hr-b0-48.ucode,iwlwifi-QuZ-a0-hr-b0-50.ucode,iwlwifi-QuZ-a0-hr-b0-53.ucode,iwlwifi-QuZ-a0-hr-b0-55.ucode,iwlwifi-QuZ-a0-hr-b0-59.ucode,iwlwifi-QuZ-a0-hr-b0-62.ucode,iwlwifi-QuZ-a0-hr-b0-63.ucode,iwlwifi-QuZ-a0-jf-b0-48.ucode,iwlwifi-QuZ-a0-jf-b0-50.ucode,iwlwifi-QuZ-a0-jf-b0-53.ucode,iwlwifi-QuZ-a0-jf-b0-55.ucode,iwlwifi-QuZ-a0-jf-b0-59.ucode,iwlwifi-QuZ-a0-jf-b0-62.ucode,iwlwifi-QuZ-a0-jf-b0-63.ucode,iwlwifi-so-a0-gf-a0.pnvm,iwlwifi-so-a0-gf-a0-64.ucode,iwlwifi-so-a0-hr-b0-64.ucode,iwlwifi-so-a0-jf-b0-64.ucode,iwlwifi-ty-a0-gf-a0.pnvm,iwlwifi-ty-a0-gf-a0-59.ucode,iwlwifi-ty-a0-gf-a0-62.ucode,iwlwifi-ty-a0-gf-a0-63.ucode,iwlwifi-ty-a0-gf-a0-66.ucode}

	echo
	$CHROOT pacman -Rns go
	$CHROOT pacman -Rns "$(pacman -Qtdq)"
	$CHROOT fstrim -av
	echo -e "${OK}"
	sleep 2
clear

#----------------------------------------
#                Bye
#----------------------------------------

center "You are now usin Arch Linux BTW...."

distro="$(source /mnt/etc/os-release && echo "${PRETTY_NAME}")"
kernel="$(arch-chroot /mnt uname -r)"
pkgs="$(arch-chroot /mnt pacman -Q | wc -l)"
memory="$(free --mega | sed -n -E '2s/^[^0-9]*([0-9]+) *([0-9]+).*/'"${space}"'\2 MB/p')"
usage="$(df -h / | grep "/" | awk '{print $3}')"

echo -e "                            "
echo -e "         / \                "
echo -e "        /   \          os       ${distro}"     
echo -e "       /^.   \         Kernel   ${kernel}"    
echo -e "      /  .-.  \        pkgs     ${pkgs}"   
echo -e "     /  (   ) _\       ram      ${memory}"
echo -e "    / _.~   ~._^\      Disk     ${usage}"
echo -e "   /.^         ^.\          "
		
		echo
		echo
while true; do
		read -rp "Do you want to reboot? [y/N]: " yn
		case $yn in
			[Yy]* ) reboot;;
			[Nn]* ) exit;;
			* ) echo "Error: you only need to type 'y' or 'n'";;
		esac
	done
