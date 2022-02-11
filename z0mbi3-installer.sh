#!/bin/env bash
			
			
		clear
		loadkeys la-latin1
		export LANG=es_MX.UTF-8
    
Rojo='\033[0;31m'
Amarillo='\033[0;33m'
Verde='\033[0;32m'
Azul='\033[0;94m'
NoColor='\033[0m'
CHROOT="arch-chroot /mnt"

########################################
#             Logo z0mbi3              #
########################################

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
    echo -e "${Verde}\n\n\n   Cargando...${NoColor}"
    sleep 5
    clear
		
########## Comprobando UEFI y Conexion
		
	    if [ -d /sys/firmware/efi/efivars ]; then
        echo "Este script solo funciona con BIOS/MBR."
        sleep 2
			exit
		else
			break
		fi
    
		echo "Probando conexion a internet"
		echo -e "Espera.... ${Verde}OK..${NoColor}"
		ping archlinux.org -c 1 >/dev/null 2>&1

		if [ $? != "0" ]
		then
		echo "Error: Tal parece que no tienes internet.."
		echo "saliendo...."
		exit
		fi
		
########## Datos    
    
		echo -e "\n\n${Amarillo} Recopilando datos necesarios${NoColor}\n"
while true
	do 
		read -p "Ingresa tu nombre de usuario: " USR
		if [[ "${USR}" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]]
		then 
			break
		fi 
		echo -e "Incorrecto!! Solo se permiten minusculas.\n"
	done  
	
while
        echo
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
        read -rsp "Ingresa el password para ROOT: " PASSWDR
        echo
        read -rsp "Confirma tu password: " CONF_PASSWDR
        echo
		[ "$PASSWDR" != "$CONF_PASSWDR" ]
	do 
		echo "Los passwords no coinciden!!"; 
	done
		echo "Password correcto"
		
		echo		
