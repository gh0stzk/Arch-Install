#!/bin/env bash
			
			
#----------------------------------------
#          Setting some vars
#----------------------------------------

clear
loadkeys la-latin1
setfont ter-v18n

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
    echo -e "${CGR}\n\n\n   Cargando...${CNC}"
    sleep 5
    clear

#----------------------------------------
#          Check Internet & BIOS
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
	
#---------
	
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
#          Testing Internet
#----------------------------------------

center "Probando conexion a internet"
	if ping archlinux.org -c 1 >/dev/null 2>&1; then
			echo -e " Espera....\n"
			sleep 3
			echo -e "${CGR} Si hay Internet!!${CNC}"
			sleep 2
			clear
		else
			echo " Error: Parace que no hay internet.."
			echo " Saliendo...."
		exit
	fi
	
#----------------------------------------
#          Creating Partitions
#----------------------------------------

center "Creando Formatenado y Montando Particiones"
	echo
	lsblk -I 8 -d -o NAME,SIZE,TYPE,MODEL
	echo "------------------------------"
	echo
	PS3="Escoge el DISCO (NO la particion) donde Arch Linux se instalara: "
select drive in $(lsblk -nd -e 7,11 -o NAME) 
	do
		if [ "$drive" ]; then
			break
		fi
	done
	
	cfdisk /dev/"${drive}"
	echo
	lsblk -I 8 -o NAME,SIZE,TYPE | grep "${drive}"
	echo
	
	while true
		do 
			read -rp "Escribe el NUMERO de la particion RAIZ /dev/${drive}/" partraiz
			if [[ "${partraiz}" =~ ^[0-9]$ ]]
			then 
				break
			fi 
			echo -e "Incorrecto, solo escribe el numero e.g. 1\n"
		done
		  
	mkfs.ext4 -L Arch /dev/"${drive}"${partraiz}
	mount /dev/"${drive}"${partraiz} /mnt
	partroot="$(findmnt -Dn -M /mnt -o SOURCE)"
	sleep 3
	echo

	echo " Creando archivo swap, espera.."
	sleep 2
	fallocate -l 512M /mnt/swapfile
	chmod 600 /mnt/swapfile
	mkswap /mnt/swapfile >/dev/null
	swapon /mnt/swapfile
	echo -e "${OK}"
	sleep 2
	clear
		
#----------------------------------------
#          Getting Information   
#----------------------------------------


center "Ingresa la informacion Necesaria"    	
	while true
		do 
			read -rp "Ingresa tu usuario: " USR
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
			read -rsp "Ingresa password para ROOT: " PASSWDR
			echo
			read -rsp "Confirma el password: " CONF_PASSWDR
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
			
		echo    
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
		
		echo
		PS3="Montar almacenamiento compartido con WINDOWS?: "
	select MPW in "Si" "No"
		do
			if [ $MPW ]; then
				break
			fi
		done
		
		 
	if [ "${MPW}" == "Si" ]; then
			echo
			echo
			lsblk -o +FSTYPE,LABEL | sed '/\(^├\|^└\)/!d'
			echo "------------------------------"
			echo
			PS3="Escoge la particion NTFS de tu almacenamiento en WINDOWS: "
		select ntfspart in $(lsblk -o +FSTYPE,LABEL | sed '/\(^├\|^└\)/!d' | cut -d " " -f 1 | cut -c7-) 
			do
				if [ "$ntfspart" ]; then
					break
				fi
			done
	fi
		
		
		
		     # Check CPU model
		if lscpu | grep -q 'GenuineIntel'; then
			cpu_name="Intel"
			cpu_model="intel-ucode"
			cpu_atkm="intel_agp i915"
	else
			cpu_name="AMD"
			cpu_model="amd-ucode"
			cpu_atkm="amdgpu"
		fi
		
clear
	
		echo
		echo -e "\n --------------------"
		echo
		
		echo -e " User:      ${CBL}$USR${CNC}"
		echo -e " Hostname:  ${CBL}$HNAME${CNC}"
		echo -e " CPU:       ${CBL}$cpu_name${CNC}"
		echo -e " Kernel:    ${CBL}$kernel${CNC}"
    
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
		
		if [ "${MPW}" = "Si" ]; then
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

