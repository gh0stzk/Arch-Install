#!/usr/bin/env bash

clear
loadkeys la-latin1
#----------------------------------------
#          Setting some vars
#----------------------------------------

CRE=$(tput setaf 1)
CYE=$(tput setaf 3)
CGR=$(tput setaf 2)
CBL=$(tput setaf 4)
CBO=$(tput bold)
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

logo() {

    local text="${1:?}"
    printf ' %s%s[%s %s %s]%s\n\n' "$CBO" "$CRE" "$CYE" "${text}" "$CRE" "$CNC"
}

#----------------------------------------
#          Getting Information
#----------------------------------------
function get_necessary_info() {
    logo "Ingresa la informacion Necesaria"

    while true; do
        read -rp "Ingresa tu usuario: " USR
        if [[ "${USR}" =~ ^[a-z][_a-z0-9-]{0,30}$ ]]; then
            break
        else
            printf "\n%sIncorrecto!! Solo se permiten minúsculas.%s\n\n" "$CRE" "$CNC"
        fi
    done

    while true; do
        read -rsp "Ingresa tu password: " PASSWD
        echo
        read -rsp "Confirma tu password: " CONF_PASSWD

        if [ "$PASSWD" != "$CONF_PASSWD" ]; then
            printf "\n%sLas contraseñas no coinciden. Intenta nuevamente.!!%s\n\n" "$CRE" "$CNC"
        else
            printf "\n\n%sContraseña confirmada correctamente.\n\n%s" "$CGR" "$CNC"
            break
        fi
    done

    while true; do
        read -rsp "Ingresa tu password para ROOT: " PASSWDR
        echo
        read -rsp "Confirma tu password: " CONF_PASSWDR

        if [ "$PASSWDR" != "$CONF_PASSWDR" ]; then
            printf "\n%sLas contraseñas no coinciden. Intenta nuevamente.!!%s\n\n" "$CRE" "$CNC"
        else
            printf "\n\n%sContraseña confirmada correctamente.%s\n\n" "$CGR" "$CNC"
            break
        fi
    done

    while true; do
        read -rp "Ingresa el nombre de tu máquina: " HNAME

        if [[ "$HNAME" =~ ^[a-z][a-z0-9_.-]{0,62}[a-z0-9]$ ]]; then
            break
        else
            printf "%sIncorrecto!! El nombre no puede incluir mayúsculas ni símbolos especiales.%s\n\n" "$CRE" "$CNC"
        fi
    done
    clear
}

#---------- Select DISK ----------
function select_disk() {
    logo "Selecciona el disco para la instalacion"

    # Mostrar información de los discos disponibles
    echo "Discos disponibles:"
    lsblk -d -e 7,11 -o NAME,SIZE,TYPE,MODEL
    echo "------------------------------"
    echo

    # Seleccionar el disco para la instalación de Arch Linux
	PS3="Escoge el DISCO (NO la partición) donde Arch Linux se instalará: "
	select drive in $(lsblk -dnp -e 7,11 -o NAME | grep -E '/dev/(sd|hd|vd|nvme|mmcblk)'); do
		if [ -n "$drive" ] && [ -b "$drive" ]; then
			break
		fi
	done
    clear
}

#---------- Creando y Montando particion raiz ----------
function create_mount_root_partition() {
    logo "Creando Particiones"

    cfdisk "${drive}"
    clear

    logo "Formatenado y Montando Particiones"

    lsblk "${drive}" -I 8 -o NAME,SIZE,FSTYPE,PARTTYPENAME
    echo

    PS3="Escoge la particion raiz que acabas de crear donde Arch Linux se instalara: "
    select partroot in $(fdisk -l "${drive}" | grep Linux | awk '{print $1}')
    do
        if [ -n "${partroot}" ] && [ -b "${partroot}" ]; then
			echo "Formateando la partición RAIZ ${partroot}"
			echo "Espere..."
			if mkfs.ext4 -L Arch "${partroot}"; then
				if mount "${partroot}" /mnt; then
					echo "Partición ${partroot} formateada y montada exitosamente."
					break
				else
					echo "Error al montar la partición ${partroot}. Intente de nuevo."
				fi
			else
				echo "Error al formatear la partición ${partroot}. Intente de nuevo."
			fi
		else
        echo "Selección inválida. Por favor, elija una partición de la lista."
		fi
	done
    okie
    clear
}

