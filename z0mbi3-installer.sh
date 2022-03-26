#!/bin/env bash
			
			
#----------------------------------------
#          Setting some vars
#----------------------------------------

clear
setfont ter-v18n
#tizo=$(curl -s https://ipapi.co/timezone)
#idiomains=$(curl -s https://ipapi.co/languages | awk -F "," '{print $1}' | sed 's/-/_/g' | sed "s|$|.UTF-8|")

CRE='\033[0;31m'
CYE='\033[0;33m'
CGR='\033[0;32m'
CBL='\033[0;94m'
CNC='\033[0m'
CHROOT="arch-chroot /mnt"

okie() {
	printf "\n\033[1;92m OK...\033[0m\n"
	sleep 2
}

#----------------------------------------
#          Logo z0mbi3              
#----------------------------------------

logo () {
	
	local text="${1:?}"
	echo -en "                                  
	               %%%                
	        %%%%%//%%%%%              
	      %%************%%%           
	  (%%//############*****%%
	%%%%%**###&&&&&&&&&###**//
	%%(**##&&&#########&&&##**
	%%(**##*****#####*****##**%%%
	%%(**##     *****     ##**
	   //##   @@**   @@   ##//
	     ##     **###     ##
	     #######     #####//
	       ###**&&&&&**###
	       &&&         &&&
	       &&&////   &&
	          &&//@@@**
	            ..***                
			  z0mbi3 Script\n\n"
    printf ' \033[0;31m[ \033[0m\033[1;93m%s\033[0m \033[0;31m]\033[0m\n\n' "${text}"
    sleep 3
}

#----------------------------------------
#          Check  BIOS CPU And Graphics
#----------------------------------------

logo "Checando modo de arranque"

	if [ -d /sys/firmware/efi/efivars ]; then	
			bootmode="uefi"
			echo " El escript se ejecutara en modo EFI"
			sleep 2
			clear			
		else		
			bootmode="mbrbios"
			echo " El escript se ejecutara en modo BIOS/MBR"
			sleep 2
			clear
	fi
	
#----------------------------------------
#          Testing Internet
#----------------------------------------

logo "Checando conexion a internet.."

	if ping archlinux.org -c 1 >/dev/null 2>&1; then
			echo -e " Espera....\n"
			sleep 3
			echo -e "${CGR} Si hay Internet!!${CNC}"
			sleep 2
			clear
		else
			echo " Error: Parace que no hay internet.."
			echo " Saliendo...."
			sleep 2
			exit 0
	fi
	
#----------------------------------------
#          Basic configuration information  
#----------------------------------------

logo "Selecciona la distribucion de tu teclado"

		setkmap_options=("Ingles US" "Español")
		PS3="Selecciona la distrubucion de tu teclado (1 o 2): "
	select opt in "${setkmap_options[@]}"; do
		case "$REPLY" in
			1) setkmap_title='US';setkmap='us';x11keymap="us";break;;
			2) setkmap_title='Español';setkmap='la-latin1';x11keymap="latam";break;;
			*) echo "Opcion invalida, intenta de nuevo.";continue;;
		esac
	done	

		printf '\nCambiando distribucion de teclado a %s\n' "${setkmap_title}"
		loadkeys "${setkmap}"
		okie
		clear
		

logo "Selecciona tu idioma"

		PS3="Selecciona tu idioma: "
	select idiomains in $(grep UTF-8 /etc/locale.gen | sed 's/\..*$//' | sed '/@/d' | awk '{print $1}' | uniq | sed 's/#//g')
		do
			if [ "$idiomains" ]; then
					break
			fi
		done
	
		printf '\nCambiando idioma a %s ...\n' "${idiomains}"
		echo "${idiomains}".UTF-8 UTF-8 >> /etc/locale.gen
		locale-gen >/dev/null 2>&1
		export LANG=${idiomains}.UTF-8
		okie
		clear
		
logo "Selecciona tu zona horaria"

		tzselection=$(tzselect  | tail -n1 )
		okie
		clear
		

		
#----------------------------------------
#          Getting Information   
#----------------------------------------

logo "Ingresa la informacion Necesaria"    	
	while true
		do 
				read -rp "Ingresa tu usuario: " USR
			if [[ "${USR}" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]]
				then 
					break
			fi 
			echo -e "Incorrecto!! Solo se permiten minusculas.\n"
		done  
		
			echo
	while
			read -rsp "Ingresa tu password: " PASSWD
			echo
			read -rsp "Confirma tu password: " CONF_PASSWD
			echo
			[ "$PASSWD" != "$CONF_PASSWD" ]
		do 
			echo "Los passwords no coinciden!!"; 
		done
			echo "Password correcto"
		
	while        
			echo
			read -rsp "Ingresa password para ROOT: " PASSWDR
			echo
			read -rsp "Confirma el password: " CONF_PASSWDR
			echo
			[ "$PASSWDR" != "$CONF_PASSWDR" ]
		do 
			echo "Los passwords no coinciden!!"; 
		done
			echo "Password correcto"
		
					
	while true
		do
				echo
				read -rp "Ingresa el nombre de tu maquina: " HNAME
			if [[ "${HNAME}" =~ ^[a-z][a-z0-9_.-]{0,62}[a-z0-9]$ ]]
				then 
					break 
			fi
			echo -e "Incorrecto!! No puede incluir mayusculas ni simbolos especiales\n"
		done
		clear
		
logo "Ingresa la informacion Necesaria"

			kernel_opts=("Linux (Default)" "Linux LTS" "Linux-Zen")
			PS3="Escoge el Kernel que usaras (1, 2 o 3): "
	select opt in "${kernel_opts[@]}"; do
		case "$REPLY" in
			1) kernel='linux';break;;
			2) kernel='linux-lts';break;;
			3) kernel='linux-zen';break;;
			*) echo "Opcion invalida, intenta de nuevo.";continue;;
		esac
	done
	
			echo
			red_options=("DHCPCD" "NetworkManager")
			PS3="Selecciona cliente para manejar Internet (1 o 2): "
	select opt in "${red_options[@]}"; do
		case "$REPLY" in
			1) redtitle='DHCPCD';redpack='dhcpcd';esys='dhcpcd.service';break;;
			2) redtitle='NetworkManager';redpack='networkmanager';esys='NetworkManager';break;;
			*) echo "Opcion invalida, intenta de nuevo.";continue;;
		esac
	done	

			echo
			audioopts=("PipeWire" "PulseAudio")
			PS3="Selecciona servidor de Audio (1 o 2): "
	select opt in "${audioopts[@]}"; do
		case "$REPLY" in
			1) audiotitle='PipeWire';audiopack='pipewire pipewire-pulse pipewire-alsa pipewire-jack';break;;
			2) audiotitle='PulseAudio';audiopack='pulseaudio';break;;
			*) echo "Opcion invalida, intenta de nuevo.";continue;;
		esac
	done
	
			echo    
			de_opts=("Bspwm" "Gnome Minimal" "Mate Minimal" "OpenBox" "Plasma Minimal" "XFCE" "Ninguno")
			PS3="Escoge el entorno de escritorio que deseas instalar (1, 2, 3, 4, 5, 6 o 7): "
	select opt in "${de_opts[@]}"; do
		case "$REPLY" in
			1) DEN='Bspwm';DE='bspwm rofi sxhkd dunst lxappearance nitrogen pavucontrol polkit-gnome';DM='lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings numlockx';SDM='lightdm';aurbspwm='picom-jonaburg-fix polybar xtitle';break;;
			2) DEN='Gnome Minimal';DE='gnome';DM='gdm';SDM='gdm.service';break;;
			3) DEN='Mate Minimal';DE='mate';DM='lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings numlockx';SDM='lightdm';break;;
			4) DEN='OpenBox';DE='openbox ttf-dejavu';DM='lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings numlockx';SDM='lightdm';break;;
			5) DEN='Plasma Minimal';DE='plasma-desktop';DM='sddm';SDM='sddm';break;;
			6) DEN='XFCE';DE='xfce4 xfce4-goodies';DM='lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings numlockx';SDM='lightdm';break;;
			7) DEN='Ninguno';break;;
			*) echo "Opcion invalida, intenta de nuevo.";continue;;
		esac
	done
			clear
			
