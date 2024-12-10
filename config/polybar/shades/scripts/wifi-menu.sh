#!/usr/bin/env bash
#Creado por: Gonka79
#Mail: gonka79@protonmail.com
#Github : Gonka79
#Twitter: Gonka79
# Obtener la interfaz Wi-Fi
interface="wlan0"

# Comando para listar redes Wi-Fi disponibles
list_networks() {
    nmcli -t -f SSID,SECURITY dev wifi list ifname $interface | awk -F: '!seen[$1]++{print "📶 " $1 " - " $2}'
}

# Mostrar menú de rofi para seleccionar una red Wi-Fi
choose_network() {
    networks=$(list_networks)
    chosen_network=$(echo -e "$networks" | rofi -dmenu -theme "$HOME/.config/polybar/shades/scripts/rofi/wifi-menu.rasi" -p "Wi-Fi Networks")
    
    if [ "$chosen_network" ]; then
        ssid=$(echo "$chosen_network" | awk -F' - ' '{print $1}' | sed 's/📶 //')

        # Verificar si la red requiere contraseña
        security=$(echo "$chosen_network" | awk -F' - ' '{print $2}')
        if [ "$security" != "--" ]; then
            # Solicitar la contraseña usando rofi
            pass=$(rofi -dmenu -password -theme "$HOME/.config/polybar/shades/scripts/rofi/wifi-menu.rasi" -p "Contraseña para $ssid")
        fi

        # Conectar a la red
        if [ -n "$pass" ]; then
            nmcli dev wifi connect "$ssid" password "$pass" ifname $interface
        else
            nmcli dev wifi connect "$ssid" ifname $interface
        fi

        # Mostrar el resultado de la conexión
        if [ $? -eq 0 ]; then
            rofi -theme "$HOME/.config/polybar/shades/scripts/rofi/wifi-menu.rasi" -e "Conectado a $ssid con éxito."
        else
            rofi -theme "$HOME/.config/polybar/shades/scripts/rofi/wifi-menu.rasi" -e "Error al intentar conectar a $ssid."
        fi
    fi
}

# Obtener la red Wi-Fi actual
current_network=$(nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes' | cut -d ':' -f2)

# Mostrar menú de selección de red si se hace clic en el módulo Polybar
if [ "$1" == "--select" ]; then
    choose_network
else
    # Mostrar la red actual en Polybar o "No conectado" si no está conectado a ninguna red
    if [ -n "$current_network" ]; then
        echo "直"
    else
        echo "睊"
    fi
fi
