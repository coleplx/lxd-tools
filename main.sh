#!/bin/bash

## Included functions
source ./functions/lxdmem.sh
source ./functions/lxcmigration.sh
source ./functions/lxddt.sh
source ./functions/beta_cycling.sh

## Colors
ESC=$(printf '\033') RESET="${ESC}[0m" RED="${ESC}[31m" GREEN="${ESC}[32m" 

## Menu functions
green() { printf "${GREEN}%s${RESET}\n" "$1"; }
quit() { printf "Bye bye!\n"; exit 0; }
fail() { printf "\n${RED}%s${RESET}\n" "Wrong option. Please choose one of the listed options"; }

## Main menu
mainmenu() {
    echo -ne "
    $(green 'Main Menu')
1) Check LXD system health
2) Identify migration candidates
3) Get downtime statistics
4) Cycle staging instances 
0) Quit
Choose an option:  "
    read -r ans
    case $ans in
    1)
        lxdmem
        goback
        ;;
    2)
        lxcmigration
        goback
        ;;        
    3)
        #lxddt
        lxddt
        goback
        ;;
    4)  
        beta_cycling
        goback
        ;;
    0)
        quit
        ;;
    *)
        fail
	mainmenu
        ;;
    esac
}

## Go Back menu
goback() {
    echo -ne "
1) Go Back to Main Menu
0) Exit
Choose an option:  "
    read -r ans
    case $ans in
    1)
        mainmenu
        ;;
    0)
        quit
        ;;
    *)
        fail
        goback
        ;;
    esac
}

## Check for interactive vs non-interactive
if [ -z "$1" ]; then
  mainmenu
elif [ "$1" = "--lxdmem" ]; then
  lxdmem
elif [ "$1" = "--lxcmigration" ]; then
  lxcmigration ${@:2}
elif [ "$1" = "--lxddt" ]; then
  lxddt
elif [ "$1" = "--cycling" ]; then
  beta_cycling
elif [[ "$1" == "--lxc" ]] && [[ "$2" == "--list" ]]; then
  source ./functions/lxc_commands.sh
  lxc_list_running
elif [[ "$1" == "--lxc" ]] && [[ "$2" == "--memory" ]]; then
  source ./functions/lxc_commands.sh
  for container in $(lxc_list_running); do container_mem_usage $container; done
elif [[ "$1" == "--lxc" ]] && [[ "$2" == "--exec" ]]; then
  source ./functions/lxc_commands.sh
  lxcexec ${@:3}
else
  echo -ne "
Please choose a valid option:
--lxdmem          Check LXD system health
--lxcmigration    Identify migration candidates
  --size=X (opt)  Container size limit in GiB
  --show=Y (opt)  Number of candidates to show
--lxddt           Get downtime statistics
--cycling         Cycle staging instances 
"
fi