logo "Ingresa la informacion Necesaria"
			PS3="Quieres instalar YAY como AUR Helper?: "
	select YAYH in "Si" "No"
		do
			if [ $YAYH ]; then
				break
			fi
		done
    
			echo
			PS3="Rstaurar mis dotfiles?: "
	select DOTS in "Si" "No"
		do
			if [ $DOTS ]; then
				break
			fi
		done
			clear
		
#----------------------------------------
#          Select DISK
#----------------------------------------

logo "Creando Formatenado y Montando Particiones"
			
			lsblk -d -e 7,11 -o NAME,SIZE,TYPE,MODEL
			echo "------------------------------"
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

	if [ "$bootmode" == "uefi" ]; then	
			cfdisk "${drive}"
			sleep 3
			partx -u "${drive}"
			clear
			
logo "Selecciona tu particion EFI"
			lsblk "${drive}" -I 8 -o NAME,SIZE,PARTTYPENAME
			echo
			
			PS3="Escoge la particion EFI que acabas de crear: "
		select efipart in $(fdisk -l "${drive}" | grep EFI | cut -d" " -f1) 
			do
				efipart="$efipart"
				echo
				echo -e " Formateando la particion EFI ${efipart}\n Espere.."
				sleep 3
				mkfs.fat -F 32 "${efipart}"
				okie
				clear
				break
			done
		
		else
			cfdisk "${drive}"
			clear
	fi
	
