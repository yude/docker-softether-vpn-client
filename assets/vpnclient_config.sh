#!/bin/sh
set -e

while true
do
  printf "READY\n"

  while read line
  do
    printf "$line" 1>&2
    
    # rebuild profile from scratch
    rm -f /usr/vpnclient/vpn_client.config
    
    # skip adapter creation if exists
    if grep -q vpn_${SE_NICNAME} /proc/net/dev; then 
      printf "NIC ${SE_NICNAME} already exists, skipping creation" 1>&2
    else
      vpncmd localhost /CLIENT /CMD NicCreate ${SE_NICNAME} 1>&2
    fi
      
    # create account
    vpncmd localhost /CLIENT /CMD AccountCreate ${SE_ACCOUNT_NAME} /SERVER:${SE_SERVER} /HUB:${SE_HUB} /USERNAME:${SE_USERNAME} /NICNAME:${SE_NICNAME} 1>&2
    # set account password
    vpncmd localhost /CLIENT /CMD AccountPasswordSet ${SE_ACCOUNT_NAME} /PASSWORD:${SE_PASSWORD} /TYPE:${SE_TYPE} 1>&2
    # initiate connection
    vpncmd localhost /CLIENT /CMD AccountConnect ${SE_ACCOUNT_NAME} 1>&2

    # acquire IP address
    dhclient -q 1>&2

    # log acquired IP address
    printf "VPN adapter IPv4 address: $(/sbin/ifconfig vpn_${SE_NICNAME} | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')\n" 1>&2
    
    printf "RESULT 2\nOK"
    
    printf "Configuration done\n" 1>&2
  done
done
