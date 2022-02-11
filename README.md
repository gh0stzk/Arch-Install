<h2 align="center">
  <br>
  <img src="imagenes/logo.svg" alt="Archlinux" width="320">
  <br>
Arch Linux Installer
</h2>

## Introduction

Este es mi script altamente personalizado para instalar [Arch Linux](https://www.archlinux.org/). adecuado a mis necesidades y hardware. <b>NOT BLOATED</b> Es una instalacion super ligera, pulida y totalmente funcional.

## Mi Setup:

- BIOS/MBR
- Grub
- ext4
- 2 unicas particiones "/" y "swap"
- DHCPCD
- Xorg-server
- BSPWM
- Polybar
- LightDM

## Features

*
*
*

## Optmizacion y Aumento del Rendimiento

* **Enchulando Pacman:**<br>
Se habilitan las descargas paralelas y se aumentan a 10. Se enchula pacman con el huevo de pascua **ILoveCandy**
* **Mitigations off:**<br>
Se agregan los parametros al kernel _noibrs noibpb nopti nospectre_v2 nospectre_v1 l1tf=off nospec_store_bypass_disable no_stf_barrier mds=off tsx=on tsx_async_abort=off mitigations=off nowatchdog_. Desactiva algunas mitigaciones de seguridad lo que lleva a una mejora del rendimiento. <br>https://transformingembedded.sigmatechnology.se/insight-post/make-linux-fast-again-for-mortals/
* **Mejorando rendimiento ext4:**<br>
Las opciones **noatime commit=120 barrier=0** se agregan al punto de montaje principal de la instalación. Y se activa el _fast_commit_ ( Desde el kernel 5.10 esta disponible este parche y reporta hasta un 103% de aumento en la velocidad de escritura ).<br>https://wiki.archlinux.org/title/Ext4#Improving_performance
* i

## Modo de uso

If using a French keyboard:

```sh
loadkeys fr
```

Check if system is under UEFI:

```sh
ls /sys/firmware/efi/efivars
```

Connect to wifi if needed

```sh
wifi-menu
```

Enable NTP and set timezone

```sh
timedatectl set-ntp true
timedatectl set-timezone Europe/Paris
```