logo "Creando Formatenado y Montando Particiones"

			echo
			lsblk "${drive}" -I 8 -o NAME,SIZE,FSTYPE,PARTTYPENAME
			echo
			
			PS3="Escoge la particion raiz que acabas de crear donde Arch Linux se instalara: "
	select partroot in $(fdisk -l "${drive}" | grep Linux | cut -d" " -f1) 
		do
			partroot="$partroot"
			break
		done
		    echo
		    echo -e " Formateando la particion RAIZ {$partroot}\n Espere.."
		    sleep 3
			mkfs.ext4 -L Arch "${partroot}"
			mount "${partroot}" /mnt
			sleep 3				
			
	if [ "$bootmode" == "uefi" ]; then
	
			mkdir -p /mnt/efi
			mount "${efipart}" /mnt/efi
			sleep 3
	fi
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
				
					echo "Creando archivo swap.."
					sleep 2
					fallocate -l 2048M /mnt/swapfile
					chmod 600 /mnt/swapfile
					mkswap -L SWAP /mnt/swapfile >/dev/null
					echo " Montando Swap, espera.."
					swapon /mnt/swapfile
					sleep 3
					okie
					break
					
				elif [ "$swappart" = "No quiero swap" ]; then
					
					break
					
				elif [ "$swappart" ]; then
				
					echo
					echo " Formateando la particion swap, espera.."
					sleep 2
					mkswap -L SWAP "${swappart}" >/dev/null 2>&1
					echo " Montando Swap, espera.."
					swapon "${swappart}"
					sleep 3
					okie
					break
				fi
			done
	
			clear
	
#----------------------------------------
#          NTFS partition Select
#----------------------------------------
	
