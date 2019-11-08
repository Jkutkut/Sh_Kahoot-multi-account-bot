#!/bin/bash
dir="/opt/google/chrome";
execu="chrome";
delay=0.02;
k=3;
mode="autoclick"; #autoclick or manual
autoSetup="true";
kahootId="";
nick="";
askResponse="";
#colors:
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
# ----------------------------------------- FUNCTIONS -----------------------------------------
#++++++ Small function ++++++
ask(){ # to do the read in terminal, save the response in askResponse
  text=$1;
  textEnd=$2;
  read -p "$(echo -e ${LBLUE}"$text"${NC} $textEnd)->" askResponse;
}

tab(){ #to switch between terminal and browser;
  press4me "alt+Tab";
  sleep 0.1;
  xdotool keyup "alt";
  xdotool keyup "Tab";
  sleep 1;
  if (( 1$1 == 11 )); then #if 1º argument == 1 ()
    xdotool key KP_Enter; #enter key
    sleep 1;
  fi
}

press4me(){ #to use the keyboard
  xdotool key --clearmodifiers "$1";
}

clicker(){
  for (( i=1; i <= $1; ++i )); do # $1 -> number of times to click and tab (1º argument).
    xdotool click 1;
    sleep $delay;
    press4me "ctrl+Tab";
    sleep $delay;
  done;
}


#loop: do the clicks and the change between windows
loop(){
  while true; do
    sleep $delay;
    STATE2=$(xinput --query-state $MOUSE_ID | grep 'button\[' | sort);#save state of the mouse
    if test "$STATE1" != "$STATE2"; then #if click update
      if $click; then
        click=false;#the mouse updates 2 times per click (OFF->ON, ON->OFF), we only do it once (boolean)
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
  printf "\nAutoSetup is now on, please wait\nStart in ";
  for (( i = 3; i >= 0; i-- )); do
    printf "$i, ";
    sleep 0.5;
  done
  printf "  ${LBLUE}GO${NC}\n";
  cd $dir; #go to the executable dir
  ./$execu >/dev/null 2>&1 & #Execute the executable.This way, we dont see browser's errors on terminal
  sleep 8;
  result=$(xdotool getactivewindow getwindowname);
  while [ "$result" != "New Tab - Google Chrome" ]; do #wait until loaded
    sleep 0.1;
    #echo $result;
    result=$(xdotool getactivewindow getwindowname);
  done
  # +++++++++++++++++++ Enter url +++++++++++++++++++
  printf "https://kahoot.it/" $url | xclip -i -selection clipboard; #copy url to clipboard
  for (( i = 0; i < $k; i++ )); do
    press4me "ctrl+v"; #paste url in browser
    sleep 0.1;
    xdotool key KP_Enter; #press enter;
    sleep $delay;
    press4me "ctrl+t"; #New tab
    sleep 0.1;
  done
  tab; # go to terminal
  ask "Enter kahootId" "(integer)";
  kahootId=$askResponse;#save kahoot's id
  tab 1; #go to browser
  # +++++++++++++++++++ Enter id +++++++++++++++++++
  for (( i = 0; i < $k; i++ )); do
    press4me "ctrl+Tab";
    result=$(xdotool search --name Game); # wait until loaded
    while [ "$result" = "" ]; do
      sleep 2;
      result=$(xdotool search --name Game);
    done
    sleep 1;
    press4me "Tab"; #press the Tab to focus the text input zone
    sleep 0.5;
    printf "$kahootId" $url | xclip -i -selection clipboard; # copy id
    press4me "ctrl+v"; #paste id
    sleep 0.1;
    xdotool key KP_Enter; #press enter
  done
  press4me "ctrl+Tab";#go to the blank one
  tab; # go to terminal
  ask "Enter nick" "(duck-> duck1, duck2...)";
  nick=$askResponse; #save nick
  tab 1; # go to browser
  # +++++++++++++++++++ Enter nick +++++++++++++++++++
  for (( i = 1; i < $k + 1; i++ )); do
    press4me "ctrl+Tab"; # go to the tab
    sleep 3;
    press4me "Tab"; # focus input zone
    sleep 0.5;
    printf "$nick$i" $url | xclip -i -selection clipboard; #copy nick
    press4me "ctrl+v"; # paste nick
    sleep 0.1;
    xdotool key KP_Enter;  #enter key
  done
  xdotool key --clearmodifiers "ctrl+Tab"; #go to the blank
  printf "done, enjoy :D" $url | xclip -i -selection clipboard; #copy text to say it's done
  xdotool key --clearmodifiers "ctrl+v"; #paste
  echo "autoSetup done"; #also in terminal
  sleep 2;
  xdotool key --clearmodifiers "ctrl+w"; #delete blank tab
}