while true
	do 
		read -rp "Ingresa el nombre de tu maquina: " HNAME
		if [[ "${HNAME}" =~ ^[a-z][a-z0-9_.-]{0,62}[a-z0-9]$ ]]
		then 
			break 
		fi
		echo -e "Incorrecto!! No puede incluir mayusculas ni simbolos especiales\n"
	done	    
    
        partroot="$(findmnt -Dn -M /mnt -o SOURCE)"
		echo
		lsblk -d -e 7,11 -o NAME,FSTYPE,FSAVAIL,MOUNTPOINTS
		echo "------------------------------"
		echo
		PS3="Escoge el disco donde se instalara Arch Linux: "
    select drive in $(lsblk -nd -e 7,11 -o NAME) 
    do
        if [ $drive ]; then
            break
        fi
    done
		
		echo    
		plat_options=("Intel" "AMD" "VM")
		PS3="Selecciona tu CPU (1, 2 o 3): "
	select opt in "${plat_options[@]}"; do 
		case "$REPLY" in
		1) packa='intel-ucode';gp='intel_agp i915';break;;
		2) packa='amd-ucode';gp='amdgpu';break;;
		3) packa='qemu-guest-agent';gp='vmwgfx';break;;
		*) echo "Opcion invalida!! trata de nuevo.";continue;;
		esac
	done

		echo
		kernel_options=("Linux" "Linux LTS" "Linux Zen")
		PS3="Selecciona el Kernel (1, 2 o 3): "
	select opt in "${kernel_options[@]}"; do
		case "$REPLY" in
		1) kerneltitle='Linux (Arch Default)';kernelpack='linux';break;;
		2) kerneltitle='Linux LTS';kernelpack='linux-lts';break;;
		3) kerneltitle='Linux Zen';kernelpack='linux-zen';break;;
		*) echo "Opcion invalida!! trata de nuevo.";continue;;
		esac
	done

		echo
		graf_options=("Intel" "AMD" "NVIDIA" "VM")
		PS3="Selecciona tus graficos (1, 2, 3 o 4): "
	select opt in "${graf_options[@]}"; do
		case "$REPLY" in
		1) graftitle='Intel';grafpack='xf86-video-intel vulkan-intel';break;;
		2) graftitle='AMD';grafpack='xf86-video-amdgpu';break;;
		3) graftitle='NVIDIA';grafpack='nvidia';break;;
		4) graftitle='Maquina Virtual';grafpack='xf86-video-vmware';break;;
		*) echo "Opcion invalida!! trata de nuevo.";continue;;
		esac
	done

		echo
		red_options=("DHCPCD" "NetworkManager")
		PS3="Selecciona el cliente para manejar Internet (1 o 2): "
	select opt in "${red_options[@]}"; do
		case "$REPLY" in
		1) redtitle='DHCPCD';redpack='dhcpcd';esys='dhcpcd.service';break;;
		2) redtitle='NetworkManager';redpack='networkmanager';esys='NetworkManager';break;;
		*) echo "Opcion invalida!! trata de nuevo.";continue;;
		esac
	done	

		echo
		audio_options=("PipeWire" "PulseAudio")
		PS3="Selecciona el audio (1 o 2): "
	select opt in "${audio_options[@]}"; do
		case "$REPLY" in
		1) audiotitle='PipeWire';audiopack='pipewire pipewire-pulse';break;;
		2) audiotitle='PulseAudio';audiopack='pulseaudio';break;;
		*) echo "Opcion invalida!! trata de nuevo.";continue;;
		esac
	done

		echo
		PS3="Quieres instalar YAY como AUR Helper?: "
	select YAYH in "Si" "No"
		do
			if [ $YAYH ]; then
				break
			fi
		done
    
		echo
		PS3="Restaurar dotfiles?: "
	select DOTS in "Si" "No"
		do
			if [ $DOTS ]; then
				break
			fi
		done
		
		echo
		PS3="Montar almacenamiento personal?: "
	select MPW in "Si" "No"
		do
			if [ $MPW ]; then
				break
			fi
		done
		
		echo
		PS3="Instalar entorno XFCE?: "
	select DEXFCE in "Si" "No"
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
		
		echo -e " Usuario:   ${Azul}$USR${NoColor}"
		echo -e " Hostname:  ${Azul}$HNAME${NoColor}"
		echo -e " CPU:       ${Azul}$plat_options${NoColor}"
		echo -e " Kernel:    ${Azul}$kerneltitle${NoColor}"
		echo -e " Graficos:  ${Azul}$graftitle${NoColor}"
		echo -e " Internet:  ${Azul}$redtitle${NoColor}"
		echo -e " Sonido:    ${Azul}$audiotitle${NoColor}"
    
		if [ "${YAYH}" = "Si" ]; then
			echo -e " Yay:       ${Verde}Si${NoColor}"
		else
			echo -e " Yay:       ${Rojo}No${NoColor}"
		fi
		
		if [ "${DOTS}" = "Si" ]; then
			echo -e " Dotfiles:  ${Verde}Si${NoColor}"
		else
			echo -e " Dotfiles:  ${Rojo}No${NoColor}"
		fi
		
		if [ "${DEXFCE}" = "Si" ]; then
			echo -e " Xfce:      ${Verde}Si${NoColor}"
		else
			echo -e " Xfce:      ${Rojo}No${NoColor}"
		fi
		
		if [ "${MPW}" = "Si" ]; then
			echo -e " Montar Storage:  ${Verde}Si${NoColor}"
		else
			echo -e " Montar Storage:  ${Rojo}No${NoColor}"
		fi
		
		echo		
		echo -e " Arch Linux se instalara en el disco ${Amarillo}[${NoColor}${Rojo}$drive${NoColor}${Amarillo}]${NoColor} en la particion ${partroot}"
    
		echo
		echo
while true; do
    read -p "Continuar con la instalacion? [s/N]: " sn
    case $sn in
        [Ss]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Eres estupido o que, solo tienes que escribir 'si' o 'no'";;
    esac
done
    
		clear

########## SISTEMA BASE PACSTRAP

		echo -e "\n\n\n${Amarillo} Instalando sistema base${NoColor}\n"
		sed -i 's/#Color/Color/; s/#ParallelDownloads = 5/ParallelDownloads = 10/; /^ParallelDownloads =/a ILoveCandy' /etc/pacman.conf
		reflector --verbose --latest 5 --country 'United States' --age 6 --sort rate --save /etc/pacman.d/mirrorlist
		echo
		pacstrap /mnt base base-devel $kernelpack linux-firmware $packa $redpack reflector cpupower grub os-prober zsh
		echo -e "\n\n${Verde} OK...${NoColor}"
		sleep 2
		clear
    