logo "Particion NTFS de Windows para compartir almacenamiento"
			lsblk -I 8 -o NAME,SIZE,PARTTYPENAME,FSTYPE,LABEL | grep "NTFS\|Microsoft"
			echo "------------------------------"
			echo
			PS3="Deseas montar una particion de almacenamiento compartida con WINDOWS, Escogela: "
		select ntfspart in $(fdisk -l | grep "NTFS\|Microsoft" | cut -d" " -f1) "Ninguna"
			do
				if [ "$ntfspart" ]; then
					break	
				fi				
			done
			clear
	
#----------------------------------------
#          Detectando Hardware
#----------------------------------------

logo "Detectando hardware.. espera.."
	
	# Detectando tarjeta WiFi
	if [ "$(lspci -d ::280)" ]; then
		WIFI=y
	fi
	
	# Detectando modelo CPU
	if lscpu | grep -q 'GenuineIntel'; then
			cpu_name="Intel"
			cpu_model="intel-ucode"
			cpu_atkm="intel_agp i915"
		else
			cpu_name="AMD"
			cpu_model="amd-ucode"
			cpu_atkm="amdgpu"
	fi
	
	# Detectando graficos
	
	if lspci | grep -qE "NVIDIA|GeForce"; then
			gpu_name="NVIDIA"
			gpu_drivers="nvidia nvidia-utils nvidia-settings"
		elif lspci | grep -qE "Radeon|AMD"; then
			gpu_name="AMD"
			gpu_drivers="mesa mesa-vdpau xf86-video-amdgpu vulkan-radeon libva-mesa-driver"
		elif lspci | grep -qE "Integrated Graphics Controller"; then
			gpu_name="Intel Integrated"
			gpu_drivers="xf86-video-intel mesa"
		elif lspci | grep -qE "Intel Corporation UHD"; then
			gpu_name="Intel HD"
			gpu_drivers="mesa libva-intel-driver libvdpau-va-gl vulkan-intel libva-intel-driver libva-utils"
		elif lspci | grep -qE "Virtio|VMware"; then
			gpu_name="Maquina Virtual"
			gpu_drivers="xf86-video-vmware"
    fi
		clear
	
#----------------------------------------
#          Info
#----------------------------------------
	
		echo
		echo -e "\n --------------------"
		echo
		
		echo -e " User:      ${CBL}$USR${CNC}"
		echo -e " Hostname:  ${CBL}$HNAME${CNC}"
		echo -e " CPU:       ${CBL}$cpu_name${CNC}"
		echo -e " Kernel:    ${CBL}$kernel${CNC}"
		echo -e " Graficos:  ${CBL}$gpu_name${CNC}"
		echo -e " Lenguaje:  ${CBL}$idiomains${CNC}"
		echo -e " Timezone:  ${CBL}$tzselection${CNC}"
		echo -e " Teclado:   ${CBL}$setkmap_title${CNC}"
		echo -e " Internet:  ${CBL}$redtitle${CNC}"
		echo -e " Audio:     ${CBL}$audiotitle${CNC}"
		echo -e " Desktop:   ${CBL}$DEN${CNC}"
    
	if [ "${YAYH}" = "Si" ]; then
			echo -e " Yay:       ${CGR}Si${CNC}"
		else
			echo -e " Yay:       ${CRE}No${CNC}"
	fi
		
	if [ "${DOTS}" = "Si" ]; then
			echo -e " Dotfiles:  ${CGR}Si${CNC}"
		else
			echo -e " Dotfiles:  ${CRE}No${CNC}"
	fi
	
	if [ "$swappart" = "Crear archivo swap" ]; then
			echo -e " Swap:      ${CGR}Si${CNC} se crea archivo swap de 2G"
	elif [ "$swappart" = "No quiero swap" ]; then
			echo -e " Swap:      ${CRE}No${CNC}"
	elif [ "$swappart" ]; then
			echo -e " Swap:      ${CGR}Si${CNC} en ${CYE}[${CNC}${CBL}${swappart}${CNC}${CYE}]${CNC}"
	fi
		
	if [ "${ntfspart}" != "Ninguna" ]; then
			echo -e " Almacenamiento Personal:  ${CGR}Si${CNC} en ${CYE}[${CNC}${CBL}${ntfspart}${CNC}${CYE}]${CNC}"
		else
			echo -e " Almacenamiento Personal:  ${CRE}No${CNC}"
	fi
		
			echo		
			echo -e " Arch Linux se instalara en el disco ${CYE}[${CNC}${CRE}$drive${CNC}${CYE}]${CNC} en la particion ${CYE}[${CNC}${CBL}${partroot}${CNC}${CYE}]${CNC}"
			echo
			echo
		
	while true; do
			read -rp " Deseas continuar? [s/N]: " sn
		case $sn in
			[Ss]* ) break;;
			[Nn]* ) exit;;
			* ) echo " Error: solo necesitas escribir 's' o 'n'";;
		esac
	done
			clear


