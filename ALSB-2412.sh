#!/bin/bash
clear
    echo ""
	echo "*********************************************************************************************"
	echo "<<<<<<<<<<<<<<<<<<             "Editor Sanbus"               >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	echo "<<<<<<<<<<<<<<<<<        "Sistema en español en liveCD"         >>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	echo "<<<<<<<<<<<<<<       Verions GPT-BIOS GPT-UEFI 202906-1200       >>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	echo "<<<<<          "Colaboración https://www.patreon.com/codigocristo"      >>>>>>>>>>>>>>>>>>>>>"
	echo "*********************************************************************************************"
	echo ""
idioma=$(curl https://ipapi.co/languages | awk -F "," '{print $1}' | sed 's/-/_/g' | sed "s|$|.UTF8|")
echo ""
echo "$idioma UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=$idioma" > /etc/locale.conf
exportlang=$(echo "LANG=$idioma")
export $exportlang
export LANG=$idioma
export $(cat /etc/locale.conf)
locale-gen
echo ""
clear

discosdisponibles=$(echo "print devices" | parted | grep /dev/ | awk '{if (NR!=1) {print}}' | sed '/sr/d')
clear
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _
echo ""
echo "Rutas de Disco disponible: "
echo ""
echo $discosdisponibles
echo ""
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _
    echo ""
	echo "******************************************************************************"
	echo "<<<<<<<<<<<<<<<<     Ingresar Datos de personales       >>>>>>>>>>>>>>>>>>>>>>"
	echo "******************************************************************************"
	echo ""

read -p "Introduce tu disco a instalar Arch: " disco
echo ""
read -p "Introduce El nombre del PC: " hostname
echo ""
read -p "Introduce Nombre usuario Nuevo: " user
echo ""
read -p "Introduce la clave de $user: " userpasswd
echo ""
read -p "Introduce la clave de Root/Administrador: " rootpasswd
echo ""

printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _
    echo ""
	echo "******************************************************************************"
	echo "<<<<<<<<<<<<<<<<<<     ENTORNO DE ESCRITORIO       >>>>>>>>>>>>>>>>>>>>>>>>>>>"
	echo "<<< Ingresa una opción marcando el numero correcto: (1 - 2 - 3 - 4)  >>>>>>>>>"
	echo "******************************************************************************"
	echo ""
echo "1. Terminal Virtual (TTY)"
echo "2. Xfce4"
echo "3. Kde Plasma"
echo "4. Gnome 40"
echo ""
read -p "Introduce la opción de Escritorio: " escritorio
echo ""

# Mostrar datos guardados
clear
    echo ""
	echo "******************************************************************************"
	echo "<<<<<<<<<<<<<<<<<<              Resumen            >>>>>>>>>>>>>>>>>>>>>>>>>>>"
	echo "******************************************************************************"
	echo ""
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _
echo ''
echo "Selección de Disco: $disco"
echo ''
echo "Nombre del PC: $hostname"
echo ''
echo "Tu usuario: $user"
echo ''
echo "Clave de usuario: $userpasswd"
echo ''
echo "Clave de Administrador: $rootpasswd"
echo ''
echo "Entorno de escritorio: $escritorio"
echo ''

# Vemos que opción elige el usuario y realiza tal acción en este caso mostrar mensaje
case $escritorio in
  1)
    echo "Escritorio : Terminal Virtual (TTY)"
  ;;

  2)
    echo "Escritorio : Xfce4"
  ;;

  3)
    echo "Escritorio : Kde Plasma"
  ;;

  4)
    echo "Escritorio : Gnome 40"
  ;;
  *)
    echo "¡Incorrecto! por defecto se instalará Terminal Virtual (TTY)"
  ;;
esac
echo ""
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _
echo ""
echo ""
echo "Para confirmar e instalar Arch Linux"
echo ""
echo "Presione ENTER o para salir presione CTRL + C"
read line


#---------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------
# DETECTA SI NUESTRO SISTEMA ES UEFI O BIOS LEGACY
	echo ""
	echo "***********************************************************************************"
	echo "<<<<<         DEFINIR BOOT del Disco : BIOS O UEFI                   >>>>>>>>>>>>>>"
    echo "<<<<<                                                                >>>>>>>>>>>>>>"
	echo "<<<<<          1. AUTOMATICA   (No sé que tipo de Boot Tengo)        >>>>>>>>>>>>>>"
	echo "<<<<<          2. MANUAL       (Sé que tipo de Boot Tengo)           >>>>>>>>>>>>>>"
	echo "<<<<<                                                                >>>>>>>>>>>>>>"
	echo "***********************************************************************************"
	read -p "Introduce la opción de particionado: " uefibios
    echo ""
	echo "Seccionaste la opción: $uefibios"
	sleep 2

if [ $uefibios == 1 ]; then
    uefi=$( ls /sys/firmware/efi/ | grep -ic efivars )
else
echo ""
	echo "******************************************************************************"
	echo "<<<<<              SELECCIÓN MANUAL                             >>>>>>>>>>>>>>"
	echo "<<<<<       GPT en BIOS Lagcy          PRESIONE 0               >>>>>>>>>>>>>>"
	echo "<<<<<       GPT en UEFI                PRESIONE 1               >>>>>>>>>>>>>>"
	echo "<<<<<       PREVIA PARTICION MANUAL    PRESIONE 2               >>>>>>>>>>>>>>"
	echo "<<<<<                                                           >>>>>>>>>>>>>>"
	echo "******************************************************************************"
	read -p "Introduce la opción de particionado: " uefi
    echo ""
	echo "Seccionaste la opción: $uefi"
	sleep 3
   	
