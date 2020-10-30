# Configuración de RaspberryPis para RSA (script)

Este repositorio contiene un script de configuración (`robopi_config.sh`) para las RaspberryPi de la asignatura Robótica Sensores y Actuadores de la UPV/EHU. Para utilizarlo directamente en una RaspberryPi, desde la línea de comandos de la RaspberryPi (con conexión a Internet), ejecutar el siguiente comando:

```
bash -c "$(curl -fsS https://raw.githubusercontent.com/egokituz/robopi_config/master/robopi_config.sh)"
```

Se nos presentará un menú interactivo que nos preguntará sucesivamente qué configuraciones deseamos realizar.

# Configuración de RaspberryPi para RSA (manualmente)

El script de configuración anterior automatiza y facilita la configuración de nuestra RaspberryPi. Si queremos hacer la configuración manualmente (y prescindir del script), tendremos que realizar las configuraciones que se detallan a continuación:


### Configuración de red

Es imprescindible configurar los parámetros de red para evitar colisiones de IP con otras RaspberryPis durante las prácticas de laboratorio de RSA. Para ello, asignaremos una IP estática en la subred 192.168.1.XXX de la red WLAN del laboratorio (`RaspberryPiLab`). Además, asignaremos un *hostname* a nuestra RaspberryPi (acorde a nuestro identificador de grupo, tipo grupoXY).

IMPORTANTE:

	- NO enchufar la alimentación todavía
	- Enchufar el conector de pantalla HDMI y teclado +mouse por USB
	- Enchufar el dongle USB-WIFI 
	- Enchufar el cable de alimentación

OBSERVACIONES:

	- Log-in con el usuario root:toor (user:password) o utilizar sudo al editar los ficheros
	- Copiar y pegar el contenido de los siguientes ficheros, y **modificar las variables XY donde corresponda**:

Fichero `/etc/dhcpcd.conf` (para asignarnos una IP estática). **IMPORTANTE: Modificar XY con nuestro número de grupo**:	

```
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
static ip_address=192.168.1.1XY/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1 8.8.8.8 4.4.4.4
# MODIFICAR 192.168.1.1XY
inform 192.168.1.1XY

interface wlan0
# MODIFICAR 192.168.1.1XY/24
static ip_address=192.168.1.XY/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1 8.8.8.8 4.4.4.4
# MODIFICAR 192.168.1.1XY
inform 192.168.1.1XX
```		

Fichero `/etc/network/interfaces`:

```
# interfaces(5) file used by ifup(8) and ifdown(8)
# Please note that this file is written to be used with dhcpcd
# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'
# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d
```

Fichero `/etc/hostname`:

```
robopiXY
```

Fichero `/etc/hosts`:

```
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff00::0         ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

127.0.1.1       robopiXY
```

Fichero `/etc/wpa_supplicant/wpa_supplicant.conf` (contraseñas WLAN):	

```
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
```

### Configuración de usuarios

Por motivos de seguridad, es muy recomendable cambiar la contraseña por defecto del usuario **pi**. 

Aunque no sea necesario crear un usuario acorde a nuestro grupo, es recomendable hacerlo. 

Desde el usuario root, borramos los usuarios "grupoXY" antiguos ejecutando `sudo userdel grupoXY`, y creamos el nuevo usuario "grupoXY" que corresponda con `sudo adduser grupoXY` (y estableceremos la contraseña: `grupoXY`).

Finalmente, añadiremos o editaremos la siguiente línea del fichero `/etc/sudoers`:

```
...
grupoXY ALL=(ALL) NOPASSWD: ALL
...
```

### Configuración SSH remoto