#----------------------------------------
#          Pacstrap base system
#----------------------------------------

logo "Instalando sistema base"
	sed -i 's/#Color/Color/; s/#ParallelDownloads = 5/ParallelDownloads = 5/; /^ParallelDownloads =/a ILoveCandy' /etc/pacman.conf
	reflector --verbose --latest 5 --country 'United States' --age 6 --sort rate --save /etc/pacman.d/mirrorlist >/dev/null 2>&1
	pacstrap /mnt \
	         base \
	         base-devel \
	         "$kernel" \
	         linux-firmware \
	         "$redpack" \
	         "$cpu_model" \
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
		
		$CHROOT ln -sf /usr/share/zoneinfo/"$tzselection" /etc/localtime
		$CHROOT hwclock --systohc
		echo
		echo "${idiomains}".UTF-8 UTF-8 >> /mnt/etc/locale.gen
		#sed -i 's/#'"${idiomains}"'/'"${idiomains}"'/' /mnt/etc/locale.gen
		$CHROOT locale-gen
		echo "LANG=$idiomains".UTF-8 >> /mnt/etc/locale.conf
		echo "KEYMAP=$setkmap" >> /mnt/etc/vconsole.conf
		echo "FONT=ter-v18n" >> /mnt/etc/vconsole.conf
		export LANG=${idiomains}.UTF-8
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
	echo -e " ${CBL}root${CNC} : ${CRE}$PASSWDR${CNC}\n ${CYE}$USR${CNC} : ${CRE}$PASSWD${CNC}"
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

	if [ "$bootmode" == "uefi" ]; then
	
			$CHROOT pacman -S grub efibootmgr os-prober ntfs-3g --noconfirm >/dev/null
			$CHROOT grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Arch
		else		
			$CHROOT pacman -S grub os-prober ntfs-3g --noconfirm >/dev/null
			$CHROOT grub-install --target=i386-pc "$drive"
	fi
	
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

	echo -e "${CYE}Enchulando pacman${CNC}"
	sed -i 's/#Color/Color/; s/#ParallelDownloads = 5/ParallelDownloads = 5/; /^ParallelDownloads =/a ILoveCandy' /mnt/etc/pacman.conf
	okie
    
	echo -e "\n${CYE}Tunning ext4 file system for SSD and SpeedUp${CNC}"
	sed -i 's/relatime/noatime,commit=120,barrier=0/' /mnt/etc/fstab
	$CHROOT tune2fs -O fast_commit "${partroot}" >/dev/null
	okie
    
	echo -e "\n${CYE}Optimizando las make flags para acelerar tiempos de compilado${CNC}\n"
	echo -e "Tienes ${CBL}$(nproc)${CNC} cores."
	sed -i 's/march=x86-64/march=native/; s/mtune=generic/mtune=native/; s/-O2/-O3/; s/#MAKEFLAGS="-j2/MAKEFLAGS="-j'"$(nproc)"'/' /mnt/etc/makepkg.conf
	okie
	clear
	
