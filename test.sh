#!/bin/env bash


if [[ $(ping -W 3 -c 2 archlinux.org) != *" 0%"* ]]; then

		echo -e "\n Espera...\n"
		sleep 2
		echo -e "\n Error: Parace que no hay internet..\n"
		
			if [ "$(lspci -d ::280)" ]; then
			
				read -p "Intentar con WiFi? [s/N] " qwifi
				
					if echo "$qwifi" | grep -iqF s; then
						device=$(ip link | grep "wl"* | grep -o -P "(?= ).*(?=:)" | sed -e "s/^[[:space:]]*//" | cut -d$'\n' -f 1)
						read -p "SSID: " ssid
						read -rsp "WiFi Password: " wifipass
						iwctl --passphrase "$wifipass" station "$device" connect "$ssid"
						sleep 3
					fi
			fi
		else
			echo "Si hay internet"
fi

if [[ $(ping -W 3 -c 2 archlinux.org) != *" 0%"* ]]; then

        echo -en "		
        
        - No se ha podido establecer conexion, intenta conectarte via ethernet.
        - Si ingresaste mal los datos de tu wifi, vuelver a cargar el script e intenta de nuevo.
        
        Saliendo del script..."
        exit 0
fi
		
echo "sigue el script"