########## FSTAB
    
		echo -e "\n\n\n${Amarillo} Generando fstab..${NoColor}"
		genfstab -U /mnt >> /mnt/etc/fstab
		echo -e "${Verde} OK...${NoColor}"
		sleep 2

########## TIEMPO Y LOCALIZACION
	
		echo -e "\n\n${Amarillo} Cambiando zona horaria, lenguaje, localizacion y distribucion del teclado${NoColor}\n" 
		IDIOMA=$(curl https://ipapi.co/languages | awk -F "," '{print $1}' | sed 's/-/_/g' | sed "s|$|.UTF-8|")
		TIZO=$(curl https://ipapi.co/timezone)
		$CHROOT ln -sf /usr/share/zoneinfo/$TIZO /etc/localtime
		
		$CHROOT hwclock --systohc
		echo
		sed -i 's/#'"${IDIOMA}"'/'"${IDIOMA}"'/' /mnt/etc/locale.gen
		$CHROOT locale-gen
		echo "LANG=$IDIOMA" >> /mnt/etc/locale.conf
		echo "KEYMAP=la-latin1" >> /mnt/etc/vconsole.conf
		sleep 3
		echo -e "\n${Verde} OK...${NoColor}"
		sleep 2

########## RED

		echo -e "\n\n${Amarillo} Configurando la red${NoColor}"
		echo "${HNAME}" >> /mnt/etc/hostname
		cat >> /mnt/etc/hosts <<EOL		
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HNAME}.localdomain ${HNAME}
EOL
		echo -e "${Verde} OK...${NoColor}"
		sleep 2
    
########## USUARIOS Y CONTRASEÑAS
    
		echo -e "\n\n${Amarillo} Creando usuario y contraseñas${NoColor}\n"
		echo "root:$PASSWDR" | $CHROOT chpasswd
		$CHROOT useradd -m -g users -G wheel -s /usr/bin/zsh ${USR}
		echo "$USR:$PASSWD" | $CHROOT chpasswd
		sed -i 's/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/; /^root ALL=(ALL:ALL) ALL/a '"${USR}"' ALL=(ALL:ALL) ALL' /mnt/etc/sudoers
		echo "Defaults insults" >> /mnt/etc/sudoers
		echo -e " ${Azul}root${NoColor} : ${Rojo}$PASSWDR${NoColor}\n ${Amarillo}$USR${NoColor} : ${Rojo}$PASSWD${NoColor}"
		echo -e "${Verde} OK...${NoColor}"
		sleep 8
		clear
		
########## GRUB

		echo -e "\n\n\n${Amarillo} Instalando y configurando grub${NoColor}\n"
		$CHROOT grub-install --target=i386-pc /dev/$drive
		echo
		sed -i 's/quiet/noibrs noibpb nopti nospectre_v2 nospectre_v1 l1tf=off nospec_store_bypass_disable no_stf_barrier mds=off tsx=on tsx_async_abort=off mitigations=off nowatchdog/; s/#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER/' /mnt/etc/default/grub
		sed -i "s/MODULES=()/MODULES=(${gp})/" /mnt/etc/mkinitcpio.conf
		echo
		$CHROOT grub-mkconfig -o /boot/grub/grub.cfg
		echo -e "\n${Verde} OK...${NoColor}"
		sleep 2
		clear  
    
########## OPTIMIZACIONES

		echo -e "\n\n\n${Amarillo} Enchulando Pacman${NoColor}"
		sed -i 's/#Color/Color/; s/#ParallelDownloads = 5/ParallelDownloads = 10/; /^ParallelDownloads =/a ILoveCandy' /mnt/etc/pacman.conf
		echo -e "${Verde} OK...${NoColor}"
		sleep 2
    
		echo -e "\n\n${Amarillo} Optimizando el sistema de archivos ext4 para su uso con SSD${NoColor}"
		sed -i 's/relatime/noatime,commit=120,barrier=0/' /mnt/etc/fstab
		$CHROOT tune2fs -O fast_commit $partroot >/dev/null
		echo -e "${Verde} OK...${NoColor}"
		sleep 2
    
		echo -e "\n\n${Amarillo} Optimizando flags para compilar de manera optima segun tu sistema${NoColor}\n"
		echo -e " Tienes ${Azul}$(nproc)${NoColor} cores."
		sed -i 's/march=x86-64/march=native/; s/mtune=generic/mtune=native/; s/-O2/-O3/; s/#MAKEFLAGS="-j2/MAKEFLAGS="-j$(nproc)/' /mnt/etc/makepkg.conf
		echo -e "${Verde} OK...${NoColor}"
		sleep 2
    
		echo -e "\n\n${Amarillo} Configurando CPU modo Performance${NoColor}"
		sed -i "s/#governor='ondemand'/governor='performance'/" /mnt/etc/default/cpupower
		echo -e "${Verde} OK...${NoColor}"
		sleep 2
    
		echo -e "\n\n${Amarillo} Modificando el scheduler del kernel a mq-deadline optimo para los SSD${NoColor}"
		cat >> /mnt/etc/udev/rules.d/60-ssd.rules <<EOL
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
EOL
		echo -e "${Verde} OK...${NoColor}"
		sleep 2

		echo -e "\n\n${Amarillo} Modificando swappiness${NoColor}"
		cat >> /mnt/etc/sysctl.d/99-swappiness.conf <<EOL
vm.swappiness=1
vm.vfs_cache_pressure=50
EOL
		echo -e "${Verde} OK...${NoColor}"
		sleep 2

		echo -e "\n\n${Amarillo} Deshabilitando journal para reducir la escritura en el ssd${NoColor}"
		sed -i 's/#Storage=auto/Storage=none/' /mnt/etc/systemd/journald.conf
		echo -e "${Verde} OK...${NoColor}"
		sleep 2
    
		echo -e "\n\n${Amarillo} Deshabilitando modulos del kernel innecesarios${NoColor}"
		cat >> /mnt/etc/modprobe.d/blacklist.conf <<EOL
blacklist iTCO_wdt
blacklist mousedev
blacklist mac_hid
blacklist uvcvideo
EOL
		echo -e "${Verde} OK...${NoColor}"
		sleep 2
		
		echo -e "\n\n${Amarillo} Deshabilitando servicios innecesarios${NoColor}\n"
		$CHROOT systemctl mask lvm2-monitor.service systemd-random-seed.service
		echo -e "\n${Verde} OK...${NoColor}"
		sleep 2
		
		echo -e "\n\n${Amarillo} Optimizando velocidad de internet${NoColor}\n"
		echo -e " Cambiando a los DNS de ${Azul}Cloudflare${NoColor}"
		if $CHROOT pacman -Qi dhcpcd > /dev/null ; then
		echo "noarp" >> /mnt/etc/dhcpcd.conf
		echo "static domain_name_servers=1.1.1.1 1.0.0.1" >> /mnt/etc/dhcpcd.conf
		else
		echo "[global-dns-domain-*]" >> /mnt/etc/NetworkManager/conf.d/dns-servers.conf
		echo "servers=1.1.1.1,1.0.0.1" >> /mnt/etc/NetworkManager/conf.d/dns-servers.conf
		fi
		echo -e "${Verde} OK...${NoColor}"
		sleep 2
    
		if [ "${MPW}" == "Si" ]; then
		echo -e "\n\n${Amarillo} Montando almacemaniento personal a fstab${NoColor}\n"
		cat >> /mnt/etc/fstab <<EOL		
# My sTuFF
UUID=01D3AE59075CA1F0		/run/media/$USR/windows	ntfs-3g		auto,rw,users,hide_hid_files,noatime,umask=000 0 0
EOL
		cat /mnt/etc/fstab
		sleep 5
		echo -e "\n${Verde} OK...${NoColor}"
		sleep 2
		fi
    
########## MIRRORS CHROOT
    
		echo -e "\n\n${Amarillo} Escogiendo los mejores mirrors y sincronizando la base de datos${NoColor}\n"
		$CHROOT reflector --verbose --latest 5 --country 'United States' --age 6 --sort rate --save /etc/pacman.d/mirrorlist
		echo
		$CHROOT pacman -Syy
		echo -e "\n${Verde} OK...${NoColor}"
		sleep 2
		clear
    
########## INSTALANDO PAQUETES

		echo -e "\n\n\n${Amarillo} Instalando Xorg, Audio y driver grafico...${NoColor}\n"
		sleep 2
		$CHROOT pacman -S xorg-server xorg-xinput xorg-xsetroot $grafpack $audiopack --noconfirm
		clear
    
		echo -e "\n\n\n${Amarillo} Instalando codecs multimedia y paqueteria${NoColor}\n"
		sleep 2
		$CHROOT pacman -S ffmpeg ffmpegthumbnailer aom libde265 x265 x264 libmpeg2 xvidcore libtheora libvpx sdl jasper openjpeg2 libwebp unarchiver lha lrzip lzip p7zip lbzip2 arj lzop cpio unrar unzip zip unarj xdg-utils --noconfirm
		clear
    
		echo -e "\n\n\n${Amarillo} Instalando soporte para montar volumenes y dispositivos multimedia extraibles${NoColor}\n"
		sleep 2
		$CHROOT pacman -S libmtp gvfs-nfs dosfstools usbutils gvfs ntfs-3g gvfs-mtp net-tools xdg-user-dirs gtk-engine-murrine --noconfirm
		echo
		echo "xdg-user-dirs-update" | $CHROOT su $USR
		sleep 2
		clear
    
		echo -e "\n\n\n${Amarillo} Instalando las aplicaciones que yo uso...${NoColor}\n"
		sleep 2
		$CHROOT pacman -S android-file-transfer bleachbit cmatrix dunst gimp gcolor3 gparted htop lxappearance minidlna neovim thunar thunar-archive-plugin tumbler ranger simplescreenrecorder transmission-gtk ueberzug viewnior geany yt-dlp zathura zathura-pdf-poppler retroarch retroarch-assets-xmb retroarch-assets-ozone bspwm nitrogen pacman-contrib rofi sxhkd pass xclip firefox firefox-i18n-es-mx pavucontrol playerctl xarchiver numlockx polkit-gnome papirus-icon-theme ttf-joypixels terminus-font scrot grsync minidlna git --noconfirm
		clear
    
		#echo -e "\n\n\n${Amarillo} Instalando QEMU${NoColor}\n\n"
		#sleep 2
		#echo "sudo pacman -S qemu virt-manager dnsmasq bridge-utils ebtables --noconfirm" | arch-chroot /mnt /bin/bash -c "su '${USR}'"
		#clear
    
		if [ "$WIFI" = "y" ]; then
		echo -e "\n\n\n${Amarillo} Instalando herramientas WIFI${NoColor}\n"
		sleep 2
		$CHROOT pacman -S wpa_supplicant wireless_tools --noconfirm
		else
		echo -e "\n\n\nNo tienes tarjeta WiFi.. No se instala soporte..\n\n"
		fi
    
		echo -e "\n\n\n${Amarillo} Instalando LightDM${NoColor}\n"
		sleep 2
		$CHROOT pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings --noconfirm
		sed -i 's/#greeter-setup-script=/greeter-setup-script=\/usr\/bin\/numlockx on/' /mnt/etc/lightdm/lightdm.conf
		rm -f /mnt/etc/lightdm/lightdm-gtk-greeter.conf
		cat >> /mnt/etc/lightdm/lightdm-gtk-greeter.conf <<EOL
[greeter]
icon-theme-name = Qogir-ubuntu
background = /run/media/$USR/windows/Imagenes/Wallpapers/external-content.duckduckgo.com.jpg
user-background = false
default-user-image = /run/media/$USR/windows/Imagenes/Som3shiT/Dzndj8HUt7EcgEBD.png
indicators = ~host;~spacer;~clock;~spacer;~session;~power
position = 50%,center 80%,center
screensaver-timeout = 0
theme-name = Dracula
font-name = Terminus 10
EOL
		clear
		
		if [ "$DEXFCE" = "Si" ]; then
		echo -e "\n\n\n${Amarillo} Instalando Entorno XFCE${NoColor}\n"
		sleep 2
		$CHROOT pacman -S xfce4 --noconfirm
		clear
		fi
    
########## AUR

		if [ "${YAYH}" == "Si" ]; then
		echo -e "\n\n\n${Amarillo} Instalando yay y apps que yo uso${NoColor}\n\n"
		sleep 2
		echo "cd && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd && rm -rf yay" | $CHROOT su $USR
		clear

		# Utilidades para WM
		echo -e "\n\n\n${Amarillo} Instalando zramswap checkupdates-aur picom-jonaburg-git polybar termite xtitle${NoColor}\n\n"
		sleep 2
		echo "cd && yay -S zramswap checkupdates-aur picom-jonaburg-git polybar termite xtitle --noconfirm --removemake --cleanafter" | $CHROOT su $USR
		clear

		# Multimedia
		echo -e "\n\n\n${Amarillo} Instalando spotify spotify-adblock mpv popcorn-time${NoColor}\n\n"
		sleep 2
		echo "cd && yay -S spotify spotify-adblock-git mpv-git popcorntime-bin --noconfirm --removemake --cleanafter" | $CHROOT su $USR
		clear

		# Mensajeria
		echo -e "\n\n\n${Amarillo} Instalando whatsapp y telegram${NoColor}\n\n"
		sleep 2
		echo "cd && yay -S whatsapp-nativefier telegram-desktop-bin --noconfirm --removemake --cleanafter" | $CHROOT su $USR
		clear

		# Complementos
		echo -e "\n\n\n${Amarillo} Instalando iconos, fuentes y stacer${NoColor}\n\n"
		sleep 2
		echo "cd && yay -S stacer nerd-fonts-jetbrains-mono qogir-icon-theme --noconfirm --removemake --cleanafter" | $CHROOT su $USR
		clear
		fi
    
########## SERVICIOS

		echo -e "\n\n\n${Amarillo} Activando Servicios${NoColor}\n"
		$CHROOT systemctl enable ${esys} lightdm cpupower systemd-oomd.service systemd-timesyncd.service
		$CHROOT systemctl enable zramswap
		
		cat >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf <<EOL
Section "InputClass"
		Identifier	"system-keyboard"
		MatchIsKeyboard	"on"
		Option	"XkbLayout"	"latam"
EndSection
EOL

		sed -i 's/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /mnt/etc/sudoers
		echo -e "\n${Verde} OK...${NoColor}"
		sleep 2
		clear
    
########## DOTFILES

		if [ "${DOTS}" == "Si" ]; then
		echo -e "\n\n\n${Amarillo} Creando archivos especificos de mi configuracion X0RG${NoColor}\n\n"
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
		echo -e " Creado ${Verde}20-intel.conf${NoColor} en --> /etc/X11/xorg.conf.d\n\n"
		  
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
		echo -e " Creado ${Verde}10-monitor.conf${NoColor} en --> /etc/X11/xorg.conf.d\n\n"
		
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
		echo -e " Creado ${Verde}drirc${NoColor} en --> /etc\n\n"
		sleep 2
		clear

##########

		echo -e "\n\n\n${Amarillo} Reestableciendo mis dotfiles${NoColor}\n\n"
		mkdir /mnt/dots
		mount -U 6bca691d-82f3-4dd5-865b-994f99db54e1 -w /mnt/dots
		echo "rsync -vrtlpX /dots/dotfiles/ /home/$USR/" | $CHROOT su $USR
		$CHROOT mv /home/$USR/.themes/Dracula /usr/share/themes
		$CHROOT cp /dots/stuff/zfetch /usr/bin/
		echo -e "\n\n${Verde} OK...${NoColor}"
		sleep 5
		clear
		fi
    
##########

		echo -e "\n\n\n${Amarillo} Limpiando sistema para su primer arranque..${NoColor}\n"
		sleep 2
		rm -vrf /mnt/home/"$USR"/.cache/yay/
		rm -vrf /mnt/home/"$USR"/.cache/electron/
		rm -vrf /mnt/home/"$USR"/.cache/go-build/
		rm -vrf /mnt/home/"$USR"/.cargo/
		rm -vrf /mnt/usr/lib/firmware/{amd,amdgpu,amd-ucode,mellanox,mwlwifi,netronome,nvidia,radeon,rtlwifi}
		rm -vrf /mnt/usr/share/icons/{Qogir-manjaro,Qogir-manjaro-dark,Papirus-Light}
		rm -vf /mnt/usr/share/applications/{avahi-discover.desktop,bssh.desktop,bvnc.desktop,compton.desktop,picom.desktop,qv4l2.desktop,qvidcap.desktop,spotify.desktop,thunar-bulk-rename.desktop,thunar-settings.desktop,xfce4-about.desktop}
		rm -vf /mnt/opt/whatsapp-nativefier/locales/{am.pak,ar.pak,bg.pak,bn.pak,ca.pak,cs.pak,da.pak,de.pak,el.pak,en-GB.pak,et.pak,fa.pak,fi.pak,fil.pak,fr.pak,gu.pak,he.pak,hi.pak,hr.pak,hu.pak,id.pak,it.pak,ja.pak,kn.pak,ko.pak,lt.pak,lv.pak,ml.pak,mr.pak,ms.pak,nb.pak,nl.pak,pl.pak,pt-BR.pak,pt-PT.pak,ro.pak,ru.pak,sk.pak,sl.pak,sr.pak,sv.pak,sw.pak,ta.pak,te.pak,th.pak,tr.pak,uk.pak,vi.pak,zh-CN.pak,zh-TW.pak}
		rm -vf /mnt/usr/lib/firmware/{iwlwifi-100-5.ucode,iwlwifi-105-6.ucode,iwlwifi-135-6.ucode,iwlwifi-1000-3.ucode,iwlwifi-1000-5.ucode,iwlwifi-2000-6.ucode,iwlwifi-2030-6.ucode,iwlwifi-3160-7.ucode,iwlwifi-3160-8.ucode,iwlwifi-3160-9.ucode,iwlwifi-3160-10.ucode,iwlwifi-3160-12.ucode,iwlwifi-3160-13.ucode,iwlwifi-3160-16.ucode,iwlwifi-3160-17.ucode,iwlwifi-3168-21.ucode,iwlwifi-3168-22.ucode,iwlwifi-3168-27.ucode,iwlwifi-3168-29.ucode,iwlwifi-3945-2.ucode,iwlwifi-4965-2.ucode,iwlwifi-5000-1.ucode,iwlwifi-5000-2.ucode,iwlwifi-5000-5.ucode,iwlwifi-5150-2.ucode,iwlwifi-6000-4.ucode,iwlwifi-6000g2a-5.ucode,iwlwifi-6000g2a-6.ucode,iwlwifi-6000g2b-5.ucode,iwlwifi-6000g2b-6.ucode,iwlwifi-6050-4.ucode,iwlwifi-6050-5.ucode,iwlwifi-7260-7.ucode,iwlwifi-7260-8.ucode,iwlwifi-7260-9.ucode,iwlwifi-7260-10.ucode,iwlwifi-7260-12.ucode,iwlwifi-7260-13.ucode,iwlwifi-7260-16.ucode,iwlwifi-7260-17.ucode,iwlwifi-7265-8.ucode,iwlwifi-7265-9.ucode,iwlwifi-7265-10.ucode,iwlwifi-7265-12.ucode,iwlwifi-7265-13.ucode,iwlwifi-7265-16.ucode,iwlwifi-7265-17.ucode,iwlwifi-7265D-10.ucode,iwlwifi-7265D-12.ucode,iwlwifi-7265D-13.ucode,iwlwifi-7265D-16.ucode,iwlwifi-7265D-17.ucode,iwlwifi-7265D-21.ucode,iwlwifi-7265D-22.ucode,iwlwifi-7265D-27.ucode,iwlwifi-7265D-29.ucode,iwlwifi-8000C-13.ucode,iwlwifi-8000C-16.ucode,iwlwifi-8000C-21.ucode,iwlwifi-8000C-22.ucode,iwlwifi-8000C-27.ucode,iwlwifi-8000C-31.ucode,iwlwifi-8000C-34.ucode,iwlwifi-8000C-36.ucode,iwlwifi-8265-21.ucode,iwlwifi-8265-22.ucode,iwlwifi-8265-27.ucode,iwlwifi-8265-31.ucode,iwlwifi-8265-34.ucode,iwlwifi-8265-36.ucode,iwlwifi-9000-pu-b0-jf-b0-33.ucode,iwlwifi-9000-pu-b0-jf-b0-34.ucode,iwlwifi-9000-pu-b0-jf-b0-38.ucode,iwlwifi-9000-pu-b0-jf-b0-41.ucode,iwlwifi-9000-pu-b0-jf-b0-43.ucode,iwlwifi-9000-pu-b0-jf-b0-46.ucode,iwlwifi-9260-th-b0-jf-b0-33.ucode,iwlwifi-9260-th-b0-jf-b0-34.ucode,iwlwifi-9260-th-b0-jf-b0-38.ucode,iwlwifi-9260-th-b0-jf-b0-41.ucode,iwlwifi-9260-th-b0-jf-b0-43.ucode,iwlwifi-9260-th-b0-jf-b0-46.ucode,iwlwifi-cc-a0-46.ucode,iwlwifi-cc-a0-48.ucode,iwlwifi-cc-a0-50.ucode,iwlwifi-cc-a0-53.ucode,iwlwifi-cc-a0-55.ucode,iwlwifi-cc-a0-59.ucode,iwlwifi-cc-a0-62.ucode,iwlwifi-cc-a0-63.ucode,iwlwifi-Qu-b0-hr-b0-48.ucode,iwlwifi-Qu-b0-hr-b0-50.ucode,iwlwifi-Qu-b0-hr-b0-53.ucode,iwlwifi-Qu-b0-hr-b0-55.ucode,iwlwifi-Qu-b0-hr-b0-59.ucode,iwlwifi-Qu-b0-hr-b0-62.ucode,iwlwifi-Qu-b0-hr-b0-63.ucode,iwlwifi-Qu-b0-jf-b0-48.ucode,iwlwifi-Qu-b0-jf-b0-50.ucode,iwlwifi-Qu-b0-jf-b0-53.ucode,iwlwifi-Qu-b0-jf-b0-55.ucode,iwlwifi-Qu-b0-jf-b0-59.ucode,iwlwifi-Qu-b0-jf-b0-62.ucode,iwlwifi-Qu-b0-jf-b0-63.ucode,iwlwifi-Qu-c0-hr-b0-48.ucode,iwlwifi-Qu-c0-hr-b0-50.ucode,iwlwifi-Qu-c0-hr-b0-53.ucode,iwlwifi-Qu-c0-hr-b0-55.ucode,iwlwifi-Qu-c0-hr-b0-59.ucode,iwlwifi-Qu-c0-hr-b0-62.ucode,iwlwifi-Qu-c0-hr-b0-63.ucode,iwlwifi-Qu-c0-jf-b0-48.ucode,iwlwifi-Qu-c0-jf-b0-50.ucode,iwlwifi-Qu-c0-jf-b0-53.ucode,iwlwifi-Qu-c0-jf-b0-55.ucode,iwlwifi-Qu-c0-jf-b0-59.ucode,iwlwifi-Qu-c0-jf-b0-62.ucode,iwlwifi-Qu-c0-jf-b0-63.ucode,iwlwifi-QuZ-a0-hr-b0-48.ucode,iwlwifi-QuZ-a0-hr-b0-50.ucode,iwlwifi-QuZ-a0-hr-b0-53.ucode,iwlwifi-QuZ-a0-hr-b0-55.ucode,iwlwifi-QuZ-a0-hr-b0-59.ucode,iwlwifi-QuZ-a0-hr-b0-62.ucode,iwlwifi-QuZ-a0-hr-b0-63.ucode,iwlwifi-QuZ-a0-jf-b0-48.ucode,iwlwifi-QuZ-a0-jf-b0-50.ucode,iwlwifi-QuZ-a0-jf-b0-53.ucode,iwlwifi-QuZ-a0-jf-b0-55.ucode,iwlwifi-QuZ-a0-jf-b0-59.ucode,iwlwifi-QuZ-a0-jf-b0-62.ucode,iwlwifi-QuZ-a0-jf-b0-63.ucode,iwlwifi-so-a0-gf-a0.pnvm,iwlwifi-so-a0-gf-a0-64.ucode,iwlwifi-so-a0-hr-b0-64.ucode,iwlwifi-so-a0-jf-b0-64.ucode,iwlwifi-ty-a0-gf-a0.pnvm,iwlwifi-ty-a0-gf-a0-59.ucode,iwlwifi-ty-a0-gf-a0-62.ucode,iwlwifi-ty-a0-gf-a0-63.ucode,iwlwifi-ty-a0-gf-a0-66.ucode}

		echo
		$CHROOT pacman -Scc
		$CHROOT pacman -Rns go
		$CHROOT pacman -Rns $(pacman -Qtdq)
		$CHROOT fstrim -av
		echo -e "\n${Verde} OK...${NoColor}"
		sleep 2
		clear

#############################################
#                   Bye                     #
#############################################

		$CHROOT /usr/bin/zfetch
		echo -e "\n\n\n\n\n\n${Verde}  Ya quedo!!${NoColor}"
		sleep 10
