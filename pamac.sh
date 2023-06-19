#!/bin/bash
#!/bin/bash

# Clonar yay desde el AUR
# hay que tener git instalado. Instalelo así:(sudo pacman -S git)
git clone https://aur.archlinux.org/yay.git
cd yay

# Compilar e instalar yay
echo "***********************************"
echo "******* Instalando Yay  ***********"
echo "***********************************"

yes | makepkg -si

# Limpiar directorio después de la instalación
cd ..
rm -rf yay

# Instalar pamac-all
echo "***********************************"
echo "****  Instalando Pamac  ***********"
echo "***********************************"

# Instalar pamac-all con respuestas parametrizadas
echo "n" | yay -S --noconfirm pamac-all  # Respuesta "1" para la primera opción
echo "a" | yay -S --noconfirm pamac-all  # Respuesta "2" para la segunda opción


