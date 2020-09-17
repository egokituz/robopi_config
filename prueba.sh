#!/bin/bash

# IMPORTANTE: Verificar que este script tiene permisos de ejecución
#             sudo chmod +x robopi_script.sh

echo "Script de configuración para robopi"

# Am i Root user?
if [ $(id -u) -eq 0 ]; then
	## Borrar usuarios "grupoXY" existentes

	users=$(grep -io "grupo[0-9]*" /etc/passwd | sort | uniq) # Obtener usuarios que coincidan con grupoXY
	
	for grupo in $users
	do
		echo "Borrando usuario $grupo ..."
		$(userdel -f -r $grupo)
		rm /home/$grupo
	done


	# Enable SSH
	sudo systemctl enable ssh
	sudo systemctl start ssh


	# Rename /etc/hostname


	# Rename /etc/hosts


	# Configure /etc/dhcpcd.conf


	# Configure /etc/wpa_supplicant/wpa_supplicant.conf



else
	echo "Only root may add a user to the system."
	exit 2
fi
