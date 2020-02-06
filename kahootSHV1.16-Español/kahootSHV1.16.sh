#!/bin/bash
dir="/opt/google/chrome";
execu="chrome";
delay=0.02;
k=3;
mode="autoclick"; #autoclick o manual
autoSetup="true";
kahootId="";
nick="";
askResponse="";
#colores:
  NC='\033[0m' # No Color
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  LRED='\033[1;31m'
  LGREEN='\033[1;32m'
  YELLOW='\033[1;33m'
  LBLUE='\033[1;34m'
#  Black        0;30     Dark Gray     1;30
#  Red          0;31     Light Red     1;31
#  Green        0;32     Light Green   1;32
#  Brown/Orange 0;33     Yellow        1;33
#  Blue         0;34     Light Blue    1;34
#  Purple       0;35     Light Purple  1;35
#  Cyan         0;36     Light Cyan    1;36
#  Light Gray   0;37     White         1;37
MOUSE_ID=$(xinput --list | grep -i -m 1 'Touchpad' | grep -o 'id=[0-9]\+' | grep -o '[0-9]\+');
STATE1=$(xinput --query-state $MOUSE_ID | grep 'button\[' | sort);
click=$true;
# ---------------------------------------------------------------------------------------------
# ----------------------------------------- FUNCIONES -----------------------------------------
#++++++ pequeña funciones ++++++
ask(){ # para leer en terminal, guarda la respuesta en askResponse
  text=$1;
  textEnd=$2;
  read -p "$(echo -e ${LBLUE}"$text"${NC} $textEnd)->" askResponse;
}

tab(){ #para cambiar entre la terminal y el navegador;
  press4me "alt+Tab";
  sleep 0.1;
  xdotool keyup "alt";
  xdotool keyup "Tab";
  sleep 1;
  if (( 1$1 == 11 )); then #if 1º argument == 1 ()
    xdotool key KP_Enter; #tecla enter
    sleep 1;
  fi
}

press4me(){ #para usar el teclado
  xdotool key --clearmodifiers "$1";
}

clicker(){
  for (( i=1; i <= $1; ++i )); do # $1 -> nº de veces que hacer click t tab (1º argumento).
    xdotool click 1;
    sleep $delay;
    press4me "ctrl+Tab";
    sleep $delay;
  done;
}


#loop: hace los clicks and cambia de ventanas
loop(){
  while true; do
    sleep $delay;
    STATE2=$(xinput --query-state $MOUSE_ID | grep 'button\[' | sort);#guarda el estado del ratón
    if test "$STATE1" != "$STATE2"; then #si el ratón se actualiza
      if $click; then
        click=false;#El ratón se actualiza 2 veces cada tick (OFF->ON, ON->OFF), sólo lo hacemos 1 vez (booleana)
        if [ "$mode" = "autoclick" ]; then # *************** Autoclick ***************
          clicker $k;
        else # *************** NORMAL ***************
          clicker 1;
        fi;
      fi;
    else
      click=true;
    fi;
    STATE1=$STATE2;
  done;
}

autoSetupFv2(){
  printf "\nAutoSetup activado, por favor espere\nEmpieza en ";
  for (( i = 3; i >= 0; i-- )); do
    printf "$i, ";
    sleep 0.5;
  done
  printf "  ${LBLUE}GO${NC}\n";
  cd $dir; #ve al directorio con el ejecutable
  ./$execu >/dev/null 2>&1 & #Ejecútalo. De esta manera, no vemos los errores que da el navegador en el terminal
  sleep 8;
  result=$(xdotool getactivewindow getwindowname);
  while [ "$result" != "New Tab - Google Chrome" ]; do #espera a que cargue
    sleep 0.1;
    #echo $result;
    result=$(xdotool getactivewindow getwindowname);
  done
  # +++++++++++++++++++ Introducir url +++++++++++++++++++
  printf "https://kahoot.it/" $url | xclip -i -selection clipboard; #copiar el url al portapapeles
  for (( i = 0; i < $k; i++ )); do
    press4me "ctrl+v"; #pega el url en el navegador
    sleep 0.1;
    xdotool key KP_Enter; #press enter;
    sleep $delay;
    press4me "ctrl+t"; #nueva pestaña
    sleep 0.1;
  done
  tab; # ve al terminal
  ask "Introduce el kahootId" "(número)";
  kahootId=$askResponse;#guardar kahootid
  tab 1; #ir al navegador
  # +++++++++++++++++++ Introducir id +++++++++++++++++++
  for (( i = 0; i < $k; i++ )); do
    press4me "ctrl+Tab";
    result=$(xdotool search --name Game); # Esperar hasta que esté cargado
    while [ "$result" = "" ]; do
      sleep 2;
      result=$(xdotool search --name Game);
    done
    sleep 1;
    press4me "Tab"; #presiona la tecla Tab para hacer focus en el textbox
    sleep 0.5;
    printf "$kahootId" $url | xclip -i -selection clipboard; # copiar id
    press4me "ctrl+v"; #pegar id
    sleep 0.1;
    xdotool key KP_Enter; #presiona enter
  done
  press4me "ctrl+Tab";#va a la que está en blanco
  tab; # ir al terminal
  ask "Enter nombre" "(pato-> pato1, pato2...)";
  nick=$askResponse; #guardar nombre
  tab 1; # ir al navegador
  # +++++++++++++++++++ Introducir nombre +++++++++++++++++++
  for (( i = 1; i < $k + 1; i++ )); do
    press4me "ctrl+Tab"; # ir a la pestaña 
    sleep 3;
    press4me "Tab"; # focus en el textbox
    sleep 0.5;
    printf "$nick$i" $url | xclip -i -selection clipboard; #copiar nombre
    press4me "ctrl+v"; # pegar nombre
    sleep 0.1;
    xdotool key KP_Enter;  # presionar enter
  done
  xdotool key --clearmodifiers "ctrl+Tab"; #ir a la vacía
  printf "Terminado, disfruta :D" $url | xclip -i -selection clipboard; #copiar el texto de que ya está listo
  xdotool key --clearmodifiers "ctrl+v"; #pegar
  echo "autoSetup terminado"; #también en terminal
  sleep 2;
  xdotool key --clearmodifiers "ctrl+w"; #borra la pestaña en blanco
}

