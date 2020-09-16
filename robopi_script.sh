#!/bin/bash

# IMPORTANTE: Verificar que este script tiene permisos de ejecución
#             sudo chmod +x robopi_script.sh

echo "Script de configuración para robopi"

# Am i Root user?
if [ $(id -u) -eq 0 ]; then
	# Borrar usuarios anteriores
	users=getent passwd | grep "grupo"
	for grupo in $users
	do
		echo $grupo
	done
	exit 0



	#read -p "Nombre del grupo (grupoXY) : " username
	#read -s -p "Enter password : " password
	#password=$username
	#egrep "^$username" /etc/passwd >/dev/null
	#if [ $? -eq 0 ]; then
	#	echo "$username exists!"
	#	exit 1
	#else
	#	pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
	#	useradd -m -p "$pass" "$username"
	#	[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
	#fi
else
	echo "Only root may add a user to the system."
	exit 2
fi
