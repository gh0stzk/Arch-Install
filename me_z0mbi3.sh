#!/bin/env bash
			
clear
loadkeys la-latin1			
#----------------------------------------
#          Setting some vars
#----------------------------------------

CRE=$(tput setaf 1)
CYE=$(tput setaf 3)
CGR=$(tput setaf 2)
CBL=$(tput setaf 4)
CNC=$(tput sgr0)
CHROOT="arch-chroot /mnt"

okie() {
	printf "\n%s OK...%s\n" "$CGR" "$CNC"
	sleep 2
}

titleopts () {
	
	local textopts="${1:?}"
	printf " \n%s>>>%s %s%s%s\n" "${CBL}" "${CNC}" "${CYE}" "${textopts}" "${CNC}"
	
}

#----------------------------------------
#          Getting Information   
#----------------------------------------

	
	while true
		do 
				read -rp "Ingresa tu usuario: " USR
			if [[ "${USR}" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]]
				then 
					break
			fi 
			printf "Incorrecto!! Solo se permiten minusculas.\n\n"
		done  
		
			echo
	while
			read -rsp "Ingresa tu password: " PASSWD
			echo
			read -rsp "Confirma tu password: " CONF_PASSWD
			echo
			[ "$PASSWD" != "$CONF_PASSWD" ]
		do 
			printf "Los passwords no coinciden!!\n\n"; 
		done
			printf "Password correcto\n"
		
	while        
			echo
			read -rsp "Ingresa password para ROOT: " PASSWDR
			echo
			read -rsp "Confirma el password: " CONF_PASSWDR
			echo
			[ "$PASSWDR" != "$CONF_PASSWDR" ]
		do 
			printf "Los passwords no coinciden!!\n"; 
		done
			printf "Password correcto\n"
			
	while true
		do
				echo
				read -rp "Ingresa el nombre de tu maquina: " HNAME
			if [[ "${HNAME}" =~ ^[a-z][a-z0-9_.-]{0,62}[a-z0-9]$ ]]
				then 
					break 
			fi
			printf "Incorrecto!! No puede incluir mayusculas ni simbolos especiales\n"
		done
	clear
		
logo "Ingresa la informacion Necesaria"

#----------------------------------------
#          Select DISK
#----------------------------------------

logo "Creando Formatenado y Montando Particiones"
			
		lsblk -d -e 7,11 -o NAME,SIZE,TYPE,MODEL
		printf "%s\n" "------------------------------"
		echo
		PS3="Escoge el DISCO (NO la particion) donde Arch Linux se instalara: "
	select drive in $(lsblk -d | awk '{print "/dev/" $1}' | grep 'sd\|hd\|vd\|nvme\|mmcblk') 
		do
			if [ "$drive" ]; then
				break
			fi
		done
			clear

#----------------------------------------
#          Creando y Montando particion raiz
#----------------------------------------

logo "Creando Formatenado y Montando Particiones"

			echo
			lsblk "${drive}" -I 8 -o NAME,SIZE,FSTYPE,PARTTYPENAME
			echo
			
			PS3="Escoge la particion raiz que acabas de crear donde Arch Linux se instalara: "
	select partroot in $(fdisk -l "${drive}" | grep Linux | cut -d" " -f1) 
		do
			if [ "$partroot" ]; then
				printf " \nFormateando la particion RAIZ %s\n Espere..\n" "${partroot}"
				sleep 3
				mkfs.ext4 -L Arch "${partroot}" >/dev/null 2>&1
				mount "${partroot}" /mnt
				sleep 3	
				break
			fi
		done
					
			okie
			clear
			
		
#----------------------------------------
#          Creando y Montando SWAP
#----------------------------------------

logo "Configurando SWAP"

			PS3="Escoge la particion SWAP: "
	select swappart in $(fdisk -l | grep -E "swap" | cut -d" " -f1) "No quiero swap" "Crear archivo swap"
		do
			if [ "$swappart" = "Crear archivo swap" ]; then
				
				printf "Creando archivo swap.."
				sleep 2
				fallocate -l 4096M /mnt/swapfile
				chmod 600 /mnt/swapfile
				mkswap -L SWAP /mnt/swapfile >/dev/null
				printf " Montando Swap, espera.."
				swapon /mnt/swapfile
				sleep 3
				okie
				break
					
			elif [ "$swappart" = "No quiero swap" ]; then
					
				break
					
			elif [ "$swappart" ]; then
				
				echo
				printf " Formateando la particion swap, espera..\n"
				sleep 2
				mkswap -L SWAP "${swappart}" >/dev/null 2>&1
				printf " Montando Swap, espera..\n"
				swapon "${swappart}"
				sleep 3
				okie
				break
			fi
		done
				clear
	
