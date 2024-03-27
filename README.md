<h2 align="center">
  <br>
  <img src="imagenes/logo.svg" alt="Archlinux" width="320">
  <br>
Arch Linux Installer
</h2>

## Introduction
### Please dont install this, i did it for old machine i had, this isnt updated.

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

* **Mejorando rendimiento ext4:**<br>
Las opciones **noatime commit=120 barrier=0** se agregan al punto de montaje principal de la instalación. Y se activa el _fast_commit_ ( Desde el kernel 5.10 esta disponible este parche y reporta hasta un 103% de aumento en la velocidad de escritura ).<br>https://wiki.archlinux.org/title/Ext4#Improving_performance

* **Optimizando MAKEFLAGS:**<br>
Se modifican algunos valores en el archivo makepkg.conf para optimizar los binarios. Y se usaran todos tus cores para mejorar los tiempos de compilacion.<br>https://wiki.archlinux.org/title/makepkg#Building_optimized_binaries

* **CPUPOWER:**<br>
Se usa cpupower para configurar como trabajara el CPU y se cambia el valor del governor "ondemand" a "performance" para asegurarnos qué siempre trabaje de manera óptima y rapida.<br>https://wiki.archlinux.org/title/CPU_frequency_scaling#cpupower

* **Optmizando el uso en los SSD:**<br>
Se usa por defecto mq-deadline scheduler no por ser más rápido,  si no por que es el mejor optimizado para los SSD<br>https://wiki.archlinux.org/title/Improving_performance#Changing_I/O_scheduler

* **Uso del swappiness:**<br>
En equipos con suficiente memoria ram, un valor bajo mejora la respuesta del sistema. Swappiness representa la preferencia del kernel para usar el espacio de intercambio swap, es decir, un valor alto hace que el kernel trate de usar con mucha frecuencia este espacio, y muchas veces puede no se lo optimo. Lo optimo seria usar la memoria ram en vez del espacio de intercambio swap. _El parametro de swappiness se redujo a 10._<br>https://wiki.archlinux.org/title/swap#Swappiness

* **Modulos del kernel:**<br>
Se ponen en la lista negra los siguientes modulos. Edita el archivo _/etc/modprobe.d/blacklist.conf_ si tu si necesitas alguno de ellos. Solo eliminalo de la lista.
  - iTCO_wdt: deshabilita watchdog.
  - mousedev: Las computadoras modernas ya ni traen puerto PS2 para el mouse.
  - mac_hid: No tengo productos de apple, entonces pues a la lista negra.
  - uvcvideo: Deshabilita la webcam, tienes una laptop o una webcam deberias quitar este.<br>
https://www.linkedin.com/pulse/how-make-your-archlinux-faster-sourav-goswami?articleId=6705965618413273088

* **Servicios innecesarios:**<br>
Se deshabilitan 2 servicios, "_lvm2-monitor.service y systemd-random-seed.service_" por que son inncesarios en mi sistema. Recuerda que este es un script basado en mis necesidades, pero posiblemente tu tampoco los necesites.<br>Puedes ver que servicios se activan de inicio con este comando.
```sh
systemd-analyze blame
```
* **Velocidad de internet:**<br>
Este script de instalacion te da la opcion de instalar dhcpcd o networkmanager, uno u otro, no son necesarios los dos, pero sea cual sea el que escogas, se agregaron opciones a cada uno de ellos para que uses las **DNS de Cloudfire** que son mas rapidas y seguras que las de google o las de tu proveedor de internet.<br>https://wiki.archlinux.org/title/Dhcpcd#/etc/resolv.conf <br>https://wiki.archlinux.org/title/NetworkManager#Custom_DNS_servers

* **Mitigations off:**<br>
Se agregan los parametros al kernel _noibrs noibpb nopti nospectre_v2 nospectre_v1 l1tf=off nospec_store_bypass_disable no_stf_barrier mds=off tsx=on tsx_async_abort=off mitigations=off nowatchdog_. Desactiva algunas mitigaciones de seguridad lo que lleva a una mejora del rendimiento. <br>https://transformingembedded.sigmatechnology.se/insight-post/make-linux-fast-again-for-mortals/


## Modo de uso

Descarga y ejectuta el script:

```sh
curl -LO https://is.gd/arch_gh0st
sh arch_gh0st
```
