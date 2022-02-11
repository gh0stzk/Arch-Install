<h2 align="center">
  <br>
  <img src="imagenes/logo.svg" alt="Archlinux" width="320">
  <br>
Arch Linux Installer
</h2>

## Introduction

Este es mi script altamente personalizado para instalar [Arch Linux](https://www.archlinux.org/). adecuado a mis necesidades y hardware. This is not meant to be a universal guide, but only how I like to setup Arch Linux on my workstations. Since other people might find it useful, I decided to publish it.

Here is the setup I use:

- UEFI
- systemd-boot
- LVM on LUKS, plain `/boot`
- NetworkManager
- Xorg
- KDE / Plasma
- SDDM

## Inital setup

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