fi

if   [ $uefi == 1 ]
 then

	clear
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _
	echo ""
	echo "Tu Sistema es UEFI"
	echo ""
	date "+%F %H:%M"
	sleep 3
	#Fuente: https://wiki.archlinux.org/index.php/GPT_fdisk

	#Metodo con EFI - SWAP - ROOT - HOME
	#+100M 			tamaño particion boot
	#+${swapsize}G  tamaño particion swap
	#0				tamaño particion root 100%
	#				Cambien valores si desean

	# Esta variable pone la misma cantidad de Gib que tenemos en ram fisica
	# free --giga | awk '/^Mem:/{print $2}'

	swapsize=$(free --giga | awk '/^Mem:/{print $2}')
	#dd if=/dev/zero of="${disco}" bs=4M conv=fsync oflag=direct status=progress
	(echo Ignore) | sgdisk --zap-all ${disco}
	#parted ${disco} mklabel gpt
	(echo 2; echo w; echo Y) | gdisk ${disco}
	sgdisk ${disco} -n=1:0:+100M -t=1:ef00
	sgdisk ${disco} -n=2:0:+${swapsize}G -t=2:8200
	sgdisk ${disco} -n=3:0:+77G  -t=2:8300
	sleep 5
	sgdisk ${disco} -n=4:0:0
	sleep 5
	fdisk -l ${disco} > /tmp/partition
	echo ""
	cat /tmp/partition
	sleep 3

	partition="$(cat /tmp/partition | grep /dev/ | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1}')"

	echo $partition | awk -F ' ' '{print $1}' >  boot-efi
	echo $partition | awk -F ' ' '{print $2}' >  swap-efi
	echo $partition | awk -F ' ' '{print $3}' >  root-efi
    echo $partition | awk -F ' ' '{print $4}' >  home-bios
	clear
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _
	echo ""
	echo "Partición EFI es:" 
	cat boot-efi
	echo ""
	echo "Partición SWAP es:"
	cat swap-efi
	echo ""
	echo "Partición ROOT es:"
	cat root-efi
	sleep 3
	echo "Partición HOME es:"
	cat home-bios
	sleep 3

	clear
	echo ""
	echo "Formateando Particiones"
	echo ""
	mkfs.ext4 $(cat root-efi) 
	mount $(cat root-efi) /mnt 

	mkdir -p /mnt/efi 
	mkfs.fat -F 32 $(cat boot-efi) 
	mount $(cat boot-efi) /mnt/efi 

	mkswap $(cat swap-efi) 
	swapon $(cat swap-efi)
	#HOME
	mkfs.ext4 $(cat home-bios)
	    sleep 2
    mkdir /mnt/home
    mount $(cat home-bios) /mnt/home
	rm boot-efi
	rm swap-efi
	rm root-efi
	RM home-bios

	clear
	echo ""
	echo "Revise en punto de montaje en MOUNTPOINT - PRESIONE ENTER"
	echo ""
	echo "De lo contrario PRESIONE CONTROL + C para cancelar"
	lsblk -l
	read line

elif [ $uefi == 0 ]
    then
	clear
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _
	echo ""
	echo "******************************************************************************"
	echo "<<<<<              PARTICIONAMIENTO DE DISCO                    >>>>>>>>>>>>>>"
	echo "<<<<<        Tabla de Particion GPT en BIOS Lagcy               >>>>>>>>>>>>>>"
	echo "******************************************************************************"
	echo ""
	date "+%F %H:%M"
	#swapsize=$(free --giga | awk '/^Mem:/{print $2}')
	sgdisk --zap-all ${disco} #borra todas las particiones
	sleep 3
	echo "Formateo de Sector Zero"
		sgdisk ${disco} -n=1:0:+100M -t=1:ef02
	sleep 5
	fdisk -l
		#sgdisk ${disco} -n=2:0:+${swapsize}G -t=2:8200
		sgdisk ${disco} -n=2:0:+8G -t=2:8200
	sleep 5
	clear
	fdisk -l
		sgdisk ${disco} -n=3:0:+77G  -t=2:8300
	sleep 5
	clear
	fdisk -l
		sgdisk ${disco} -n=4:0:0
	sleep 5
	clear
	fdisk -l
		fdisk -l ${disco} > /tmp/partition 
	cat /tmp/partition
	echo ""
	sleep 3
	lsblk
	echo "Revise en punto de montaje en MOUNTPOINT - PRESIONE ENTER"
    read line
	partition="$(cat /tmp/partition | grep /dev/ | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1}')"

	echo $partition | awk -F ' ' '{print $1}' >  boot-bios
	echo $partition | awk -F ' ' '{print $2}' >  swap-bios
    echo $partition | awk -F ' ' '{print $3}' >  root-bios
    echo $partition | awk -F ' ' '{print $4}' >  home-bios

	clear
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _
	echo ""
	echo "Partición BOOT es:" 
	cat boot-bios
	echo ""
	echo "Partición SWAP es:"
	cat swap-bios
	echo ""
	echo "Partición ROOT es:"
	cat root-bios
    echo ""
    echo "Partición HOME es:"
	cat home-bios
	sleep 3

	clear
	echo ""
	echo "Formateando Particiones"	# Formateo de particiones
      mkswap $(cat swap-bios)
	  	sleep 2
	  swapon $(cat swap-bios)
	  sleep 2
	  mkfs.ext4 $(cat root-bios) 
	    sleep 2
	  echo ">>> pesione s para SI o Entrer para continuar <<<<"
	  read line
      mkfs.ext4 $(cat home-bios)
	    sleep 2
	  echo ">>> pesione s para SI o Entrer para continuar <<<<"
	  read line
      # Montar las particiones
      mount $(cat root-bios) /mnt 
	    sleep 2
      mkdir /mnt/home
      mount $(cat home-bios) /mnt/home
    
	clear
	echo ""
	lsblk -l
	echo "********************************************************************************"
	echo "<<<<<<<< Revise en punto de montaje en MOUNTPOINT - PRESIONE ENTER >>>>>>>>>>>>>"
	echo "********************************************************************************"
	read line
	