center "Instalando sistema base"
	sed -i 's/#Color/Color/; s/#ParallelDownloads = 5/ParallelDownloads = 5/; /^ParallelDownloads =/a ILoveCandy' /etc/pacman.conf
	reflector --verbose --latest 5 --country 'United States' --age 6 --sort rate --save /etc/pacman.d/mirrorlist >/dev/null 2>&1
	pacstrap /mnt \
	         base \
	         base-devel \
	         "$kernel" \
	         linux-firmware \
	         dhcpcd \
	         "$cpu_model" \
	         reflector \
	         zsh
	echo -e "${OK}"
	sleep 2
clear

#----------------------------------------
#          Generating FSTAB
#----------------------------------------
    
center "Generando FSTAB"
	genfstab -U /mnt >> /mnt/etc/fstab
	echo -e "${OK}"
	sleep 2
clear

#----------------------------------------
#          Timezone, Lang & Keyboard
#----------------------------------------
	
center "Configurando Timezone y Locales"
	$CHROOT ln -sf /usr/share/zoneinfo/America/Mexico_City /etc/localtime
	$CHROOT hwclock --systohc
	echo
	sed -i 's/#es_MX.UTF-8/es_MX.UTF-8/' /mnt/etc/locale.gen
	$CHROOT locale-gen
	echo "LANG=es_MX.UTF-8" >> /mnt/etc/locale.conf
	echo "KEYMAP=la-latin1" >> /mnt/etc/vconsole.conf
	export LANG=es_MX.UTF-8
	echo -e "${OK}"
	sleep 2
clear

#----------------------------------------
#          Hostname & Hosts
#----------------------------------------

center "Configurando Internet"
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
    
center "Usuario Y Passwords"
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
#          Refreshing Mirrors
#----------------------------------------

center "Refrescando mirros en la nueva Instalacion"
	$CHROOT reflector --verbose --latest 5 --country 'United States' --age 6 --sort rate --save /etc/pacman.d/mirrorlist
	$CHROOT pacman -Syy
	echo -e "${OK}"
	sleep 2
clear

#----------------------------------------
#          Install GRUB
#----------------------------------------

center "Instalando GRUB"
	$CHROOT pacman -S grub os-prober ntfs-3g --noconfirm >/dev/null
	$CHROOT grub-install --target=i386-pc /dev/"$drive"
	echo
	sed -i 's/quiet/zswap.enabled=0 mitigations=off nowatchdog/; s/#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER/' /mnt/etc/default/grub
	sed -i "s/MODULES=()/MODULES=(${cpu_atkm})/" /mnt/etc/mkinitcpio.conf
	echo
	$CHROOT grub-mkconfig -o /boot/grub/grub.cfg
	echo -e "${OK}"
	sleep 2
clear  

#----------------------------------------
#          Optimizations
#----------------------------------------

center "Aplicando optmizaciones.."

	echo -e "${CYE}Enchulando pacman${CNC}"
	sed -i 's/#Color/Color/; s/#ParallelDownloads = 5/ParallelDownloads = 5/; /^ParallelDownloads =/a ILoveCandy' /mnt/etc/pacman.conf
	echo -e "${OK}"
	sleep 2
    
	echo -e "\n${CYE}Tunning ext4 file system for SSD and SpeedUp${CNC}"
	sed -i 's/relatime/noatime,commit=120/' /mnt/etc/fstab
	$CHROOT tune2fs -O fast_commit "$partroot" >/dev/null
	echo -e "${OK}"
	sleep 2
    
	echo -e "\n${CYE}Optimizing make flags for speedup compiling times${CNC}\n"
	echo -e "You have ${CBL}$(nproc)${CNC} cores."
	sed -i 's/march=x86-64/march=native/; s/mtune=generic/mtune=native/; s/-O2/-O3/; s/#MAKEFLAGS="-j2/MAKEFLAGS="-j'"$(nproc)"'/' /mnt/etc/makepkg.conf
	echo -e "${OK}"
	sleep 2
    
	echo -e "\n${CYE}Configuring CPU to performance mode${CNC}"
	$CHROOT pacman -S cpupower --noconfirm >/dev/null
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
vm.swappiness=100
vm.vfs_cache_pressure=80
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
	echo "noarp" >> /mnt/etc/dhcpcd.conf
	echo "static domain_name_servers=1.1.1.1 1.0.0.1" >> /mnt/etc/dhcpcd.conf
	echo -e "${OK}"
	sleep 2
    
    
    
	if [ "${MPW}" == "Si" ]; then
	echo -e "\n${CYE}Mounting my personal storage${CNC}\n"
	ntfsuuid=$(blkid -o value -s UUID /dev/${ntfspart}) 
	cat >> /mnt/etc/fstab <<EOL		