#---------- Creando y Montando SWAP ----------
function create_mount_swap_partition() {
    logo "Configurando SWAP"

    PS3="Escoge la particion SWAP: "
    select swappart in $(fdisk -l | grep -E "swap" | cut -d" " -f1) "No quiero swap" "Crear archivo swap"
    do
        if [ "$swappart" = "Crear archivo swap" ]; then

            printf "\n Creando archivo swap..\n"
            sleep 2
            fallocate -l 4096M /mnt/swapfile
            chmod 600 /mnt/swapfile
            mkswap -L SWAP /mnt/swapfile >/dev/null
            printf " Montando Swap, espera..\n"
            swapon /mnt/swapfile
            sleep 2
            okie
            break

        elif [ "$swappart" = "No quiero swap" ]; then

            break

        elif [ "$swappart" ]; then

            echo
            printf " \nFormateando la particion swap, espera..\n"
            sleep 2
            mkswap -L SWAP "${swappart}" >/dev/null 2>&1
            printf " Montando Swap, espera..\n"
            swapon "${swappart}"
            sleep 2
            okie
            break
        fi
    done
    clear
}

#---------- Mostrar informacion de la instalacion ----------
function print_info() {
    printf "\n\n%s\n\n" "--------------------"
    printf " User:      %s%s%s\n" "${CBL}" "$USR" "${CNC}"
    printf " Hostname:  %s%s%s\n" "${CBL}" "$HNAME" "${CNC}"

    if [ "$swappart" = "Crear archivo swap" ]; then
        printf " Swap:      %sSi%s se crea archivo swap de 4G\n" "${CGR}" "${CNC}"
    elif [ "$swappart" = "No quiero swap" ]; then
        printf " Swap:      %sNo%s\n" "${CRE}" "${CNC}"
    elif [ "$swappart" ]; then
        printf " Swap:      %sSi%s en %s[%s%s%s%s%s]%s\n" "${CGR}" "${CNC}" "${CYE}" "${CNC}" "${CBL}" "${swappart}" "${CNC}" "${CYE}" "${CNC}"
    fi

    echo
    printf "\n Arch Linux se instalara en el disco %s[%s%s%s%s%s]%s en la particion %s[%s%s%s%s%s]%s\n\n\n" "${CYE}" "${CNC}" "${CRE}" "${drive}" "${CNC}" "${CYE}" "${CNC}" "${CYE}" "${CNC}" "${CBL}" "${partroot}" "${CNC}" "${CYE}" "${CNC}"

    while true; do
        read -rp " ¿Deseas continuar? [s/N]: " sn
        case $sn in
            [Ss]* ) break ;;
            [Nn]* ) exit ;;
            * ) printf " Error: solo necesitas escribir 's' o 'n'\n\n" ;;
        esac
    done
    clear
}

#---------- Pacstrap base system ----------
function base_install() {
    logo "Instalando sistema base"

    sed -i 's/#Color/Color/; s/#ParallelDownloads = 5/ParallelDownloads = 5/; /^ParallelDownloads =/a ILoveCandy' /etc/pacman.conf
    pacstrap /mnt \
        base base-devel \
        linux-zen linux-firmware-intel linux-firmware-realtek linux-firmware-whence \
        intel-ucode mkinitcpio \
        reflector zsh git networkmanager
    okie
    clear
}

#---------- Generating FSTAB ----------
function generating_fstab() {
    logo "Generando FSTAB"

    genfstab -U /mnt >> /mnt/etc/fstab
    okie
    clear
}

#---------- Timezone, Lang & Keyboard ----------
function set_timezone_lang_keyboard() {
    logo "Configurando Timezone y Locales"

    $CHROOT ln -sf /usr/share/zoneinfo/America/Mexico_City /etc/localtime
    $CHROOT hwclock --systohc
    echo
    echo "es_MX.UTF-8 UTF-8" >> /mnt/etc/locale.gen
    $CHROOT locale-gen
    echo "LANG=es_MX.UTF-8" >> /mnt/etc/locale.conf
    echo -e "KEYMAP=es\nFONT=Lat2-Terminus16\nXKBLAYOUT=es" >> /mnt/etc/vconsole.conf
    export LANG=es_MX.UTF-8
    okie
    clear
}

#---------- Hostname & Hosts ----------
function set_hostname_hosts() {
    logo "Configurando Internet"

    echo "${HNAME}" >> /mnt/etc/hostname
    cat >> /mnt/etc/hosts <<- EOL
		127.0.0.1   localhost
		::1         localhost
		127.0.1.1   ${HNAME}.localdomain ${HNAME}
	EOL
    okie
    clear
}