preLunchFv2(){
  while true; do
    printf "${YELLOW}\nAjuste actual:${NC}\nModo: $mode, nº de cuentas: $k, delay: $delay\s, autoSetup: $autoSetup\n";
    ask 'Empezamos?' '[yes/setup/help]';

    case $askResponse in
      h|help|H|HELP)
        clear;
        helpText;
      ;;

      y|start|yes|Y|START)
        printf "${GREEN}Disfrute :D${NC}\nPara cerrar el script, presione ${RED}ctrl+C${NC}";
        if [ "$autoSetup" = "true" ]; then
          autoSetupFv2;
        fi
        loop;
      ;;
      s|setup|S|SETUP)
        setup;
      ;;
      *)
        echo "commando no encontrado";
      ;;
      esac
  done
}

setup(){ #menu para cambiar los parámetros
  miniLoop=$true; # para controlar el loop
  while $miniLoop; do
    clear;
    echo -e "${YELLOW}Ajustes:${NC} \nModo: $mode, nº de cuentas: $k, delay: $delay s, autoSetup: $autoSetup";
    if [ "$mode" != "autoclick" ]; then #if autoclick on-> menu diferente
      echo "[modo/autoSetup (auto)/salir(c, done, exit)]";
    else
      echo "[modo/nº de cuentas (n, number)/delay/autoSetup (auto)/salir(c, done, exit)]";
    fi;
    ask "Qué elemento quieres cambiar?";
    case $askResponse in #haz la respuesta
      m|mode)
        ask "Modo?" "(autoclick/normal)";
        case $askResponse in
          auto*)#encuentra auto, autoclick...
            mode="autoclick";
          ;;
          *)
            mode="normal";
          ;;
        esac
      ;;
      n|number)
        ask "nº cuentas" "(integer)";
        k=$askResponse;
      ;;
      d|delay)
        ask "Tiempo delay (in seconds, \".\" format)";
        delay=$askResponse;
      ;;
      auto)
        ask "autoSetup" "(y/n)";
        if [ "$askResponse" = "y" ]; then
          autoSetup="true";
        else
          autoSetup="false";
        fi
      ;;
      c|exit|done) #si salir
        miniLoop=false;# ahora, este loop termina
        clear;
        echo "Setup terminado";
      ;;
    esac
  done;
}



helpText(){ # cuando se pida ayuda, mostrar esto
  echo -e "${YELLOW}Ayuda:${NC}\n
- ${LBLUE}Autoclick${NC} Hará la acción de clicar e ir a la siguiente pestaña de la ventana.
- ${LBLUE}Normal${NC} Sólo irá a la siguiente pestaña, por tanto puedes elegir la opción manualmente.
- ${LBLUE}AutoSetup${NC}: Este modo hace el montaje del navegador automáticamente.

${LRED}Posibles errores${NC}:\n
  - ${RED}Error abriendo el navegador:${NC} debes poner la dirección
    del executable (cambiar vars \"dir\" y \"execu\").
    Por defecto, intentará \"/opt/google/chrome\" y el 
    ejecutable \"chrome\".
    Recuerda que si usas un navegador diferente, puede no
    funcionar (el script usa los atajos del teclado que pueden
    no ser iguales para todos los navegadores).\n
  - ${RED}El autoSetup va muy rápido:${NC} El tiempo requerrido puede variar
    entre dispositivos, use tiempos suficientes para arreglar esto.\n
  - ${RED}El ratón no responde:${NC} en un terminal,
    escribir ${GREEN}xinput --list${NC} y elegir su input (Touchpad,
    USB Receiver...).\n
  - ${RED}El texto de la enterfaz no cabe bien en terminal:${NC} este programa está pensado
    para un terminal 80x43 (2º nodo en Ubuntu 18.04 terminal).\n
  - ${RED}Xdotool no instalado:${NC} este script usa xdotool para controlar el
    dispositivo. Por favor, intalar antes de su uso.";
}
# ---------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------
clear;
printf "${LGREEN}********* Kahoot script *********${NC}\n\n- Este programa fué creado por motivos educativos, el\nautor no es responsable del uso que se dé a este programa.\nSi es la primera vez ejecutando el programa, ver ${YELLOW}ayuda${NC}.\nEste projecto es open source.\n";
preLunchFv2;
#~~~~~~~~ Debug ~~~~~~~~
#while true; do
#  read -p "do?" result;
#  $result;
#done
