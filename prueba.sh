#!/bin/bash

# IMPORTANTE: Verificar que este script tiene permisos de ejecución
#             sudo chmod +x robopi_script.sh

echo "Script de configuración para robopi"

# Am i Root user?
if [ $(id -u) -eq 0 ]; then
	## Borrar usuarios anteriores

	users=$(grep -io "grupo[0-9]*" /etc/passwd | sort | uniq) # Obtener la lista de usuarios que coincidan con grupoXY"
	
	for grupo in $users
	do
		echo "Usuario $grupo"
		$(userdel -f -r $grupo)
		rm /home/$grupo
	done
else
	echo "Only root may add a user to the system."
	exit 2
fi