#---------- Users & Passwords ----------
function create_user_and_password() {
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
}

#---------- Refreshing Mirrors ----------
function refresh_mirrors() {
    logo "Refrescando mirros en la nueva Instalacion"

    $CHROOT reflector --verbose --latest 5 --country 'United States' --age 6 --sort rate --save /etc/pacman.d/mirrorlist >/dev/null 2>&1
    $CHROOT pacman -Syy
    okie
    clear
}

#---------- Install GRUB ----------
function install_grub() {
    logo "Instalando GRUB"

    $CHROOT pacman -S grub os-prober --noconfirm >/dev/null
    $CHROOT grub-install --target=i386-pc "$drive"

    sed -i 's/quiet/zswap.enabled=0 mitigations=off nowatchdog transparent_hugepage=madvise/; s/#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER/' /mnt/etc/default/grub
    sed -i "s/MODULES=()/MODULES=(intel_agp i915)/" /mnt/etc/mkinitcpio.conf
    echo
    $CHROOT grub-mkconfig -o /boot/grub/grub.cfg
    okie
    clear
}

#---------- Optimizations ----------
function opts_pacman() {
    logo "Aplicando optmizaciones.."
    titleopts "Editando pacman. Se activan descargas paralelas, el color y el easter egg ILoveCandy"
    sed -i 's/#Color/Color/; /^#DisableSandbox/a ILoveCandy' /mnt/etc/pacman.conf
    okie
}

function opts_ext4() {
    titleopts "Optimiza y acelera ext4 para SSD"
    sed -i '0,/relatime/s/relatime/noatime,commit=120/' /mnt/etc/fstab
    $CHROOT tune2fs -O fast_commit "${partroot}" >/dev/null
    okie
}

function opts_make_flags() {
    titleopts "Optimizando las make flags para acelerar tiempos de compilado"
    printf "\nTienes %s%s%s cores\n" "${CBL}" "$(nproc)" "${CNC}"
    sed -i 's/march=x86-64/march=native/; s/mtune=generic/mtune=native/; s/-O2/-O3/; s/#MAKEFLAGS="-j2/MAKEFLAGS="-j'"$(nproc)"'/' /mnt/etc/makepkg.conf
    #sed -i 's/COMPRESSZST=(zstd -c -T0 --ultra -20 -)/COMPRESSZST=(zstd -c -T0 --fast -9 -)/' /mnt/etc/makepkg.conf
    okie
}

function opts_cpupower() {
    titleopts "Configurando CPU a modo performance"
    $CHROOT pacman -S cpupower --noconfirm >/dev/null
    sed -i "s/#governor='ondemand'/governor='performance'/" /mnt/etc/default/cpupower
    okie
}

function opts_scheduler() {
    titleopts "Cambiando el scheduler del kernel a mq-deadline"
    cat >> /mnt/etc/udev/rules.d/60-ssd.rules <<- EOL
		ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
	EOL
    okie
}

function opts_swappiness() {
    titleopts "Modificando swappiness"
    cat >> /mnt/etc/sysctl.d/99-swappiness.conf <<- EOL
		vm.swappiness=20
        vm.vfs_cache_pressure=50
        vm.dirty_ratio=10
        vm.dirty_background_ratio=5
        vm.page-cluster=0
	EOL
    okie
}

function opts_journal() {
    titleopts "Deshabilitando Journal logs.."
    sed -i 's/#Storage=auto/Storage=none/' /mnt/etc/systemd/journald.conf
    okie
}

function opts_innec_kernel_modules() {
    titleopts "Desabilitando modulos del kernel innecesarios"
    cat >> /mnt/etc/modprobe.d/blacklist.conf <<- EOL
		blacklist iTCO_wdt
		blacklist mousedev
		blacklist mac_hid
		blacklist uvcvideo
	EOL
    okie
}

function opts_servicios_innecesarios() {
    titleopts "Deshabilitando servicios innecesarios"
    echo
    $CHROOT systemctl mask lvm2-monitor.service systemd-random-seed.service
    okie
}

