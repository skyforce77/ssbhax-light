#!/bin/bash
# Script développé par @Skyforce77

function show_help {
  echo "Vous devez préciser votre intention:"
  echo " - $0 install"
  echo " - $0 start [interface]"
}

function install_hax {
  if [ -e "hax.lck" ]
  then
    echo "Le hack est déjà installé"
  else
    git clone https://github.com/yellows8/3ds_smashbroshax.git
    git clone https://github.com/yellows8/ctr-wlanbeacontool.git
    wget https://github.com/aircrack-ng/aircrack-ng/archive/1.2-rc2.tar.gz
    gunzip 1.2-rc2.tar.gz
    tar xvf 1.2-rc2.tar
    rm 1.2-rc2.tar
    patch aircrack-ng-1.2-rc2/src/aireplay-ng.c < 3ds_smashbroshax/aireplay-ng.patch
    cd aircrack-ng-1.2-rc2
    make
    cd ../ctr-wlanbeacontool
    make
    cd ../3ds_smashbroshax
    make PAYLOADPATH=/smashpayload.bin
    cd ..
    touch hax.lck
    echo ""
    echo "Installation terminée. Vous pouvez maintenant lancer le hack"
  fi
}

function start_hax {
  wlan_if="wlan0"

  echo "Vos interfaces réseaux:"
  count=0
  interfaces=`ls /sys/class/net`
  interfaces_arr=($interfaces)
  for if in $interfaces
  do
    echo " $count - $if"
    count=$((count+1))
  done
  echo "Entrez le numéro correspondant à votre émetteur wifi (souvent wlan0 ou wlp4s0):"
  read choice

  wlan_if=${interfaces_arr[$choice]}

  echo "Vous avez choisi l'interface: $wlan_if"
  echo ""

  echo "Regions de 3ds:"
  echo " 0 - Pal/Eur/Jap"
  echo " 1 - Usa"
  echo "Entrez le numéro correspondant à votre 3ds (0 pour une 3ds française):"
  read choice

  case $choice in
  "1")
    region="gameusa"
    ;;
  *)
    region="gameother"
    ;;
  esac

  echo "Vous avez choisi la région: $region"
  echo ""

  echo "Entrez votre version de Super Smash Bros (visible sur l'écran principal):"
  read choice
  version=`echo "$choice" | tr -d .`

  echo "Vous avez choisi la version: $version"
  echo ""

  sudo ifconfig $wlan_if down
  sudo iwconfig $wlan_if mode monitor
  sudo ifconfig $wlan_if up
  sudo iwconfig $wlan_if channel 6

  file="3ds_smashbroshax/pcap_out/smashbros_"$region"v"$version"_beaconhax.pcap"
  if [ -e $file ]
  then
    sudo aircrack-ng-1.2-rc2/src/aireplay-ng --interactive -r $file -h 59:ee:3f:2a:37:e0 -x 10 $wlan_if
  else
    echo "Malheureusement, cette configuration n'est pas compatible"
  fi
}

case $1 in
"install")
  install_hax
  ;;
"start")
  start_hax
  ;;
*)
  show_help
  ;;
esac