elif [ $uefi == 2 ]
then

    echo "*************************************************************************************"
	echo "<<<<<<<< SE DEFINIÓ MANUALMENTE EL PARTICIONAMIENTO Y PUNTOS DE MONTAJE >>>>>>>>>>>>>"
	echo "<<<<<<<<            CONTINUAMOS CON LA INSTALACION DE ARCH              >>>>>>>>>>>>>"
	echo "*************************************************************************************"
	sleep 5
	(
      echo g     # Crear una nueva tabla de particiones GPT
      echo n     # Crear una nueva partición   --  Boot Bios GPT
      echo       # Número de partición (por defecto: 1)
      echo       # Primer sector (por defecto: primer sector disponible)
      echo +100M # Último sector (+100M para la partición de /boot) (definimos tamaño con el simbolo + , el número y temnado en G =gigabytes o M=megabytes)
	  sleep 4	#Este número son segundos de espera para rear el formato. este tiempo puede aumentar en disco mecanicos
	  echo "PARTICION BOOT CREADA"
	  echo n     # Crear una nueva partición  --  Swap
      echo       # Número de partición (por defecto:SIGUIENTE PARTICION DISPONIBLE)
      echo       # Primer sector (por defecto: primer sector disponible)
      echo +8G  # partición del sistema swap (definimos tamaño con el simbolo + , el número y temnado en G =gigabytes o M=megabytes)
	  sleep 4	#Este número son segundos de espera para rear el formato. este tiempo puede aumentar en disco mecanicos
	  echo "PARTICION SWAP CREADA"
      echo n     # Crear una nueva partición  -- root
      echo       # Número de partición (por defecto:SIGUIENTE PARTICION DISPONIBLE)
      echo       # Primer sector (por defecto: primer sector disponible)
      echo +77G  # partición del root
	  sleep 4	  #Este número son segundos de espera para rear el formato. este tiempo puede aumentar en disco mecanicos
	  echo "PARTICION (ROOT/RAIZ) CREADA"
	  echo n     # Crear una nueva partición  -- home
      echo       # Número de partición (por defecto:SIGUIENTE PARTICION DISPONIBLE)
      echo       # Primer sector (por defecto: primer sector disponible)
      echo       # Último sector (por defecto: último sector disponible, usar todo el espacio restante)
	  sleep 4	 #Este número son segundos de espera para rear el formato. este tiempo puede aumentar en disco mecanicos
	  echo "PARTICION RESTANTE CREADA (ESPACIO LIBRE)"
      echo t     # cambiar tipo de particion al boot
      echo 1     # Nuemero de partición (<< 1 >> es la primera particon creada)
      echo 4     # Tipo de particion boot (El número 4 es el asignado para >> Boot Partiion<< )
	  sleep 2
      echo t     # cambiar tipo de particion al swap
      echo 2     # Nuemero de partición creada para el swap
      echo 19    # Tipo de particion swap (El número 19 es el asignado para >> Boot Partiion<< !!VALIDAR DE NO FUNCIONAR¡¡¡)
	  sleep 2
      echo w     # Guardar y salir
	  sleep 2
    ) | fdisk ${disco}
	#echo "Formateando Particiones"	# Formateo de particiones
     mkswap /dev/sda2             #formateando particion Swap
	 sleep 2
	 swapon /dev/sda2             #Activando particion Swap
	 sleep 2
	 mkfs.ext4 /dev/sda3          #formateando particion raiz
	  sleep 5
     mkfs.ext4 /dev/sda4    #FORMATEO!!!  particion home
	  sleep 5
	 mount /dev/sda3 /mnt       # Montar las particione Raiz en carpeta temporal mnt
     mkdir /mnt/home            # Creando carpeta home en mnt
     mount /dev/sda4 /mnt/home  # Montar las particione HOME en carpeta mnt
    
	lsblk -l
	echo ""
	echo "********************************************************************************"
	echo "<<<<<<<< Revise en punto de montaje en MOUNTPOINT - PRESIONE ENTER >>>>>>>>>>>>>"
	echo "********************************************************************************"
	read line
else 
 
    echo "<<<<<<<<                   OPCION ERRADA                           >>>>>>>>>>>>>"
	echo "*************************************************************************************"
	sleep 5
	exit
	
fi