function opts_my_stuff() {
    titleopts "Configurando almacenamiento personal"
    cat >> /mnt/etc/fstab <<-EOL
	# My sTuFF
    UUID=01D3AE59075CA1F0		/run/media/z0mbi3/windows 	ntfs3		rw,uid=1000,gid=984,umask=022,prealloc,windows_names,noatime	0 0
	EOL
    okie
    clear
}
#---------- Add my repo and chaotic-aur repos ----------
function add_repos() {
    titleopts "Adding gh0stzk repo"

	cat >> /mnt/etc/pacman.conf <<- EOL
		[gh0stzk-dotfiles]
		SigLevel = Optional TrustAll
        Server = http://gh0stzk.github.io/pkgs/x86_64
	EOL

	$CHROOT pacman -Syy
}

#---------- Installing Packages ----------
function install_video_sound() {
    logo "Instalando Audio & Video"
    mkdir /mnt/dots
    mount -U 6bca691d-82f3-4dd5-865b-994f99db54e1 -w /mnt/dots
    $CHROOT pacman -S \
        mesa-amber xorg-server xf86-video-intel \
        xorg-xinput xorg-xrdb xorg-xsetroot xorg-xwininfo xorg-xkill xorg-xdpyinfo \
        --noconfirm

    $CHROOT pacman -S pipewire pipewire-pulse --noconfirm
    clear
}

function install_codecs_utilities() {
    logo "Instalando codecs multimedia y utilidades"
    $CHROOT pacman -S \
        ffmpeg ffmpegthumbnailer aom libde265 x265 x264 libmpeg2 xvidcore libtheora libvpx sdl \
        jasper openjpeg2 libwebp webp-pixbuf-loader imagemagick \
        unarchiver lrzip lzip p7zip lbzip2 lzop cpio unrar unzip zip xdg-utils \
        --noconfirm
    clear
}

function install_mount_multimedia_support() {
    logo "Instalando soporte para montar volumenes y dispositivos multimedia extraibles"
    $CHROOT pacman -S \
        libmtp gvfs-nfs gvfs gvfs-mtp \
        dosfstools usbutils net-tools \
        xdg-user-dirs gtk-engines gtk-engine-murrine gnome-themes-extra \
        --noconfirm
    clear
}

function install_bspwm_enviroment() {
    logo "Instalando todo el entorno bspwm"
    $CHROOT pacman -S \
        sxhkd polybar picom rofi dunst clipcat \
        alacritty yazi maim eza bat feh lxsession-gtk3 \
        mpd ncmpcpp mpc pamixer playerctl pacman-contrib \
        thunar thunar-archive-plugin tumbler xarchiver jq \
        xdo xdotool jgmenu fd ripgrep redshift xcolor \
        zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting \
        --noconfirm
    clear
}

function install_apps_que_uso() {
    logo "Instalando apps que yo uso"
    $CHROOT pacman -S \
        bleachbit gimp gcolor3 geany mpv screenkey \
        htop viewnior zathura npm zathura-pdf-poppler \
        retroarch retroarch-assets-xmb retroarch-assets-ozone \
        pass xclip xsel neovim yt-dlp minidlna grsync \
        lxappearance pavucontrol piper firefox firefox-i18n-es-mx obsidian \
        papirus-icon-theme ttf-jetbrains-mono ttf-jetbrains-mono-nerd noto-fonts-emoji ttf-inconsolata ttf-ubuntu-mono-nerd ttf-terminus-nerd zram-generator \
        --noconfirm
    clear
}

function install_lightdm() {
    logo "Instalando LightDM"
    $CHROOT pacman -S \
        lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings numlockx \
        --noconfirm

    sed -i 's/#greeter-setup-script=/greeter-setup-script=\/usr\/bin\/numlockx on/' /mnt/etc/lightdm/lightdm.conf
    rm -f /mnt/etc/lightdm/lightdm-gtk-greeter.conf
    cat >> /mnt/etc/lightdm/lightdm-gtk-greeter.conf <<- EOL
		[greeter]
		icon-theme-name = Qogirr-Dark
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
}

function install_apps_gh0stzk() {
	$CHROOT pacman -S \
		st-gh0stzk gh0stzk-gtk-themes gh0stzk-cursor-qogirr gh0stzk-icons-beautyline \
        gh0stzk-icons-candy gh0stzk-icons-catppuccin-mocha gh0stzk-icons-dracula \
        gh0stzk-icons-glassy gh0stzk-icons-gruvbox-plus-dark gh0stzk-icons-hack \
        gh0stzk-icons-luv gh0stzk-icons-sweet-rainbow gh0stzk-icons-tokyo-night \
        gh0stzk-icons-vimix-white gh0stzk-icons-zafiro gh0stzk-icons-zafiro-purple
}

