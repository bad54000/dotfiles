#!/bin/bash

EXCLUDE_LIST="rootfs"
ALERT_WARN=75
ALERT_CRIT=90
ADMIN="danyb@perfscript.fr"


function format_sendmail(){
   
   i=0
   df -h > /tmp/df
   while read output; do
         if [[ $i -ne 0 ]]; then
            usep=$(echo $output | awk '{ print $5}' | sed 's/.$//')
            part=$(echo $output | awk '{ print $6}' )
            if (( $(echo $usep | awk '{ print ($1 > '$ALERT_CRIT')}') )); then
               mail -s "$HOSTNAME CRITICAL DISK SPACE: Almost out of disk space $usep% on $part" $ADMIN < /tmp/df
            elif (( $(echo $usep | awk '{ print ($1 > '$ALERT_WARN')}') )); then
               mail -s "$HOSTNAME WARNING DISK SPACE: Almost out of disk space $usep% on $part" $ADMIN < /tmp/df
            fi
         fi
         i=$(($i + 1)) 
      done   
}
df -h
if [ "$EXCLUDE_LIST" != "" ] ; then
   df -h | grep -v "^tmpfs|${EXCLUDE_LIST}" | format_sendmail
else
   df -h | grep -v "^tmpfs" | format_sendmail
fi
