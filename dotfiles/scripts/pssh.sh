#!/bin/bash

INPUT=~/.servers.csv
OLDIFS=$IFS
IFS=","
max=$(wc -l < "$INPUT")
_type=""

displayCmd() {
  echo "Choose one command among this"
  OLDIFS=$IFS
  IFS=","
  i=1;
  display=false
  printf "%-2s %-20s %-10s %-17s %-17s\n" N Name ShortCut Note
  while read type name shortcut cmd note
  do
    #printf "$name \nShortCut : $serverhortcut\nHostname : $hostname\n\n"
    if [ "$type" == "$_type" ] || [ -z "$_type" ] ; then
      display=true
      printf "\e[1;43m%-2d\e[0m %-20s %-10s %-17s %-17s\n" $i $name $shortcut $note
    fi
    i=$[$i+1]
  done < $INPUT

  # Si on a rien afficher, on réaffiche tout
  if [ $display = false ] ; then
      printf "Aucune ligne trouvé pour $_type\n\n"
      _type=""
      displayCmd
  fi

  IFS=$OLDIFS
  printf "\n==> Please enter the number of server you want to connect, (enter to continue)\n"
  printf "==> ----------------------------------------\n"
  printf "==> "
  read -r num
  printf "\n"
  if [ -z $num ] ; then
	exit
  else
	tryConnect $num
  fi
  exit
}

tryConnect() {
  re='^[0-9]+$'

  if [[ ${#1} -eq 0 ]]; then 
    displayCmd
  fi

  # is a number
  if [[ $1 =~ $re ]]; then
    # le nb specifier est incohérent par rapport au nb de lignes
    if [[ "$1" -gt "$max" ]] || [[ -z "$1" ]]; then
      printf "You have specify an unknow server, try again : \n"
      printf "==> "
      displayCmd
      exit
    fi  

    lineNumber=$(sed "$1"'q;d' $INPUT)
    IFS=',' read type name shortcut cmd note <<< "$lineNumber"
    
    echo "Found, cmd will start
    
    $cmd
    "
    # execute la commande
    bash -c "$cmd"
    exit
  else
    lineNumber=$(cat $INPUT | cut -d ',' -f3 | grep -n "^$1$" | cut -f1 -d:)
    
    # pas vide
    if [ -n "$lineNumber" ]; then
      tryConnect $lineNumber
      exit
    else
      echo "Not found"
      displayCmd    
    fi
  fi
}

TEMP=`getopt -o lt:m: --long list,type:,memory:,debugfile:,minheap:,maxheap: -n 'parse-options  ' -- "$@"`
USAGE="Usage: $0 short"

if [ "$#" -gt 2 ] ; then echo "$USAGE"; exit 1; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true; do
  case "$1" in
    -l | --list )
        cut -d',' -f3 $INPUT | sort | uniq | tr '\n' ' '
        exit
        shift ;;
    -t | --type ) 
        _type=$2
        displayCmd 
        shift;shift ;;
    -m | --memory )
        echo memory 
        shift ;;
    -- )
        tryConnect $2
        # echo default
        exit 2;
        break ;;
    * ) 
        echo nothing 
        exit
        break ;;
  esac
done