#---------- AUR Packages ----------
function aur_paru() {
    $CHROOT pacman -S rustup --noconfirm
    echo "rustup default stable" | $CHROOT su "$USR"
    echo "cd && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si --noconfirm && cd" | $CHROOT su "$USR"
}

function aur_apps() {
    echo "cd && paru -S xqp i3lock-color xwinwrap-0.9-bin fzf-tab-git --skipreview --noconfirm --removemake" | $CHROOT su "$USR"
    echo "cd && paru -S simple-mtpfs localsend-bin stacer-bin --skipreview --noconfirm --removemake" | $CHROOT su "$USR"
    echo "cd && paru -S spotify-1.1 spotify-adblock-git popcorntime --skipreview --noconfirm --removemake" | $CHROOT su "$USR"
    echo "cd && paru -S telegram-desktop-bin simplescreenrecorder --skipreview --noconfirm --removemake" | $CHROOT su "$USR"
}

#---------- Enable Services & other stuff ----------
function activando_servicios() {
    logo "Activando Servicios"

    $CHROOT systemctl enable NetworkManager.service cpupower systemd-timesyncd.service lightdm.service
    echo "systemctl --user enable mpd.service" | $CHROOT su "$USR"

    echo "xdg-user-dirs-update" | $CHROOT su "$USR"
    echo "timeout 1s firefox --headless --display=0" | $CHROOT su "$USR"
    #echo "export __GLX_VENDOR_LIBRARY_NAME=amber" >> /mnt/etc/profile
}

#---------- Generando archivos de configuracion ----------
function conf_xorg() {
    logo "Generating my XORG config files"
    cat >> /mnt/etc/X11/xorg.conf.d/20-intel.conf <<EOL
Section "Device"
	Identifier	"Intel Graphics"
	Driver		"Intel"
	Option		"AccelMethod"	"sna"
	Option		"DRI"		"3"
	Option		"TearFree"	"true"
	Option 		"TripleBuffer" "true"
EndSection
EOL
    printf "%s20-intel.conf%s generated in --> /etc/X11/xorg.conf.d\n" "${CGR}" "${CNC}"

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
}

function conf_monitor() {
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
}

function conf_keyboard() {
    cat >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf <<EOL
Section "InputClass"
		Identifier	"system-keyboard"
		MatchIsKeyboard	"on"
		Option	"XkbLayout"	"es"
EndSection
EOL
    printf "%s00-keyboard.conf%s generated in --> /etc/X11/xorg.conf.d\n" "${CGR}" "${CNC}"
}

function conf_zram() {
	cat > /mnt/etc/systemd/zram-generator.conf <<EOL
[zram0]
zram-size = ram / 2
compression-algorithm = lz4
swap-priority = 100
fs-type = swap
EOL
}
#---------- Restoring my dotfiles ----------

function restore_dotfiles() {
    logo "Restaurando mis dotfiles. Esto solo funciona es mi maquina z0mbi3-b0x"

    echo "rsync -vrtlpX /dots/dotfiles/ /home/$USR/" | $CHROOT su "$USR"

    $CHROOT mv /home/"$USR"/.themes/Dracula /usr/share/themes
    $CHROOT rm -rf /home/"$USR"/.themes
    $CHROOT cp /dots/stuff/{arch.png,gh0st.png} /usr/share/pixmaps/

    echo "cp -r /dots/stuff/z0mbi3-Fox-Theme/chrome /home/$USR/.mozilla/*.default-default/" | $CHROOT su "$USR"
    echo "cp /dots/stuff/z0mbi3-Fox-Theme/user.js /home/$USR/.mozilla/*.default-default/" | $CHROOT su "$USR"
	echo "sudo cp /dots/dotfiles/polybar-update.hook /etc/pacman.d/hooks/" | $CHROOT su "$USR"
    echo "systemctl --user enable ArchUpdates.timer" | $CHROOT su "$USR"
    okie
    sleep 5
    clear
}

#---------- Install Eww, Bspwm & Nitrogen ----------
function install_bspwm() {
    $CHROOT pacman -S libxcb xcb-util xcb-util-wm xcb-util-keysyms --noconfirm
    echo "cd && git clone https://github.com/baskerville/bspwm.git" | $CHROOT su "$USR"
    echo "cd && cd bspwm && make && sudo make install" | $CHROOT su "$USR"
    $CHROOT mkdir -p /usr/share/xsessions
    $CHROOT cp -r /usr/local/share/xsessions/bspwm.desktop /usr/share/xsessions/bspwm.desktop
}