# My sTuFF
UUID=${ntfsuuid}		/run/media/$USR/windows	ntfs-3g		auto,rw,uid=1000,gid=984,hide_hid_files,windows_names,big_writes,noatime,dmask=022,fmask=133 0 0
EOL
	cat /mnt/etc/fstab
	sleep 5
	echo -e "${OK}"
	sleep 2
	fi
	
clear

#----------------------------------------
#          Installing Packages
#----------------------------------------

center "Installing Audio & Video"
	sleep 2	
	$CHROOT pacman -S xorg-server mesa xf86-video-intel xorg-xinput xorg-xsetroot pipewire pipewire-pulse --noconfirm
	clear
	
center "Installing Multimedia Codecs And Archiver Utilities"
	$CHROOT pacman -S ffmpeg ffmpegthumbnailer aom libde265 x265 x264 libmpeg2 xvidcore libtheora libvpx sdl jasper openjpeg2 libwebp webp-pixbuf-loader unarchiver lha lrzip lzip p7zip lbzip2 arj lzop cpio unrar unzip zip unarj xdg-utils --noconfirm
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

		if [ "${YAYH}" == "Si" ]; then
		
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

center "Actizando Servicios"
	$CHROOT systemctl enable dhcpcd.service lightdm cpupower systemd-timesyncd.service
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

	if [ "${DOTS}" == "Si" ]; then
	
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

center "Restaurando mis dotfiles"
	mkdir /mnt/dots
	mount -U 6bca691d-82f3-4dd5-865b-994f99db54e1 -w /mnt/dots
	echo "rsync -vrtlpX /dots/dotfiles/ /home/$USR/" | $CHROOT su "$USR"
	$CHROOT mv /home/"$USR"/.themes/Dracula /usr/share/themes
	$CHROOT rm -rf /home/"$USR"/.themes
	$CHROOT cp /dots/stuff/zfetch /usr/bin/
	$CHROOT cp /dots/stuff/{arch.png,gh0st.png} /usr/share/pixmaps/
	echo -e "${OK}"
	sleep 5
clear
	fi

#----------------------------------------
#          Cleaning Garbage
#----------------------------------------

center "Limpiando sistema para su primer arranque"
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

center "Instalacion Finalizada"

echo -e "                       "
echo -e "         / \           I use Arch Linux BTW.."
echo -e "        /   \          ==========================="     
echo -e "       /^.   \         os       $(source /mnt/etc/os-release && echo "${PRETTY_NAME}")"    
echo -e "      /  .-.  \        Kernel   $(uname -r)"   
echo -e "     /  (   ) _\       pkgs     $(arch-chroot /mnt pacman -Q | wc -l)"
echo -e "    / _.~   ~._^\      ram      $(free --mega | sed -n -E '2s/^[^0-9]*([0-9]+) *([0-9]+).*/'"${space}"'\2 MB/p')"
echo -e "   /.^         ^.\     Disk     $(df -h / | grep "/" | awk '{print $3}')"
		
		echo
		echo
while true; do
		read -rp "Quieres reiniciar ahora? [s/N]: " sn
		case $sn in
			[Ss]* ) reboot;;
			[Nn]* ) exit;;
			* ) echo "Error: solo escribe 's' o 'n'";;
		esac
	done
