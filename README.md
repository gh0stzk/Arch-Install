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