Para conectarnos mediante SSH a nuestra RaspberryPi, es necesario habilitarlo. Para hacerlo, seguiremos las instrucciones en [https://www.raspberrypi.org/documentation/remote-access/ssh/](https://www.raspberrypi.org/documentation/remote-access/ssh/). Alternativamente, podemos ejecutar los siguientes comandos:

```
sudo systemctl enable ssh
sudo systemctl start ssh
```

# Apéndices

## Configuración Router WiFi "RaspberryPiLab":

Dirección del ruter o router Linksys con SSID RaspberryPiLab:

- Setup IP address: 192.168.1.1
- Root/admin password: admin
	
A veces, si el WiFi del laboratorio de EGOKITUZ está dentro del alcance, las Rpis pueden haberse conectado a la red del router LIPCNE, en lugar del Router RaspberryPiLab.
Para obtener el SSID de la red LAN/WiFi a la que estamos conectados, ejecutar el comando `iwgetid `.
	
Mediante el fichero de configuración /etc/wpa_supplicant/wpa_supplicant.conf podemos establecer la prioridad de cada red WiFi:

 priority=1 	bajo<br>
 priority=2 	alto, elegirá esta red antes, si está disponible<br>
 (más alto = más prioridad)

Comando para ver los dispositivos conectados en la misma red LAN (es lento y tarda un rato):

```
nmap -sn 192.168.1.0/24
```

## Configuración Headless (sin pantalla)

Si no disponemos de pantalla para conectar a la Raspberry Pi, o si preferimos conectarnos mediante SSH, podemos realizar lo que se conoce como "Headless Setup":

	1- Introducir la tarjeta microSD en el PC
	2- Crear un fichero vacío llamado "ssh" (sin extensión de archivo) en el directorio principal de la tarjeta SD
	3- En la carpeta `/boot/` pegar el contenido del fichero wpa_supplicant.conf (descargable en el github de Egokituz)

## Instalar RaspberryPi OS en una microSD

Material necesario:
* Tarjeta microSD compatible con RaspberryPi (recomendable mínimo 7GB)
* Adaptador para leer tarjetas microSD en nuestro PC.

La forma mas fácil de instalar el sistema operativo Raspberry Pi OS (antes llamado *raspbian*) es mediante el software *RaspberryPi Imager* (https://www.raspberrypi.org/downloads/), disponible en Windows, Ubuntu y macOS. Para instalar un sistema operativo alternativo en una tarjeta microSD, seguir [estas instrucciones](https://www.raspberrypi.org/documentation/installation/installing-images/README.md).

Las instrucciones de instalación y uso del programa *RaspberryPi Imager* están en [https://projects.raspberrypi.org/en/projects/raspberry-pi-setting-up/2](https://projects.raspberrypi.org/en/projects/raspberry-pi-setting-up/2)

Una vez terminada la instalación del sistema operativo en la microSD, tendremos que configurarla para su uso en la asignatura RSA. 

## Formatear una SD por completo:

Para formatear y resetear una SD por completo desde windows, nos toparemos con el problema de que Windows no es capaz de leer todas las particiones de la SD que Raspbian ha creado. Ni siquiera seremos capaces de formatear y unir las particiones desde el Administrador de Equipos de windows. En su lugar, usaremos la herramienta DiskPart, desde la linea de comandos (cmd):

```
diskpart	
list disk	nos fijamos en el número de disco que nos interesa
select disk X	X = el número de disco según el comando list disk
clean	
create partition primary	
format quick	
```

Mas información para la configuración de red:

https://raspberrypi.stackexchange.com/questions/37920/how-do-i-set-up-networking-wifi-static-ip-address/37921#37921


## Manual para clonar tarjetas microSD:

Resumen de los pasos:

	1. Preparar el sistema operativo de la tarjeta microSD que queremos clonar
		a. Borrar ficheros personales y basura
		b. Actualizar sistema operativo y programas
	2. Volcar imagen de disco de la microSD al PC
	3. Clonar imagen desde el PC a la microSD

### Paso 1: Limpiar y actualizar la tarjeta microSD que vamos a clonar:
Actualizar programas:

```
	$ sudo apt update 
	$ sudo apt upgrade
```

Borrar los ficheros y directorios creados por alumnos anteriores:

```
	/home/grupoXY/.netbeans/
	/root/.netbeans/
	etc
```

### Paso 2: Volcar imagen de disco de la microSD al PC

Antes de seguir, asegurarse de tener instalado ***Win32 Disk Imager*** (software para crear imagenes de disco en MS Windows).

	1- introducir la SD en el ordenador antes de ejecutar el programa
	2- Seleccionar dispositivo (device) del drop-down-list
		a. Si no aparece en el dropdownlist, asegurarse de que windows reconoce la SD
		b. Si windows reconoce la SD, cerrar y abrir el programa Win32 Disk Imager
	3- Seleccionar la carpeta destino donde se vaya a clonar la imagen de la SD
	4- IMPORTANTE: dar nombre al archivo de imagen con la extensión ".img" como por ejemplo: "robopi_12_SD_clone.img"
	(Win32 Disk Imager no pone la extensión del archivo)
	5- Pulsar el botón "Read"
	6- IMPORTANTE: Esperar a que termine sin ejecutar otros programas. La RAM podría llenarse y fallaría el proceso de clonado
	
### Paso 3: Clonar imagen desde el PC a la microSD

	1- Introducir microSD
	2- Arrancar programa Win32 Disk Imager
	3- Seleccionar directorio del PC con la imagen (fichero .img)
	4- seleccionar device del dropdownlist
	5- Pulsar el botón "Write"
	6- IMPORTANTE: Esperar a que termine sin ejecutar otros programas. La RAM podría llenarse y fallaría el proceso de clonado
