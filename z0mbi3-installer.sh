#!/bin/env bash
			
			
#----------------------------------------
#          Setting some vars
#----------------------------------------

clear
setfont ter-v18n
#tizo=$(curl -s https://ipapi.co/timezone)
#idiomains=$(curl -s https://ipapi.co/languages | awk -F "," '{print $1}' | sed 's/-/_/g' | sed "s|$|.UTF-8|")

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
	printf " \n%s>>>%s %s%s%s\n\n" "${CBL}" "${CNC}" "${CYE}" "${textopts}" "${CNC}"
	
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
			printf " El escript se ejecutara en modo EFI"
			sleep 2
			clear			
		else		
			bootmode="mbrbios"
			printf " El escript se ejecutara en modo BIOS/MBR"
			sleep 2
			clear
	fi
	
#----------------------------------------
#          Testing Internet
#----------------------------------------

logo "Checando conexion a internet.."

	if ping archlinux.org -c 1 >/dev/null 2>&1; then
			printf " Espera....\n"
			sleep 3
			printf " %sSi hay Internet!!%s" "${CGR}" "${CNC}"
			sleep 2
			clear
		else
			printf " Error: Parace que no hay internet..\n\n Saliendo...."
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
			1)
				setkmap_title='US';
				setkmap='us';
				x11keymap="us";
				break;;
			2)
				setkmap_title='Español';
				setkmap='la-latin1';
				
				x11keymap="latam";break;;
			*)
				echo "Opcion invalida, intenta de nuevo.";
				continue;;
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
			printf "Los passwords no coinciden!!\n\n"; 
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

			kernel_opts=("Linux (Default)" "Linux LTS" "Linux-Zen")
			PS3="Escoge el Kernel que usaras (1, 2 o 3): "
	select opt in "${kernel_opts[@]}"; do
		case "$REPLY" in
			1)
				kernel='linux';
				break;;
			2)
				kernel='linux-lts';
				break;;
			3)
				kernel='linux-zen';
				break;;
			*)
				printf "Opcion invalida, intenta de nuevo.\n";
				continue;;
		esac
	done
	
			echo
			red_options=("DHCPCD" "NetworkManager")
			PS3="Selecciona cliente para manejar Internet (1 o 2): "
	select opt in "${red_options[@]}"; do
		case "$REPLY" in
			1)
				redtitle='DHCPCD';
				redpack='dhcpcd';
				esys='dhcpcd.service';
				break;;
			2)
				redtitle='NetworkManager';
				redpack='networkmanager';
				esys='NetworkManager';
				break;;
			*)
				printf "Opcion invalida, intenta de nuevo.\n";
				continue;;
		esac
	done	

			echo
			audioopts=("PipeWire" "PulseAudio")
			PS3="Selecciona servidor de Audio (1 o 2): "
	select opt in "${audioopts[@]}"; do
		case "$REPLY" in
			1)
				audiotitle='PipeWire';
				audiopack='pipewire pipewire-pulse pipewire-alsa pipewire-jack';
				break;;
			2)
				audiotitle='PulseAudio';
				audiopack='pulseaudio';
				break;;
			*)
				printf "Opcion invalida, intenta de nuevo.\n";
				continue;;
		esac
	done
	
			echo    
			de_opts=("Bspwm" "Gnome Minimal" "Mate Minimal" "OpenBox" "Plasma Minimal" "XFCE" "Ninguno")
			PS3="Escoge el entorno de escritorio que deseas instalar (1, 2, 3, 4, 5, 6 o 7): "
	select opt in "${de_opts[@]}"; do
		case "$REPLY" in
			1)
				DEN='Bspwm';
				DE='bspwm rofi sxhkd dunst lxappearance nitrogen pavucontrol polkit-gnome';
				DM='lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings numlockx';
				SDM='lightdm';
				aurbspwm='picom-jonaburg-fix polybar xtitle';
				break;;
			2)
				DEN='Gnome Minimal';DE='gnome';DM='gdm';SDM='gdm.service';break;;
			3)
				DEN='Mate Minimal';
				DE='mate';
				DM='lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings numlockx';
				SDM='lightdm';
				break;;
			4)
				DEN='OpenBox';
				DE='openbox ttf-dejavu';
				DM='lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings numlockx';
				SDM='lightdm';
				break;;
			5)
				DEN='Plasma Minimal';
				DE='plasma-desktop';
				DM='sddm';
				SDM='sddm';
				break;;
			6)
				DEN='XFCE';
				DE='xfce4 xfce4-goodies';
				DM='lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings numlockx';
				SDM='lightdm';
				break;;
			7)
				DEN='Ninguno';
				break;;
			*)
				printf "Opcion invalida, intenta de nuevo.\n";
				continue;;
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
		printf "------------------------------"
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
		do true
				
			echo
			printf " Formateando la particion EFI %s\n Espere.." "${efipart}"
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
		do true
			
			break
		done
		    echo
		    printf " Formateando la particion RAIZ %s\n Espere..\n" "{$partroot}"
		    sleep 3
			mkfs.ext4 -L Arch "${partroot}"
			mount "${partroot}" /mnt
			sleep 3				
			
	if [ "$bootmode" == "uefi" ]; then
	
			printf " Configurando y montando la particion EFI\n Espere..\n"
			sleep 3
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
				
				printf "Creando archivo swap.."
				sleep 2
				fallocate -l 2048M /mnt/swapfile
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
#          NTFS partition Select
#----------------------------------------
	
