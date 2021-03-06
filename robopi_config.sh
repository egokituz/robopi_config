#!/bin/bash
#
# Configuration script for Raspberry Pi.
# Only to be used within the EHU course "Robótica, Sensores y Actuadores"
#
# To download and run this script, execute the following command in a terminal:
# bash -c "$(curl -fsS https://raw.githubusercontent.com/egokituz/robopi_config/master/robopi_config.sh)"
#
# Or if you already have it downloaded, execute it 
#
# Author: Xabier Gardeazabal
# email:  xabier.gardeazabal at ehu.eus
#
# Last updated on 2020/09/17
#
# Based on: https://ragingtiger.github.io/2018/06/19/rpi-init-setup


########################
# Function definitions #
########################

prompt(){
  # prompt user
  printf "\n\n\n"
  echo -n "$1"
}

fresh_restart(){
  sudo shutdown -r 1
}

get_response(){
  # get user input
  local response
  read response

  # determine action
  case $response in
    $2)
      # execute function

      $1
      ;;

    *)
      # do nothing
      :
      ;;
  esac

  # optional return
  if $3; then
    echo "$response"
  fi
}

setup_rpi_update(){
  # update
  sudo apt update
  sudo apt upgrade
}

setup_su_password(){
  sudo passwd
}

setup_delete_user_pi(){
  # execute only if not pi
  if [[ "$USER" != "pi" ]]; then
    sudo deluser pi && sudo rm -rf /home/pi
  else
    echo "Can't delete user 'pi' while being logged in.\
	      You must create a new user other than 'pi', \
          and login as that user and then rerun this script"
  fi
}

setup_delete_user_grupoXY(){
  # Obtener usuarios que coincidan con grupoXY
  local usuarios_grupoXY=$(grep -io "grupo[0-9]*" /etc/passwd | sort | uniq)

  for grupo in $usuarios_grupoXY
  do
    # execute only if current user is not grupoXY
    if [[ "$USER" != $grupo ]]; then
	  echo "Deleting user $grupo ..."
      sudo deluser $grupo && sudo rm -rf /home/$grupo
    else
      echo "Can't delete user $grupo while being logged in.\
            You must create a new user other than '$grupo', \
            and login as that user and then rerun this script"			
    fi
  done
}

setup_hostname(){
  # get new hostname
  prompt "Input new hostname for raspberry pi (eg: robopi01): "
  local new_hostname
  new_hostname=$(get_response '*' true)

  # update hostname file
  sudo sh -c "echo ${new_hostname} > /etc/hostname" && \

  # update hosts file
  sudo sed -i.bak "s/$(hostname)/${new_hostname}/g" /etc/hosts && \

  # give response
  printf "\n\n"
  echo "Host will now be addressable at: ${new_hostname}.local"
  printf "\n\n"

}

setup_network_files(){

  # get new static IP address
  prompt "Input new static IP address for this raspberry pi (eg: 192.168.1.101 for RoboPi01 with grupo01): "
  local ip_address
  ip_address=$(get_response '*' true)

  # create here doc and append to file
  sudo cat <<EOF | sudo tee /etc/dhcpcd.conf
# Configuracion generada automaticamente por https://github.com/egokituz/robopi_config/robopi_config.sh
# See dhcpcd.conf(5) for details.

#Inform the DHCP server of our hostname for DDNS
hostname

# Use the hardware address of the interface for the Client ID
clientid

# Persist interface configuration when dhcpcd exits.
persistent

# Rapid commit support. Safe to enable by default because it requires the equivalent option set on the server to actually work.
option rapid_commit

# A list of options to request from the DHCP server.
option domain_name_servers, domain_name, domain_search, host_name
option classless_static_routes
# Respect the network MTU. This is applied to DHCP routes.
option interface_mtu

# A ServerID is required by RFC2131.
require dhcp_server_identifier

# Generate Stable Private IPv6 Addresses based from the DUID
slaac private

interface eth0

# MODIFICAR 192.168.1.1XY/24
static ip_address=$ip_address/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1 8.8.8.8 4.4.4.4
inform $ip_address

interface wlan0

## MODIFICAR 192.168.1.1XY/24
static ip_address=$ip_address/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1 8.8.8.8 4.4.4.4
inform $ip_address
EOF

  sudo cat <<EOF | sudo tee /etc/network/interfaces
# Configuracion generada automaticamente por https://github.com/egokituz/robopi_config/robopi_config.sh

# interfaces(5) file used by ifup(8) and ifdown(8)

# Please note that this file is written to be used with dhcpcd
# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'

# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d
EOF
  
  sudo cat <<EOF | sudo tee /etc/wpa_supplicant/wpa_supplicant.conf
# Configuracion generada automaticamente por https://github.com/egokituz/robopi_config/robopi_config.sh

ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=ES

network={
ssid="LIPCNE"
psk="3G0kituz*"
key_mgmt=WPA-PSK
priority=1
}

network={
ssid="RaspberryPiLab"
psk="robopi2015"
key_mgmt=WPA-PSK
priority=2
}
EOF

}