logo "Aplicando optmizaciones.."
    
	echo -e "\n${CYE}Configurando CPU a modo performance${CNC}"
	$CHROOT pacman -S cpupower --noconfirm >/dev/null
	sed -i "s/#governor='ondemand'/governor='performance'/" /mnt/etc/default/cpupower
	okie
    
	echo -e "\n${CYE}Cambiando el scheduler del kernel a mq-deadline${CNC}"
	cat >> /mnt/etc/udev/rules.d/60-ssd.rules <<- EOL
		ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
	EOL
	okie

	echo -e "\n${CYE}Configurando swappiness${CNC}"
	cat >> /mnt/etc/sysctl.d/99-swappiness.conf <<- EOL
		vm.swappiness=10
		vm.vfs_cache_pressure=50
	EOL
	okie
	clear

logo "Aplicando optmizaciones.."

	echo -e "\n${CYE}Deshabilitando Journal logs..${CNC}"
	sed -i 's/#Storage=auto/Storage=none/' /mnt/etc/systemd/journald.conf
	okie
    
	echo -e "\n${CYE}Desabilitando modulos del kernel innecesarios${CNC}"
	cat >> /mnt/etc/modprobe.d/blacklist.conf <<- EOL
		blacklist iTCO_wdt
		blacklist mousedev
		blacklist mac_hid
		blacklist uvcvideo
	EOL
	okie
		
	echo -e "\n${CYE}Deshabilitando servicios innecesarios${CNC}\n"
	$CHROOT systemctl mask lvm2-monitor.service systemd-random-seed.service
	okie
		
	echo -e "\n${CYE}Acelerando internet con los DNS de Cloudflare${CNC}"
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
    
	if [ "${ntfspart}" != "Ninguna" ]; then
	
logo "Aplicando optmizaciones.."

		echo -e "\n${CYE}Configurando almacenamiento personal${CNC}\n"
		ntfsuuid=$(blkid -o value -s UUID "${ntfspart}") 
		cat >> /mnt/etc/fstab <<-EOL		
		# My sTuFF
		UUID=${ntfsuuid}		/run/media/$USR/windows	ntfs-3g		auto,rw,uid=1000,gid=984,hide_hid_files,windows_names,big_writes,noatime,dmask=022,fmask=133 0 0
		EOL
		cat /mnt/etc/fstab
		echo
		echo -e "${CYE}Tu particion compartida NTFS 'WINDOWS' Se cargara automaticamente en cada inicio para que puedas compartir archivos entre Linux y Windows.${CNC}"
		sleep 5
		okie
		clear
	fi
	
#----------------------------------------
#          Installing Packages
#----------------------------------------

logo "Instalando Audio & Video"	
	$CHROOT pacman -S \
					  xorg-server $gpu_drivers \
					  xorg-xinput xorg-xsetroot \
					  $audiopack \
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
		$CHROOT pacman -S $DE $DM --noconfirm
	
	if $CHROOT pacman -Qi lightdm >/dev/null 2>&1; then
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
	fi
	clear
	
logo "Instalando soporte WIFI"
	if [ "$WIFI" = "y" ]; then
			$CHROOT pacman -S iwd dialog wpa_supplicant wireless_tools --noconfirm
		else
			echo -e " No tienes tarjeta de red WIFI. No se instala.."
			sleep 5
	fi
	clear
		