clear
echo "Actualización de llaves y mirroslist del LIVECD"
pacman -Syy
pacman -Sy archlinux-keyring --noconfirm 
clear
pacman -Sy reflector python rsync glibc curl --noconfirm 
sleep 3
clear
echo ""
echo "Actualizando lista de MirrorList"
echo ""
reflector --verbose --latest 5 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist
clear
cat /etc/pacman.d/mirrorlist
sleep 3
clear

# Instalando Sistema base en nuestro Disco
    echo "********************************************************************************"
    echo ">>>>>>>>>>>>>>>>>>>>>>>   INSTALANDO SISTEMA BASE  >>>>>>>>>>>>>>>>>>><>>>>>>>>"
    echo "**** ( base base-devel nano reflector python rsync ) ***************************"
pacstrap /mnt base base-devel nano reflector python rsync
clear

# Creando Archiv FSTAB para detectar al iniciar el sistema
    echo ""
	echo "******************************************************************************"
	echo "<<<<<  Creando Archiv FSTAB para detectar al iniciar el sistema >>>>>>>>>>>>>>"
	echo "******************************************************************************"
	echo ""
echo ""
echo "Archivo FSTAB"
echo ""
echo "genfstab -p /mnt >> /mnt/etc/fstab"
echo ""
genfstab -p /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
sleep 4
clear

# Configurando pacman para que tenga colores con el repo de MultiLib
    echo ""
	echo "******************************************************************************"
	echo "<<<<<<<<<<<<<   Pacman colores y repo de MultiLib   >>>>>>>>>>>>>>>>>>>>>>>>>>"
	echo "******************************************************************************"
	echo ""
sed -i 's/#Color/Color/g' /mnt/etc/pacman.conf
sed -i 's/#TotalDownload/TotalDownload/g' /mnt/etc/pacman.conf
sed -i 's/#VerbosePkgLists/VerbosePkgLists/g' /mnt/etc/pacman.conf
sed -i "37i ILoveCandy" /mnt/etc/pacman.conf
sed -i 's/#[multilib]/[multilib]/g' /mnt/etc/pacman.conf
sed -i "s/#Include = /etc/pacman.d/mirrorlist/Include = /etc/pacman.d/mirrorlist/g" /mnt/etc/pacman.conf
clear

# Hosts y Nombre de computador
clear
echo "$hostname" > /mnt/etc/hostname
echo "127.0.1.1 $hostname.localdomain $hostname" > /mnt/etc/hosts
clear
echo "Hostname: $(cat /mnt/etc/hostname)"
echo ""
echo "Hosts: $(cat /mnt/etc/hosts)"
echo ""
clear

# Agregando usuario y claves con administrador
    echo ""
	echo "******************************************************************************"
	echo "<<<<<<<<<<<<<<<  usuario y claves con administrador  >>>>>>>>>>>>>>>>>>>>>>>>>>"
	echo "******************************************************************************"
	echo ""
arch-chroot /mnt /bin/bash -c "(echo $rootpasswd ; echo $rootpasswd) | passwd root"
arch-chroot /mnt /bin/bash -c "useradd -m -g users -s /bin/bash $user"
arch-chroot /mnt /bin/bash -c "(echo $userpasswd ; echo $userpasswd) | passwd $user"
sed -i "80i $user ALL=(ALL) ALL"  /mnt/etc/sudoers
clear

    echo ""
	echo "******************************************************************************"
	echo "<<<<<<<<<<<<<<<<<<       Idioma del sistema        >>>>>>>>>>>>>>>>>>>>>>>>>>>"
	echo "******************************************************************************"
	echo ""
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _
echo -e ""
echo -e "\t\t\t| Idioma del Sistema |"
echo -e ""
echo "$idioma UTF-8" > /mnt/etc/locale.gen
arch-chroot /mnt /bin/bash -c "locale-gen" 
echo "LANG=$idioma" > /mnt/etc/locale.conf
echo ""
cat /mnt/etc/locale.conf 
echo ""
cat /mnt/etc/locale.gen
sleep 4
echo ""
arch-chroot /mnt /bin/bash -c "export $(cat /mnt/etc/locale.conf)" 
export $(cat /mnt/etc/locale.conf)
arch-chroot /mnt /bin/bash -c "sudo -u $user export $(cat /etc/locale.conf)"
export $(cat /etc/locale.conf)
export $(cat /mnt/etc/locale.conf)
exportlang=$(echo "LANG=$idioma")
export $exportlang
export LANG=$idioma
locale-gen
arch-chroot /mnt /bin/bash -c "locale-gen" 
sleep 3
clear

    echo ""
	echo "******************************************************************************"
	echo "<<<<<<<<<<<<<<<<<<     Zona horaria Automatica     >>>>>>>>>>>>>>>>>>>>>>>>>>>"
	echo "******************************************************************************"
	echo ""
arch-chroot /mnt /bin/bash -c "pacman -Sy curl --noconfirm"
curl https://ipapi.co/timezone > zonahoraria
zonahoraria=$(cat zonahoraria)
arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/$zonahoraria /etc/localtime"
arch-chroot /mnt /bin/bash -c "timedatectl set-timezone $zonahoraria"
arch-chroot /mnt /bin/bash -c "pacman -S ntp --noconfirm"
arch-chroot /mnt /bin/bash -c "ntpd -qg"
arch-chroot /mnt /bin/bash -c "hwclock --systohc"
sleep 3
rm zonahoraria
clear