setup_user(){
  # prompt/get response
  prompt "Input new username: "
  local username
  username=$(get_response '*' true)

  # next add new user
  sudo adduser $username

  # now add to sudo group
  sudo adduser $username sudo

  # reminder to logout and delete pi user
  echo "Remember to remove pi user as follows:"
  echo "# login with new USER"
  echo "$ ssh USER@raspberrypi.local"
  echo "raspberrypi:~ $ sudo deluser pi && sudo rm -rf /home/pi"
  printf "\n"
  echo "Or simply choose to 'Delete pi user' when prompted by config-rpi.sh"
}

setup_sshkey(){

  # prompt/get response
  prompt "Input username of account to setup sshkey for: "
  local username
  username=$(get_response '*' true)

  # path to .ssh dir
  local ssh_dir="/home/${username}/.ssh"

  # setup .ssh dir in $HOME
  sudo mkdir $ssh_dir

  # change ownership
  sudo chown ${username}:${username} $ssh_dir

  # now instruct user on how to copy keys
  echo "Execute on your local machine (assumes rpi is on local network):"
  echo "  $ scp ~/.ssh/id_rsa.pub ${username}@$(hostname).local:/home/${username}/.ssh/authorized_keys"
  echo ""


  # now confirm keys are copied, print next steps, and logout
  echo "After keys are copied, logout of pi user and execute the following: "
  echo "  $ ssh ${username}@$(hostname).local"
  echo ""
  exit
}

setup_ssh_enable(){
  sudo systemctl enable ssh
  sudo systemctl start ssh
  
  sudo cat <<EOF | sudo tee -a /etc/ssh/sshd_config
PermitRootLogin yes
EOF
}

setup_wiringpi(){
	sudo su<<EOF
cd /root
git clone https://github.com/WiringPi/WiringPi
./build
exit # exit super user session
EOF
}

main(){
  # update
  prompt "Would you like to update? (recommended) [Y/n]: "
  get_response setup_rpi_update 'Y' false
  
  # Change sudo password
  prompt "Would you like to set or change super user password? (recommended: toor) [Y/n]: "
  get_response setup_su_password 'Y' false

  # delete 'pi' user
  prompt "Would you like to delete 'pi' user (recommended)? [Y\n]: "
  get_response setup_delete_user_pi 'Y' false

  # delete old grupoXY users
  prompt "Would you like to delete old 'grupoXY' users? [Y\n]: "
  get_response setup_delete_user_grupoXY 'Y' false

  # get new user
  prompt "Would you like to setup a new RPi user? (eg: grupo01) [Y/n]: "
  get_response setup_user 'Y' false
  
  # setup network files
  prompt "Would you like to setup network files? \
  (/etc/dhcpcd.conf, /etc/network/interfaces, /etc/wpa_supplicant/wpa_supplicant.conf) [Y/n]: "
  get_response setup_network_files 'Y' false

  # set new hostname
  prompt "Would you like to setup a new hostname? (eg: robopi01) [Y/n]: "
  get_response setup_hostname 'Y' false

  # WiringPi
  prompt "Install WiringPi? [Y/n]: "
  get_response setup_wiringpi 'Y' false

  # enable ssh
  prompt "Would you like to enable SSH (also for root)? [Y/n]: "
  get_response setup_ssh_enable 'Y' false

  # setup sshkey
  prompt "Would you like to setup an SSH key now? [Y/n]: "
  get_response setup_sshkey 'Y' false
  
  # restart
  prompt "Restart RPi for changes to take effect (hostname, user)? [Y/n]: "
  get_response fresh_restart 'Y' false
}

################
# execute main #
################
main