preLunchFv2(){
  while true; do
    printf "${YELLOW}\nCurrent settings:${NC}\nMode: $mode, kahoot acounts: $k, delay: $delay\s, autoSetup: $autoSetup\n";
    ask 'Ready to start?' '[yes/setup/help]';

    case $askResponse in
      h|help|H|HELP)
        clear;
        helpText;
      ;;

      y|start|yes|Y|START)
        printf "${GREEN}Enjoy :D${NC}\nTo close the program, press ${RED}ctrl+C${NC}";
        if [ "$autoSetup" = "true" ]; then
          autoSetupFv2;
        fi
        loop;
      ;;
      s|setup|S|SETUP)
        setup;
      ;;
      *)
        echo "command not found";
      ;;
      esac
  done
}

setup(){ #menu to change the parameters
  miniLoop=$true; #to control the setup loop
  while $miniLoop; do
    clear;
    echo -e "${YELLOW}Settings:${NC} \nMode: $mode, kahoot acounts: $k, delay: $delay s, autoSetup: $autoSetup";
    if [ "$mode" != "autoclick" ]; then #if autoclick on-> diferent menu
      echo "[mode/autoSetup (auto)/exit(c, done, exit)]";
    else
      echo "[mode/number of acounts (n, number)/delay/autoSetup (auto)/exit(c, done, exit)]";
    fi;
    ask "Which element do you want to change?";
    case $askResponse in #do the response
      m|mode)
        ask "Mode?" "(autoclick/normal)";
        case $askResponse in
          auto*)#matches auto, autoclick...
            mode="autoclick";
          ;;
          *)
            mode="normal";
          ;;
        esac
      ;;
      n|number)
        ask "Kahoot acounts" "(integer)";
        k=$askResponse;
      ;;
      d|delay)
        ask "Delay time (in seconds, \".\" format)";
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
      c|exit|done) #if exit
        miniLoop=false;#now, loop will end
        clear;
        echo "Setup done";
      ;;
    esac
  done;
}



helpText(){ #when asked for help, show it
  echo -e "${YELLOW}Help:${NC}\n
- ${LBLUE}Autoclick${NC} will do the click action and go to the next tab in the window.
- ${LBLUE}Normal${NC} will only tab to the next, so you can choose the option you want.
- ${LBLUE}AutoSetup${NC}: this mode made the setup of the browser automatically

${LRED}Possible errors${NC}:\n
  - ${RED}Error opening the browser:${NC} you must put the location of the
    executable (change vars \"dir\" and \"execu\").
    By default, it will try the \"/opt/google/chrome\" and the
    executable \"chrome\".
    Remember that if you use a diferent browser, it might not
    work (the script uses keyboard shortcuts that might not be
    equal in all browsers).\n
  - ${RED}The autoSetup goes too fast:${NC} the time required might differ
    between devices, please use enough time in order to solve this.\n
  - ${RED}The mouse does not response:${NC} in a terminal,
    type ${GREEN}xinput --list${NC} and choose your input (Touchpad,
    USB Receiver...).\n
  - ${RED}The text here doesn\'t fit correctly:${NC} this program was made for a
    80x43 terminal (2º mode in Ubuntu 18.04\'s terminal).\n
  - ${RED}Xdotool not installed:${NC} this program uses xdotool in order to control the
    device. prease install it.";
}
# ---------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------
clear;
printf "${LGREEN}********* Kahoot script *********${NC}\n\n- This program was made for educational purposes only, the\nauthor is not responsible for the use of this software.\nIf it's your 1º time using this program, please read the ${YELLOW}help${NC}.\nThis is an open source file.\n";
preLunchFv2;
#~~~~~~~~ Debug ~~~~~~~~
#while true; do
#  read -p "do?" result;
#  $result;
#done
