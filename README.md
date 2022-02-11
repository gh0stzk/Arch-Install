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

## Optmizacion y aumento del Rendimiento

* Mitigations off: Se agregan los parametros al kernel <b>noibrs noibpb nopti nospectre_v2 nospectre_v1 l1tf=off nospec_store_bypass_disable no_stf_barrier mds=off tsx=on tsx_async_abort=off mitigations=off nowatchdog</b>. Desactiva algunas mitigaciones de seguridad lo que lleva a una mejora del rendimiento. <br>https://transformingembedded.sigmatechnology.se/insight-post/make-linux-fast-again-for-mortals/
* y
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