# Establecer un mapa de teclado para la terminal virtual
curl https://ipapi.co/languages | awk -F "," '{print $1}' | sed -e's/.$//' | sed -e's/.$//' | sed -e's/.$//' > keymap
keymap=$(cat keymap)
echo "KEYMAP=$keymap" > /mnt/etc/vconsole.conf 
cat /mnt/etc/vconsole.conf 
clear

# Actualiza lista de mirrors en tu disco
echo ""
echo "Actualizando lista de MirrorList"
echo ""
arch-chroot /mnt /bin/bash -c "reflector --verbose --latest 15 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist"
clear
cat /mnt/etc/pacman.d/mirrorlist
sleep 3
clear

    echo ""
	echo "******************************************************************************"
	echo "<<<<<<<<<<<<<<<<<<  Instalación del kernel stable  >>>>>>>>>>>>>>>>>>>>>>>>>>>"
	echo "******************************************************************************"
	echo ""
arch-chroot /mnt /bin/bash -c "pacman -S linux-firmware linux linux-headers mkinitcpio --noconfirm"
clear

    echo ""
	echo "******************************************************************************"
	echo "<<<<<<<<<<<<<<<<<<  Instalación de GRUB - Arranque  >>>>>>>>>>>>>>>>>>>>>>>>>>>"
	echo "******************************************************************************"
	echo ""
if [ $uefi == 1 ]
then

clear
arch-chroot /mnt /bin/bash -c "pacman -S grub efibootmgr os-prober dosfstools --noconfirm"
echo '' 
echo 'Instalando EFI System >> bootx64.efi' 
arch-chroot /mnt /bin/bash -c 'grub-install --target=x86_64-efi --efi-directory=/efi --removable' 
echo '' 
echo 'Instalando UEFI System >> grubx64.efi' 
arch-chroot /mnt /bin/bash -c 'grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Arch'
sed -i "6iGRUB_CMDLINE_LINUX_DEFAULT="loglevel=3"" /mnt/etc/default/grub
sed -i '7d' /mnt/etc/default/grub
echo ''
arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
echo '' 
echo 'ls -l /mnt/efi' 
ls -l /mnt/efi 
echo '' 
echo 'Lea bien que no tenga ningún error marcado' 
echo '> Confirme tener las IMG de linux para el arranque' 
echo '> Confirme tener la carpeta de GRUB para el arranque' 
sleep 4

else

clear
arch-chroot /mnt /bin/bash -c "pacman -S grub os-prober --noconfirm"
echo '' 
arch-chroot /mnt /bin/bash -c "grub-install --target=i386-pc $disco"
sed -i "6iGRUB_CMDLINE_LINUX_DEFAULT="loglevel=3"" /mnt/etc/default/grub
sed -i '7d' /mnt/etc/default/grub
echo ''
arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
echo '' 
echo 'ls -l /mnt/boot' 
ls -l /mnt/boot 
echo '' 
echo 'Lea bien que no tenga ningún error marcado' 
echo '> Confirme tener las IMG de linux para el arranque' 
echo '> Confirme tener la carpeta de GRUB para el arranque' 

fi
clear

    echo ""
	echo "******************************************************************************"
	echo "<<<<<<<<<<<<<<<<<<<<<<       "Ethernet"          >>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	echo "******************************************************************************"
	echo ""
arch-chroot /mnt /bin/bash -c "pacman -S dhcpcd networkmanager iwd net-tools ifplugd --noconfirm"
arch-chroot /mnt /bin/bash -c "systemctl enable dhcpcd NetworkManager"
echo "noipv6rs" >> /mnt/etc/dhcpcd.conf
echo "noipv6" >> /mnt/etc/dhcpcd.conf
# Wifi
arch-chroot /mnt /bin/bash -c "pacman -S iw wireless_tools wpa_supplicant dialog wireless-regdb --noconfirm"

# Bluetoot
#arch-chroot /mnt /bin/bash -c "pacman -S bluez bluez-utils pulseaudio-bluetooth"

clear

    echo ""
	echo "******************************************************************************"
	echo "<<<<<<<<<<             Directorios del sistema                   >>>>>>>>>>>>>"
	echo "******************************************************************************"
	echo ""
arch-chroot /mnt /bin/bash -c "xdg-user-dirs-update"
echo ""
arch-chroot /mnt /bin/bash -c "ls /home/$user"
sleep 3
clear
    echo "********A**********************************************************************"
	echo "<<<<<<<<<<<<<<<<<<<<<<<    Drivers de VGA o GPU   >>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	echo "*******************************************************************************"
# Driver de Vídeo automatico solo driver Libres
if (lspci | grep VGA | grep "NVIDIA\|nVidia" &>/dev/null); then
    echo ""
	echo "********************************************************************************"
	echo "<<<<<<<<<<<<<<<<<< GPU NVIDIA\|nVidia R\|R2/R3/R4/R5   >>>>>>>>>>>>>>>>>>>>>>>>>"
	echo "********************************************************************************"
	echo ""
    sleep 2
arch-chroot /mnt /bin/bash -c "pacman -S xf86-video-nouveau mesa lib32-mesa mesa-vdpau libva-mesa-driver lib32-mesa-vdpau lib32-libva-mesa-driver libva-vdpau-driver libvdpau-va-gl libva-utils vdpauinfo libvdpau lib32-libvdpau opencl-mesa clinfo ocl-icd lib32-ocl-icd opencl-headers --noconfirm"