#----------------------------------------
#          Info
#----------------------------------------
	
		printf "\n\n%s\n\n" "--------------------"
		printf " User:      %s%s%s\n" "${CBL}" "$USR" "${CNC}"
		printf " Hostname:  %s%s%s\n" "${CBL}" "$HNAME" "${CNC}"
	
	if [ "$swappart" = "Crear archivo swap" ]; then
			printf " Swap:      %sSi%s se crea archivo swap de 2G\n" "${CGR}" "${CNC}"
	elif [ "$swappart" = "No quiero swap" ]; then
			printf " Swap:      %sNo%s\n" "${CRE}" "${CNC}"
	elif [ "$swappart" ]; then
			printf " Swap:      %sSi%s en %s[%s%s%s%s%s]%s\n" "${CGR}" "${CNC}" "${CYE}" "${CNC}" "${CBL}" "${swappart}" "${CNC}" "${CYE}" "${CNC}"
	fi
		
			echo		
			printf " \nArch Linux se instalara en el disco %s[%s%s%s%s%s]%s en la particion %s[%s%s%s%s%s]%s\n\n\n" "${CYE}" "${CNC}" "${CRE}" "${drive}" "${CNC}" "${CYE}" "${CNC}" "${CYE}" "${CNC}" "${CBL}" "${partroot}" "${CNC}" "${CYE}" "${CNC}"
		
	while true; do
			read -rp " Deseas continuar? [s/N]: " sn
		case $sn in
			[Ss]* ) break;;
			[Nn]* ) exit;;
			* ) printf " Error: solo necesitas escribir 's' o 'n'\n\n";;
		esac
	done
			clear


#----------------------------------------
#          Pacstrap base system
#----------------------------------------

logo "Instalando sistema base"

	sed -i 's/#Color/Color/; s/#ParallelDownloads = 5/ParallelDownloads = 5/; /^ParallelDownloads =/a ILoveCandy' /etc/pacman.conf
	pacstrap /mnt \
	         base \
	         base-devel \
	         linux-zen \
	         linux-firmware \
	         dhcpcd \
	         intel-ucode \
	         mkinitcpio \
	         reflector \
	         zsh
	okie
	clear

#----------------------------------------
#          Generating FSTAB
#----------------------------------------
    
logo "Generando FSTAB"

		genfstab -U /mnt >> /mnt/etc/fstab
		okie
	clear

#----------------------------------------
#          Timezone, Lang & Keyboard
#----------------------------------------
	
logo "Configurando Timezone y Locales"
		
	$CHROOT ln -sf /usr/share/zoneinfo/America/Mexico_City /etc/localtime
	$CHROOT hwclock --systohc
	echo
	echo "es_MX.UTF-8 UTF-8" >> /mnt/etc/locale.gen
	$CHROOT locale-gen
	echo "LANG=es_MX.UTF-8" >> /mnt/etc/locale.conf
	echo "KEYMAP=la-latin1" >> /mnt/etc/vconsole.conf
	echo "FONT=ter-v18n" >> /mnt/etc/vconsole.conf
	export LANG=es_MX.UTF-8
	okie
	clear

#----------------------------------------
#          Hostname & Hosts
#----------------------------------------

logo "Configurando Internet"

	echo "${HNAME}" >> /mnt/etc/hostname
	cat >> /mnt/etc/hosts <<- EOL		
		127.0.0.1   localhost
		::1         localhost
		127.0.1.1   ${HNAME}.localdomain ${HNAME}
	EOL
	okie
	clear

#----------------------------------------
#          Users & Passwords
#----------------------------------------
    
logo "Usuario Y Passwords"

	echo "root:$PASSWDR" | $CHROOT chpasswd
	$CHROOT useradd -m -g users -G wheel -s /usr/bin/zsh "${USR}"
	echo "$USR:$PASSWD" | $CHROOT chpasswd
	sed -i 's/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/; /^root ALL=(ALL:ALL) ALL/a '"${USR}"' ALL=(ALL:ALL) ALL' /mnt/etc/sudoers
	echo "Defaults insults" >> /mnt/etc/sudoers
	printf " %sroot%s : %s%s%s\n %s%s%s : %s%s%s\n" "${CBL}" "${CNC}" "${CRE}" "${PASSWDR}" "${CNC}" "${CYE}" "${USR}" "${CNC}" "${CRE}" "${PASSWD}" "${CNC}"
	okie
	sleep 3
	clear

