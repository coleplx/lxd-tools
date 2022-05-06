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
1) 
2) Miscellaneous
0) Exit
Choose an option:  "
    read -r ans
    case $ans in
    1)
        mysql_menu
        mainmenu
        ;;
    2)
        miscellaneous
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

# Miscellaneous menu
miscellaneous() {
    echo -ne "
    $(green 'Miscellaneous')
1) Memory Usage per Common Process
2) Go Back to Main Menu
0) Exit
Choose an option:  "
    read -r ans
    case $ans in
    1)
        memory_usage
        goback
        ;;
    2)
        mainmenu
        ;;
    0)
        quit
        ;;
    *)
        fail
	miscellaneous
        ;;
    esac
}

## MySQL menu
mysql_menu() {
    echo -ne "
    $(green 'MySQL Options')
1) Logsize fix
2) MySQL Check
3) DB Usage
4) Transients
5) Processes
6) Export DB or single table
7) Show misc information
8) Check DB Optimization Level
9) Back to Main Menu
0) Exit
Choose an option:  "
    read -r ans
    case $ans in
    1)
        logsize_fix
        goback
        ;;   
    2)
        mysqlchecking
        goback
        ;;
    3)
        db_usage_stats
        goback
        ;;
    4)
        my_transients
        goback
        ;;
    5)
        my_processes
        goback
        ;;
    6)
        export_dbtable
        goback
        ;;
    7)
        misc
        goback
        ;;
    8)
        optimization
        goback
        ;;
    9)
        mainmenu
        ;;
    0)
        quit
        ;;
    *)
        fail
	mysql_menu
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

## Run the menu
mainmenu