elif (lspci | grep VGA | grep "Radeon R\|R2/R3/R4/R5" &>/dev/null); then
    echo ""
	echo "***********************************************************************************"
	echo "<<<<<<<<<<<<<<<<<<<<< AMD/GPU Radeon R\|R2/R3/R4/R5   >>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	echo "***********************************************************************************"
	echo ""echo "Istalando....."
    sleep 5  
#arch-chroot /mnt /bin/bash -c "pacman -S xf86-video-amdgpu mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon mesa-vdpau libva-mesa-driver lib32-mesa-vdpau lib32-libva-mesa-driver libva-vdpau-driver libvdpau-va-gl libva-utils vdpauinfo opencl-mesa clinfo ocl-icd lib32-ocl-icd opencl-headers --noconfirm"
arch-chroot /mnt /bin/bash -c "pacman -S xf86-video-amdgpu vulkan-radeon mesa mesa-vdpau libva-mesa-driver libva-vdpau-driver libvdpau-va-gl libva-utils vdpauinfo opencl-mesa clinfo ocl-icd opencl-headers --noconfirm"
							   #pacman -S xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon
elif (lspci | grep VGA | grep "ATI\|AMD/ATI" &>/dev/null); then
    echo ""
	echo "***********************************************************************************"
	echo "<<<<<<<<<<<<<<<<<<<<<<   "VGA Integrado AMD / ATI"    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	echo "***********************************************************************************"
	echo ""
    sleep 2           
arch-chroot /mnt /bin/bash -c "pacman -S xf86-video-ati mesa lib32-mesa mesa-vdpau libva-mesa-driver lib32-mesa-vdpau lib32-libva-mesa-driver libva-vdpau-driver libvdpau-va-gl libva-utils vdpauinfo opencl-mesa clinfo ocl-icd lib32-ocl-icd opencl-headers --noconfirm"

elif (lspci | grep VGA | grep "Intel" &>/dev/null); then
    echo ""
	echo "*******************************************************************************"
	echo "<<<<<<<<<<<<<<<<<<<<<<   "VGA Integrado Intel"    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	echo "*******************************************************************************"
	echo ""
    sleep 2        
arch-chroot /mnt /bin/bash -c "pacman -S xf86-video-intel vulkan-intel mesa lib32-mesa intel-media-driver libva-intel-driver libva-vdpau-driver libvdpau-va-gl libva-utils vdpauinfo intel-compute-runtime beignet clinfo ocl-icd lib32-ocl-icd opencl-headers --noconfirm"
    
else
    echo ""
	echo "***********************************************************************************"
	echo "<<<<<<<<<<<<<<<<<<<<<<   "VGA Integrado Estandar"    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	echo "**********************************************************************************"
	echo ""
    sleep 2   
arch-chroot /mnt /bin/bash -c "pacman -S xf86-video-vesa xf86-video-fbdev mesa mesa-libgl lib32-mesa --noconfirm"

fi
sleep 3
clear

# Escritorio seleccionado
case $escritorio in
  1)
    echo "Escritorio : Terminal Virtual (TTY)"
    sleep 3
    clear
  ;;

  2)
    echo ""
	echo "*******************************************************************************"
	echo "<<<<<<<<<<<<<<<<<<<<<<<   "Escritorio : Xfce4"    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	echo "*******************************************************************************"
	echo ""
    sleep 2

    # Instala Xorg
	arch-chroot /mnt /bin/bash -c "pacman -S xorg xorg-apps xorg-xinit xorg-twm xterm xorg-xclock --noconfirm"
clear
    # Programas de Xfce4
    arch-chroot /mnt /bin/bash -c "pacman -S xfce4 xfce4-goodies network-manager-applet ffmpegthumbs ffmpegthumbnailer --noconfirm"
clear	
	# Programas para Login
	arch-chroot /mnt /bin/bash -c "pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings light-locker accountsservice --noconfirm"
	arch-chroot /mnt /bin/bash -c "systemctl enable lightdm"
clear
	# Establecer formato de teclado dentro de Xorg
	keymap="latam"
	# Aqui podemos ponerlo en " latam - es - us " 
	# Algún otro idioma que queremos para nuestro teclado mi caso es : latam
clear
	touch /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
	echo -e 'Section "InputClass"' > /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
	echo -e 'Identifier "system-keyboard"' >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
	echo -e 'MatchIsKeyboard "on"' >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
	echo -e 'Option "XkbLayout" "latam"' >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
	echo -e 'EndSection' >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
	echo ""
	cat /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
	sleep 5
clear

	# Formatos de lectura de todo tipo de discos incluido android
	arch-chroot /mnt /bin/bash -c "pacman -S android-file-transfer android-tools android-udev msmtp libmtp libcddb gvfs gvfs-afc gvfs-smb gvfs-gphoto2 gvfs-mtp gvfs-goa gvfs-nfs gvfs-google dosfstools jfsutils f2fs-tools btrfs-progs exfat-utils ntfs-3g reiserfsprogs udftools xfsprogs nilfs-utils polkit gpart mtools --noconfirm"
clear
	# Audio
	arch-chroot /mnt /bin/bash -c "pacman -S pulseaudio pavucontrol --noconfirm"
clear

	# Fonts
	arch-chroot /mnt /bin/bash -c "pacman -S gnu-free-fonts ttf-hack ttf-inconsolata gnome-font-viewer --noconfirm"