#----------------------------------------
#          Refreshing Mirrors
#----------------------------------------

logo "Refrescando mirros en la nueva Instalacion"

	$CHROOT reflector --verbose --latest 5 --country 'United States' --age 6 --sort rate --save /etc/pacman.d/mirrorlist >/dev/null 2>&1
	$CHROOT pacman -Syy
	okie
	clear

#----------------------------------------
#          Install GRUB
#----------------------------------------

logo "Instalando GRUB"

	$CHROOT pacman -S grub os-prober ntfs-3g --noconfirm >/dev/null
	$CHROOT grub-install --target=i386-pc "$drive"
	
	sed -i 's/quiet/zswap.enabled=0 mitigations=off nowatchdog/; s/#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER/' /mnt/etc/default/grub
	sed -i "s/MODULES=()/MODULES=(${cpu_atkm})/" /mnt/etc/mkinitcpio.conf
	echo
	$CHROOT grub-mkconfig -o /boot/grub/grub.cfg
	okie
	clear  

#----------------------------------------
#          Optimizations
#----------------------------------------

logo "Aplicando optmizaciones.."

	titleopts "Editando pacman. Se activan descargas paralelas, el color y el easter egg ILoveCandy"
	sed -i 's/#Color/Color/; s/#ParallelDownloads = 5/ParallelDownloads = 5/; /^ParallelDownloads =/a ILoveCandy' /mnt/etc/pacman.conf
	okie
    
    titleopts "Optimiza y acelera ext4 para SSD"
	sed -i '0,/relatime/s/relatime/noatime,commit=120,barrier=0/' /mnt/etc/fstab
	$CHROOT tune2fs -O fast_commit "${partroot}" >/dev/null
	okie
    
    titleopts "Optimizando las make flags para acelerar tiempos de compilado"
	printf "\nTienes %s%s%s cores\n" "${CBL}" "$(nproc)" "${CNC}"
	sed -i 's/march=x86-64/march=native/; s/mtune=generic/mtune=native/; s/-O2/-O3/; s/#MAKEFLAGS="-j2/MAKEFLAGS="-j'"$(nproc)"'/' /mnt/etc/makepkg.conf
	okie
    
    titleopts "Configurando CPU a modo performance"
	$CHROOT pacman -S cpupower --noconfirm >/dev/null
	sed -i "s/#governor='ondemand'/governor='performance'/" /mnt/etc/default/cpupower
	okie
    
    titleopts "Cambiando el scheduler del kernel a mq-deadline"
	cat >> /mnt/etc/udev/rules.d/60-ssd.rules <<- EOL
		ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
	EOL
	okie
	clear
	
logo "Aplicando optmizaciones.."

	titleopts "Modificando swappiness"
	cat >> /mnt/etc/sysctl.d/99-swappiness.conf <<- EOL
		vm.swappiness=10
		vm.vfs_cache_pressure=50
	EOL
	okie

	titleopts "Deshabilitando Journal logs.."
	sed -i 's/#Storage=auto/Storage=none/' /mnt/etc/systemd/journald.conf
	okie
    
    titleopts "Desabilitando modulos del kernel innecesarios"
	cat >> /mnt/etc/modprobe.d/blacklist.conf <<- EOL
		blacklist iTCO_wdt
		blacklist mousedev
		blacklist mac_hid
		blacklist uvcvideo
	EOL
	okie
	
	titleopts "Deshabilitando servicios innecesarios"
	echo
	$CHROOT systemctl mask lvm2-monitor.service systemd-random-seed.service
	okie
	clear
	
logo "Aplicando optmizaciones.."
	
	titleopts "Acelerando internet con los DNS de Cloudflare"
	if $CHROOT pacman -Qi dhcpcd > /dev/null ; then
	cat >> /mnt/etc/dhcpcd.conf <<- EOL
		noarp
		static domain_name_servers=1.1.1.1 1.0.0.1
	EOL
		else
	cat >> /mnt/etc/NetworkManager/conf.d/dns-servers.conf <<- EOL
		[global-dns-domain-*]
		servers=1.1.1.1,1.0.0.1
	EOL
	fi
	okie
	clear

	titleopts "Configurando almacenamiento personal"
	cat >> /mnt/etc/fstab <<-EOL		
	# My sTuFF
	UUID=01D3AE59075CA1F0		/run/media/$USR/windows	ntfs-3g		auto,rw,uid=1000,gid=984,hide_hid_files,windows_names,big_writes,noatime,dmask=022,fmask=133 0 0
	EOL
	
	okie
	clear
	