#----------------------------------------
#          AUR Packages
#----------------------------------------

	if [ "${YAYH}" == "Si" ]; then

		logo "Instalando YAY"
			sleep 2
				echo "cd && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd && rm -rf yay" | $CHROOT su "$USR"
			clear
	fi
	
	if [ "$DEN" == "Bspwm" ]; then
	
		if $CHROOT pacman -Qi yay >/dev/null 2>&1; then
			logo "Complementando BSPWM"
				echo "cd && yay -S $aurbspwm --noconfirm --removemake --cleanafter" | $CHROOT su "$USR"
			clear
		else
			logo "Necesitas YAY para complemetar BSPWM"
				echo -e "\n Para instalar Polybar y Picom es necesario YAY.."
				echo -e " Instalando YAY.."
			sleep 2
				echo "cd && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd && rm -rf yay" | $CHROOT su "$USR"
			clear
		logo "Complementando BSPWM"
				echo "cd && yay -S $aurbspwm --noconfirm --removemake --cleanafter" | $CHROOT su "$USR"
			clear
		fi
	fi
		
	if [ "${YAYH}" == "Si" ]; then

		logo "zramswap termite"
			sleep 2
				echo "cd && yay -S zramswap termite checkupdates-aur --noconfirm --removemake --cleanafter" | $CHROOT su "$USR"
			clear
		logo "spotify spotify-adblock mpv popcorn-time"
			sleep 2
				echo "cd && yay -S spotify spotify-adblock-git mpv-git popcorntime-bin --noconfirm --removemake --cleanafter" | $CHROOT su "$USR"
			clear
		logo "Whatsapp & Telegram"
			sleep 2
				echo "cd && yay -S whatsapp-nativefier telegram-desktop-bin --noconfirm --removemake --cleanafter" | $CHROOT su "$USR"
			clear
		logo "Iconos, fuentes & stacer"
			sleep 2
				echo "cd && yay -S stacer nerd-fonts-jetbrains-mono nerd-fonts-ubuntu-mono qogir-icon-theme --noconfirm --removemake --cleanafter" | $CHROOT su "$USR"
			clear
		fi

#----------------------------------------
#          Enable Services & other stuff
#----------------------------------------

logo "Activando Servicios"
	$CHROOT systemctl enable $esys $SDM cpupower systemd-timesyncd.service
	$CHROOT systemctl enable zramswap
		
	cat >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf <<EOL
Section "InputClass"
		Identifier	"system-keyboard"
		MatchIsKeyboard	"on"
		Option	"XkbLayout"	"${x11keymap}"
EndSection
EOL
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
#          My DOTFILES
#----------------------------------------

	if [ "${DOTS}" == "Si" ]; then
	
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

logo "Restaurando mis dotfiles"
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
		clear
	fi

#----------------------------------------
#          Cleaning Garbage
#----------------------------------------

logo "Limpiando sistema para su primer arranque"
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

	$CHROOT pacman -Scc
	$CHROOT pacman -Rns go --noconfirm >/dev/null
	$CHROOT pacman -Rns "$(pacman -Qtdq)" >/dev/null
	$CHROOT fstrim -av >/dev/null
	okie
clear

#----------------------------------------
#                Bye
#----------------------------------------

logo "Instalacion Finalizada"

echo -e "          .            "
echo -e "         / \           I use Arch BTW.."
echo -e "        /   \          ==========================="     
echo -e "       /^.   \         os       $(source /mnt/etc/os-release && echo "${PRETTY_NAME}")"    
echo -e "      /  .-.  \        Kernel   $(uname -r)"   
echo -e "     /  (   ) _\       pkgs     $(arch-chroot /mnt pacman -Q | wc -l)"
echo -e "    / _.~   ~._^\      ram      $(free --mega | sed -n -E '2s/^[^0-9]*([0-9]+) *([0-9]+).*/''\2 MB/p')"
echo -e "   /.^         ^.\     Disk     $(df -h / | grep "/" | awk '{print $3}')"
		
		echo
		echo
		
	while true; do
			read -rp "Quieres reiniciar ahora? [s/N]: " sn
		case $sn in
			[Ss]* ) umount -a >/dev/null;reboot;;
			[Nn]* ) exit;;
			* ) echo "Error: solo escribe 's' o 'n'";;
		esac
	done

# Agregue info de la swap
# Agregue comando para ejecutar firefox y generar el perfil y directorios.
# copy firefox theme to new firefox default dirs created
# Agregue zona horaria y lenguaje general