logo "Particion NTFS de Windows para compartir almacenamiento"

			lsblk -o NAME,SIZE,PARTTYPENAME,FSTYPE,LABEL | grep "NTFS\|Microsoft"
			printf "------------------------------\n"
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
	
		printf "\n\n --------------------\n\n" """"""
		printf " User:      %s%s%s\n" "${CBL}" "$USR" "${CNC}"
		printf " Hostname:  %s%s%s\n" "${CBL}" "$HNAME" "${CNC}"
		printf " CPU:       %s%s%s\n" "${CBL}" "$cpu_name" "${CNC}"
		printf " Kernel:    %s%s%s\n" "${CBL}" "$kernel" "${CNC}"
		printf " Graficos:  %s%s%s\n" "${CBL}" "$gpu_name" "${CNC}"
		printf " Lenguaje:  %s%s%s\n" "${CBL}" "$idiomains" "${CNC}"
		printf " Timezone:  %s%s%s\n" "${CBL}" "$tzselection" "${CNC}"
		printf " Teclado:   %s%s%s\n" "${CBL}" "$setkmap_title" "${CNC}"
		printf " Internet:  %s%s%s\n" "${CBL}" "$redtitle" "${CNC}"
		printf " Audio:     %s%s%s\n" "${CBL}" "$audiotitle" "${CNC}"
		printf " Desktop:   %s%s%s\n" "${CBL}" "$DEN" "${CNC}"
    
	if [ "${YAYH}" = "Si" ]; then
			printf " Yay:       %sSi%s\n" "${CGR}" "${CNC}"
		else
			printf " Yay:       %sNo%s\n" "${CRE}" "${CNC}"
	fi
		
	if [ "${DOTS}" = "Si" ]; then
			printf " Dotfiles:  %sSi%s\n" "${CGR}" "${CNC}"
		else
			printf " Dotfiles:  %sNo%s\n" "${CRE}" "${CNC}"
	fi
	
	if [ "$swappart" = "Crear archivo swap" ]; then
			printf " Swap:      %sSi%s se crea archivo swap de 2G\n" "${CGR}" "${CNC}"
	elif [ "$swappart" = "No quiero swap" ]; then
			printf " Swap:      %sNo%s\n" "${CRE}" "${CNC}"
	elif [ "$swappart" ]; then
			printf " Swap:      %sSi%s en %s[%s%s%s%s%s]%s\n" "${CGR}" "${CNC}" "${CYE}" "${CNC}" "${CBL}" "${swappart}" "${CNC}" "${CYE}" "${CNC}"
	fi
		
	if [ "${ntfspart}" != "Ninguna" ]; then
			printf " Almacenamiento Personal:  %sSi%s en %s[%s%s%s%s%s]%s" "${CGR}" "${CNC}" "${CYE}" "${CNC}" "${CBL}" "${ntfspart}" "${CNC}" "${CYE}" "${CNC}"
		else
			printf " Almacenamiento Personal:  %sNo%s\n" "${CRE}" "${CNC}"
	fi
		
			echo		
			printf " Arch Linux se instalara en el disco %s[%s%s%s%s%s]${CNC}%s en la particion %s[%s%s%s%s%s]%s\n\n\n" "${CYE}" "${CNC}" "${CRE}" "${drive}" "${CNC}" "${CYE}" "${CYE}" "${CNC}" "${CBL}" "${partroot}" "${CNC}" "${CYE}" "${CNC}"
		
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
	printf " %sroot%s : %s%s%s\n %s%s%s : %s%s%s" "${CBL}" "${CNC}" "${CRE}" "${PASSWDR}" "${CNC}" "${CYE}" "${USR}" "${CNC}" "${CRE}" "${PASSWD}" "${CNC}"
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

	titleopts "Editando pacman. Se activan descargas paralelas, el color y el easter egg ILoveCandy"
	sed -i 's/#Color/Color/; s/#ParallelDownloads = 5/ParallelDownloads = 5/; /^ParallelDownloads =/a ILoveCandy' /mnt/etc/pacman.conf
	okie
    
    titleopts "Optimiza y acelera ext4 para SSD"
	sed -i '0,/relatime/s/relatime/noatime,commit=120,barrier=0/' /mnt/etc/fstab
	$CHROOT tune2fs -O fast_commit "${partroot}" >/dev/null
	okie
    
    titleopts "Optimizando las make flags para acelerar tiempos de compilado"
	printf "Tienes %s%s%s cores\n" "${CBL}" "$(nproc)" "${CNC}"
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
    
	if [ "${ntfspart}" != "Ninguna" ]; then
	