#----------------------------------------
#          Installing Packages
#----------------------------------------

logo "Instalando Audio & Video"	
	$CHROOT pacman -S \
					  mesa-amber xorg-server xf86-video-intel \
					  xorg-xinput xorg-xsetroot \
					  pipewire pipewire-pulse pipewire-alsa \
					  --noconfirm
	clear
	
logo "Instalando codecs multimedia y utilidades"
	$CHROOT pacman -S \
                      ffmpeg ffmpegthumbnailer aom libde265 x265 x264 libmpeg2 xvidcore libtheora libvpx sdl \
                      jasper openjpeg2 libwebp webp-pixbuf-loader \
                      unarchiver lha lrzip lzip p7zip lbzip2 arj lzop cpio unrar unzip zip unarj xdg-utils \
                      --noconfirm
	clear
	
logo "Instalando soporte para montar volumenes y dispositivos multimedia extraibles"
	$CHROOT pacman -S \
					  libmtp gvfs-nfs gvfs gvfs-mtp \
					  dosfstools usbutils net-tools \
					  xdg-user-dirs gtk-engine-murrine \
					  --noconfirm
	clear
	
logo "Instalando apps que yo uso"
	$CHROOT pacman -S \
					  android-file-transfer bleachbit gimp gcolor3 geany gparted simplescreenrecorder \
					  thunar thunar-archive-plugin tumbler xarchiver \
					  ranger htop scrot cmatrix ueberzug viewnior zathura zathura-pdf-poppler neovim \
					  retroarch retroarch-assets-xmb retroarch-assets-ozone \
					  pacman-contrib pass xclip playerctl yt-dlp minidlna \
					  firefox firefox-i18n-es-mx transmission-gtk \
					  papirus-icon-theme ttf-joypixels terminus-font grsync git \
					  --noconfirm
	clear
	
logo "Instalando Entorno de Escritorio"

	sed -i 's/#greeter-setup-script=/greeter-setup-script=\/usr\/bin\/numlockx on/' /mnt/etc/lightdm/lightdm.conf
	rm -f /mnt/etc/lightdm/lightdm-gtk-greeter.conf
	cat >> /mnt/etc/lightdm/lightdm-gtk-greeter.conf <<- EOL
		[greeter]
		icon-theme-name = Qogir-ubuntu
		background = /usr/share/pixmaps/arch.png
		user-background = false
		default-user-image = /usr/share/pixmaps/gh0st.png
		indicators = ~host;~spacer;~clock;~spacer;~session;~power
		position = 50%,center 83%,center
		screensaver-timeout = 0
		theme-name = Dracula
		font-name = UbuntuMono Nerd Font 11
	EOL
	
	clear
		
#----------------------------------------
#          AUR Packages
#----------------------------------------

	echo "cd && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd && rm -rf yay" | $CHROOT su "$USR"
	echo "cd && yay -S picom-jonaburg-fix polybar xtitle termite checkupdates-aur --noconfirm --removemake --cleanafter" | $CHROOT su "$USR"
	echo "cd && yay -S zramswap --noconfirm --removemake --cleanafter" | $CHROOT su "$USR"
	echo "cd && yay -S spotify spotify-adblock-git mpv-git popcorntime-bin --noconfirm --removemake --cleanafter" | $CHROOT su "$USR"
	echo "cd && yay -S whatsapp-nativefier telegram-desktop-bin --noconfirm --removemake --cleanafter" | $CHROOT su "$USR"
	echo "cd && yay -S stacer nerd-fonts-ubuntu-mono qogir-icon-theme nerd-fonts-jetbrains-mono --noconfirm --removemake --cleanafter" | $CHROOT su "$USR"

#----------------------------------------
#          Enable Services & other stuff
#----------------------------------------

logo "Activando Servicios"

	$CHROOT systemctl enable dhcpcd.service lightdm cpupower systemd-timesyncd.service
	$CHROOT systemctl enable zramswap

	echo "xdg-user-dirs-update" | $CHROOT su "$USR"
	echo "timeout 1s firefox --headless" | $CHROOT su "$USR"
	