clear

  ;;

  3)
    echo "Escritorio : Kde Plasma"
    sleep 3

    # Instala Xorg
	arch-chroot /mnt /bin/bash -c "pacman -S xorg xorg-apps xorg-xinit xorg-twm xterm xorg-xclock --noconfirm"

    # Programas para KDE Plasma minimalista
    arch-chroot /mnt /bin/bash -c "pacman -S plasma dolphin konsole discover sddm ffmpegthumbs ffmpegthumbnailer --noconfirm"
    arch-chroot /mnt /bin/bash -c "systemctl enable sddm"

    # Establecer formato de teclado dentro de Xorg
	keymap="latam"
	# Aqui podemos ponerlo en " latam - es - us " 
	# Algún otro idioma que queremos para nuestro teclado mi caso es : latam

	touch /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
	echo -e 'Section "InputClass"' > /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
	echo -e 'Identifier "system-keyboard"' >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
	echo -e 'MatchIsKeyboard "on"' >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
	echo -e 'Option "XkbLayout" "latam"' >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
	echo -e 'EndSection' >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
	echo ""
	cat /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
	sleep 5
	clear

	# Formatos de lectura de todo tipo de discos incluido android
	#arch-chroot /mnt /bin/bash -c "pacman -S android-file-transfer android-tools android-udev msmtp libmtp libcddb gvfs gvfs-afc gvfs-smb gvfs-gphoto2 gvfs-mtp gvfs-goa gvfs-nfs gvfs-google dosfstools jfsutils f2fs-tools btrfs-progs exfat-utils ntfs-3g reiserfsprogs udftools xfsprogs nilfs-utils polkit gpart mtools --noconfirm"

	# Audio
	arch-chroot /mnt /bin/bash -c "pacman -S pulseaudio pavucontrol --noconfirm"
	clear

	# Fonts
	arch-chroot /mnt /bin/bash -c "pacman -S gnu-free-fonts ttf-hack ttf-inconsolata gnome-font-viewer --noconfirm"
	clear

;;

  4)
    echo "Escritorio : Gnome 40"
    sleep 3

    # Instala Xorg
	arch-chroot /mnt /bin/bash -c "pacman -S xorg xorg-apps xorg-xinit xorg-twm xterm xorg-xclock --noconfirm"

    # Programas para Gnome minimalista
    arch-chroot /mnt /bin/bash -c "pacman -S gnome-shell gdm gnome-control-center gnome-tweaks gnome-terminal nautilus --noconfirm"
    arch-chroot /mnt /bin/bash -c "systemctl enable gdm"

    # Establecer formato de teclado dentro de Xorg
	keymap="latam"
	# Aqui podemos ponerlo en " latam - es - us " 
	# Algún otro idioma que queremos para nuestro teclado mi caso es : latam

	touch /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
	echo -e 'Section "InputClass"' > /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
	echo -e 'Identifier "system-keyboard"' >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
	echo -e 'MatchIsKeyboard "on"' >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
	echo -e 'Option "XkbLayout" "latam"' >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
	echo -e 'EndSection' >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
	echo ""
	cat /mnt/etc/X11/xorg.conf.d/00-keyboard.conf
	sleep 5
	clear

	# Formatos de lectura de todo tipo de discos incluido android
	arch-chroot /mnt /bin/bash -c "pacman -S android-file-transfer android-tools android-udev msmtp libmtp libcddb gvfs gvfs-afc gvfs-smb gvfs-gphoto2 gvfs-mtp gvfs-goa gvfs-nfs gvfs-google dosfstools jfsutils f2fs-tools btrfs-progs exfat-utils ntfs-3g reiserfsprogs udftools xfsprogs nilfs-utils polkit gpart mtools --noconfirm"

	# Audio
	arch-chroot /mnt /bin/bash -c "pacman -S pulseaudio pavucontrol --noconfirm"
	clear

	# Fonts
	arch-chroot /mnt /bin/bash -c "pacman -S gnu-free-fonts ttf-hack ttf-inconsolata gnome-font-viewer --noconfirm"
	clear

	# Navegador Web
	arch-chroot /mnt /bin/bash -c "pacman -S firefox --noconfirm"
	clear
  ;;

  *)
    arch-chroot /mnt /bin/bash -c "pacman -Syu --noconfirm"
    clear
  ;;
esac

    # Directorios y appś del sistema personal
	echo ""
    echo "****************************************************************************************"
	echo "                      <            PROGRAMAS               >"
	echo "                      <            PERSONALES              >"
	echo "****************************************************************************************"
	echo ""
arch-chroot /mnt /bin/bash -c "yes | pacman -S --noconfirm firefox libreoffice xreader xarchiver unrar p7zip zip unzip git wget neofetch lsb-release xdg-user-dirs gparted rhythmbox vscode psensor transmission-gtk vlc"

    echo ""
	echo "******************************************************************************"
	echo "<<<<<<<<<<         validar instalacion de programas              >>>>>>>>>>>>>"
	echo "******************************************************************************"
	echo ""
    sleep 5
	clear

#DESMONTAR Y REINICIAR
umount -R /mnt
swapoff -a
echo ""
echo "Visita: https://t.me/ArchLinuxCristo"
echo ""
echo "Apóyame en Patreon: "
echo "https://www.patreon.com/codigocristo"
    echo ""
	echo "********************************************************************************************"
	echo ">>>>>>>>                     Terminamos, reiniciamos                 >>>>>>>>>>>>>>>>>>>>>>"
	echo "<<<<<<<                                y                              >>>>>>>>>>>>>>>>>>>>>>"
	echo ">>>>>>>>                debe retire el medio de inatlación            <<<<<<<<<<<<<<<<<<<<<<"
	echo "********************************************************************************************"
	echo ""
    sleep 5
