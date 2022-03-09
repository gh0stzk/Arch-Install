#!/bin/env bash
pepito="yes"
	if ping archlinux.org -W 3 -c 1 >/dev/null 2>&1; then
			echo -e " Espera....\n"
			sleep 3
			echo -e "${CGR} Si hay Internet!!${CNC}"
			sleep 2
			clear
		else
			echo " Error: Parace que no hay internet.."
				if [ $pepito = "yes" ]; then
					read -p " Quieres intentar con una red WiFi? [s/n] " qwifi
					if echo "$qwifi" | grep -iqF s; then
                device=$(ip link | grep "wl"* | grep -o -P "(?= ).*(?=:)" | sed -e "s/^[[:space:]]*//" | cut -d$'\n' -f 1)
                printf "\nUsando WiFi...\n"
                read -p " SSID: " ssid
                read -rsp " WiFi Password: " wifipass
                iwctl --passphrase "$wifipass" station "$device" connect "$ssid"
			else
                echo -e "${CGR} Saliendo..!!${CNC}"
                exit 0
					fi
				fi
				
			echo " Saliendo...."
			exit 0
	fi
		
echo "sigue el script"