logo "Aplicando optmizaciones.."

	titleopts "Configurando almacenamiento personal"
	ntfsuuid=$(blkid -o value -s UUID "${ntfspart}") 
	cat >> /mnt/etc/fstab <<-EOL		
	# My sTuFF
	UUID=${ntfsuuid}		/run/media/$USR/windows	ntfs-3g		auto,rw,uid=1000,gid=984,hide_hid_files,windows_names,big_writes,noatime,dmask=022,fmask=133 0 0
	EOL
	
	printf "La particion Windows %s %s Se cargara automaticamente en cada inicio para compartir archivos entre tu Linux y Windows.\n" "${ntfspart}" "${ntfsuuid}"
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
			printf " No tienes tarjeta de red WIFI. No se instala.."
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

	if [ "${gpu_name}" == "Intel Integrated" ]; then
	
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
	fi
	
		if [ "${DOTS}" == "Si" ]; then
		
logo "Restaurando mis dotfiles"

		mkdir /mnt/dots
		mount -U 6bca691d-82f3-4dd5-865b-994f99db54e1 -w /mnt/dots
		echo "rsync -vrtlpX /dots/dotfiles/ /home/$USR/" | $CHROOT su "$USR"
		$CHROOT mv /home/"$USR"/.themes/Dracula /usr/share/themes
		$CHROOT rm -rf /home/"$USR"/.themes
		
		# Some images
		printf "Descargando algunas images y mi version modificada del theme DRACULA"
		curl -sLO https://github.com/gh0stzk/dotfiles/raw/master/gh0st.png | $CHROOT su "$USR"
		curl -sLO https://github.com/gh0stzk/dotfiles/raw/master/arch.png | $CHROOT su "$USR"
		mv /mnt/home/"$USR"/{arch.png,gh0st.png} /usr/share/pixmaps/
		
		# My Firefox theme
		printf " Descargando y aplicando z0mbi3-F0x Firefox theme\n Espera.."
		git clone https://github.com/gh0stzk/z0mbi3-f0x.git >/dev/null 2>&1 | $CHROOT su "$USR"
		mv /mnt/home/"$USR"/z0mbi3-f0x/z0mbi3-Fox-Theme/chrome /mnt/home/"$USR"/.mozilla/firefox/*.default-release/
		mv /mnt/home/"$USR"/z0mbi3-f0x/z0mbi3-Fox-Theme/user.js /mnt/home/"$USR"/.mozilla/firefox/*.default-release/
		
		okie
		clear
	fi

#----------------------------------------
#          Cleaning Garbage
#----------------------------------------

logo "Limpiando sistema para su primer arranque"
	sleep 2
	rm -rf /mnt/home/"$USR"/z0mbi3-f0x/
	rm -rf /mnt/home/"$USR"/.cache/yay/
	rm -rf /mnt/home/"$USR"/.cache/electron/
	rm -rf /mnt/home/"$USR"/.cache/go-build/
	rm -rf /mnt/home/"$USR"/.cargo/

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