reboot

#########################################################
#
# METODO DE DISCO PARA UEFI - BOOT - ROOT - HOME - SWAP 
#
	#+100M 			tamaño particion boot
	#+${swapsize}G  tamaño particion swap
	#+20G			tamaño particion root
	#0				tamaño partición home
	#				Cambien valores si desean
#
#	swapsize=$(free --giga | awk '/^Mem:/{print $2}')
#
#	dd if=/dev/zero of="${disco}" bs=100M count=10 status=progress
#	parted ${disco} mklabel gpt
#	sgdisk ${disco} -n=1:0:+100M -t=1:ef00
#	sgdisk ${disco} -n=2:0:+${swapsize}G -t=2:8200
#	sgdisk ${disco} -n=3:0:+20G -t=3:8300
#	sgdisk ${disco} -n=4:0:0
#	fdisk -l ${disco} > /tmp/partition
#	echo ""
#	echo ""
#	cat /tmp/partition
#	sleep 3
#
#	partition="$(cat /tmp/partition | grep /dev/ | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1}')"
#
#	echo $partition | awk -F ' ' '{print $1}' >  boot-efi
#	echo $partition | awk -F ' ' '{print $2}' >  swap-efi
#	echo $partition | awk -F ' ' '{print $3}' >  root-efi
#	echo $partition | awk -F ' ' '{print $4}' >  home-efi
#
#	clear
#	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _
#	echo ""
#	echo "Partición EFI es:" 
#	cat boot-efi
#	echo ""
#	echo "Partición SWAP es:"
#	cat swap-efi
#	echo ""
#	echo "Partición ROOT es:"
#	cat root-efi
#	echo ""
#	echo "Partición HOME es:"
#	cat home-efi
#	sleep 4
#
#	clear
#	echo ""
#	echo "Formateando Particiones"
#	echo ""
#	mkfs.ext4 $(cat root-efi) 
#	mount $(cat root-efi) /mnt 
#
#	mkdir -p /mnt/home
#	mkfs.ext4 $(cat home-efi) 
#	mount $(cat home-efi) /mnt/home
#
#	mkdir -p /mnt/efi 
#	mkfs.fat -F 32 $(cat boot-efi) 
#	mount $(cat boot-efi) /mnt/efi 
#
#	mkswap $(cat swap-efi) 
#	swapon $(cat swap-efi)
#
#	clear
#	echo ""
#	echo "Revise en punto de montaje en MOUNTPOINT"
#	echo ""
#	lsblk -l
#	sleep 3
#	clear

#########################################################
#
# METODO DE DISCO PARA BIOS - BOOT - ROOT - HOME - SWAP 
#
	#+100M 			particion boot
	#+${swapsize}G	particion swap
	#+20G			particion root
	#0				partición home 100%
#	Cambien valores si desean
#
#	swapsize=$(free --giga | awk '/^Mem:/{print $2}')
#
#	dd if=/dev/zero of="${disco}" bs=100M count=10 status=progress
#	(echo o; echo n; echo p; echo 1; echo ""; echo +100M; echo n; echo p; echo 2; echo ""; echo +${swapsize}G; echo n; echo p; echo 3; echo ""; echo +20G; echo n; echo p; echo 4; echo ""; echo ""; echo t; echo 2; echo 82; echo a; echo 1; echo w; echo q) | fdisk ${disco}
#	fdisk -l ${disco} > /tmp/partition 
#	cat /tmp/partition
#	sleep 3
#
#	partition="$(cat /tmp/partition | grep /dev/ | awk '{if (NR!=1) {print}}' | sed 's/*//g' | awk -F ' ' '{print $1}')"
#
#	echo $partition | awk -F ' ' '{print $1}' >  boot-bios
#	echo $partition | awk -F ' ' '{print $2}' >  swap-bios
#	echo $partition | awk -F ' ' '{print $3}' >  root-bios
#	echo $partition | awk -F ' ' '{print $4}' >  home-bios
#
#	clear
#	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' _
#	echo ""
#	echo "Partición BOOT es:" 
#	cat boot-bios
#	echo ""
#	echo "Partición SWAP es:"
#	cat swap-bios
#	echo ""
#	echo "Partición HOME es:"
#	cat home-bios
#	echo ""
#	echo "Partición ROOT es:"
#	cat root-bios
#	sleep 3
#
#	clear
#	echo ""
#	echo "Formateando Particiones"
#	echo ""
#	mkfs.ext4 $(cat root-bios) 
#	mount $(cat root-bios) /mnt 
#
#	mkdir -p /mnt/boot
#	mkfs.ext4 $(cat boot-bios) 
#	mount $(cat boot-bios) /mnt/boot
#
#	mkdir -p /mnt/home
#	mkfs.ext4 $(cat home-bios) 
#	mount $(cat home-bios) /mnt/home
#
#	mkswap $(cat swap-bios) 
#	swapon $(cat swap-bios)
#
#	clear
#	echo ""
#	echo "Revise en punto de montaje en MOUNTPOINT"
#	echo ""
#	lsblk -l
#	sleep 4
#	clear