function install_nitrogen() {
    $CHROOT pacman -S gtkmm --noconfirm
    echo "cd && git clone https://github.com/professorjamesmoriarty/nitrogen.git" | $CHROOT su "$USR"
    echo "cd && cd nitrogen && autoreconf -fi && ./configure && make && sudo make install" | $CHROOT su "$USR"
}

function install_eww() {
    echo "cd && git clone https://github.com/elkowar/eww" | $CHROOT su "$USR"
    echo "cd && cd eww && cargo build --release --no-default-features --features x11" | $CHROOT su "$USR"
    $CHROOT install -m 755 /home/"$USR"/eww/target/release/eww -t /usr/bin/
}

#---------- Reverting No Pasword Privileges ----------
function revert_privileges() {
    sed -i 's/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /mnt/etc/sudoers
}

#---------- Cleaning Garbage ----------
function clean_garbage() {
    logo "Limpiando sistema para su primer arranque"
    sleep 2
    rm -rf /mnt/home/"$USR"/.cache/paru/
    rm -rf /mnt/home/"$USR"/.cache/electron/
    rm -rf /mnt/home/"$USR"/.cache/go-build/
    rm -rf /mnt/home/"$USR"/{bspwm,nitrogen,eww,paru,.cargo,.rustup}
    rm -f /mnt/usr/share/applications/{avahi-discover.desktop,bssh.desktop,bvnc.desktop,compton.desktop,picom.desktop,qv4l2.desktop,qvidcap.desktop,spotify.desktop,thunar-bulk-rename.desktop,thunar-settings.desktop,xfce4-about.desktop,lstopo.desktop,rofi.desktop,rofi-theme-selector.desktop,electron32.desktop,jgmenu.desktop}
    rm -rf /mnt/usr/share/icons/{Qogir-manjaro,Qogir-manjaro-dark,Papirus-Light}

    $CHROOT pacman -Scc
    $CHROOT pacman -Rns go --noconfirm >/dev/null 2>&1
    $CHROOT pacman -Rns "$(pacman -Qtdq)" >/dev/null 2>&1
    $CHROOT fstrim -av >/dev/null
    okie
    clear
}

#---------- Bye ----------
function bye_bye() {
    echo -e "          .            "
    echo -e "         / \           I use Arch BTW.."
    echo -e "        /   \          ==========================="
    echo -e "       /^.   \         os       $(awk -F '"' '/PRETTY_NAME/ { print $2 }' /etc/os-release)"
    echo -e "      /  .-.  \        Kernel   $(arch-chroot /mnt uname -r)"
    echo -e "     /  (   ) _\       pkgs     $(arch-chroot /mnt pacman -Q | wc -l)"
    echo -e "    / _.~   ~._^\      ram      $(free --mega | sed -n -E '2s/^[^0-9]*([0-9]+) *([0-9]+).*/''\2 MB/p')"
    echo -e "   /.^         ^.\     Disk     $(arch-chroot /mnt df -h / | grep "/" | awk '{print $3}')"

    echo
    echo

    while true; do
        read -rp " Quieres reiniciar ahora? [s/N]: " sn
        case $sn in
            [Ss]* ) umount -a >/dev/null 2>&1;reboot ;;
            [Nn]* ) exit ;;
            * ) printf "Error: solo escribe 's' o 'n'\n\n" ;;
        esac
    done
}

###############################################
#####----------| Run Functions |----------#####
###############################################

get_necessary_info
select_disk
create_mount_root_partition
create_mount_swap_partition
print_info
base_install
generating_fstab
set_timezone_lang_keyboard
set_hostname_hosts
create_user_and_password
refresh_mirrors
install_grub

opts_pacman
opts_ext4
opts_make_flags
opts_cpupower
opts_scheduler
opts_swappiness
#opts_journal
opts_innec_kernel_modules
opts_servicios_innecesarios
opts_my_stuff

add_repos
install_video_sound
install_codecs_utilities
install_mount_multimedia_support
install_bspwm_enviroment
install_apps_que_uso
install_lightdm
install_apps_gh0stzk

aur_paru
aur_apps

activando_servicios

conf_xorg
conf_monitor
conf_keyboard
conf_zram

restore_dotfiles
install_bspwm
install_nitrogen
install_eww

revert_privileges
clean_garbage
bye_bye