#----------------------------------------
#          Reverting No Pasword Privileges
#----------------------------------------

	sed -i 's/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /mnt/etc/sudoers
	okie
	sleep 2
	clear

#----------------------------------------
#          Xorg conf only intel
#----------------------------------------

	
logo "Generating my XORG config files"
	
	cat >> /mnt/etc/X11/xorg.conf.d/20-intel.conf <<EOL		
Section "Device"
	Identifier	"Intel Graphics"
	Driver		"Intel"
	Option		"AccelMethod"	"sna"
	Option		"DRI"		"3"
	Option		"TearFree"	"true"
EndSection
EOL
		printf "%s20-intel.conf%s generated in --> /etc/X11/xorg.conf.d\n" "${CGR}" "${CNC}"
		  
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
		printf "$%s10-monitor.conf$%s generated in --> /etc/X11/xorg.conf.d\n" "${CGR}" "${CNC}"
		
	cat >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf <<EOL
Section "InputClass"
		Identifier	"system-keyboard"
		MatchIsKeyboard	"on"
		Option	"XkbLayout"	"${x11keymap}"
EndSection
EOL
		printf "%s00-keyboard.conf%s generated in --> /etc/X11/xorg.conf.d\n" "${CGR}" "${CNC}"
		
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
		printf "%sdrirc%s generated in --> /etc" "${CGR}" "${CNC}"
		sleep 2
		clear
	
#----------------------------------------
#          Restoring my dotfiles
#----------------------------------------
	

logo "Restaurando mis dotfiles. Esto solo funciona es mi maquina z0mbi3-b0x"
			
	mkdir /mnt/dots
	mount -U 6bca691d-82f3-4dd5-865b-994f99db54e1 -w /mnt/dots
	echo "rsync -vrtlpX /dots/dotfiles/ /home/$USR/" | $CHROOT su "$USR"
	$CHROOT mv /home/"$USR"/.themes/Dracula /usr/share/themes
	$CHROOT rm -rf /home/"$USR"/.themes
	$CHROOT cp /dots/stuff/zfetch /usr/bin/
	$CHROOT cp /dots/stuff/{arch.png,gh0st.png} /usr/share/pixmaps/
	$CHROOT cp -r /dots/stuff/z0mbi3-Fox-Theme/chrome /home/$USR/.mozilla/firefox/*.default-release/
	$CHROOT cp /dots/stuff/z0mbi3-Fox-Theme/chrome/user.js /home/$USR/.mozilla/firefox/*.default-release/
	okie
	sleep 5
	clear

#----------------------------------------
#          Cleaning Garbage
#----------------------------------------

logo "Limpiando sistema para su primer arranque"
	sleep 2
	rm -rf /mnt/home/"$USR"/dotfiles/
	rm -rf /mnt/home/"$USR"/.cache/yay/
	rm -rf /mnt/home/"$USR"/.cache/electron/
	rm -rf /mnt/home/"$USR"/.cache/go-build/
	rm -rf /mnt/home/"$USR"/.cargo/
	rm -f /mnt/usr/share/applications/{avahi-discover.desktop,bssh.desktop,bvnc.desktop,compton.desktop,picom.desktop,qv4l2.desktop,qvidcap.desktop,spotify.desktop,thunar-bulk-rename.desktop,thunar-settings.desktop,xfce4-about.desktop}

	$CHROOT pacman -Scc
	$CHROOT pacman -Rns go --noconfirm >/dev/null 2>&1
	$CHROOT pacman -Rns "$(pacman -Qtdq)" >/dev/null 2>&1
	$CHROOT fstrim -av >/dev/null
	okie
clear

#----------------------------------------
#                Bye
#----------------------------------------

	curl -s https://raw.githubusercontent.com/gh0stzk/Arch-Install/main/zfetch > zfetch
	mv zfetch /mnt/usr/bin/
	chmod +x /mnt/usr/bin/zfetch
	$CHROOT /usr/bin/zfetch
		
		echo
		echo
		
	while true; do
			read -rp "Quieres reiniciar ahora? [s/N]: " sn
		case $sn in
			[Ss]* ) umount -a >/dev/null 2>&1;reboot;;
			[Nn]* ) exit;;
			* ) printf "Error: solo escribe 's' o 'n'\n\n";;
		esac
	done
