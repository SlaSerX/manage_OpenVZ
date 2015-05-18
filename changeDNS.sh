#!/usr/bin/env bash
#
# Author: Aman Hanjrah
# Date: 27 Mar 2015
# License: GPLv2.0
#
# Start
main() {
	. ./vars.sh
	vzlist -a
  listFile=$(mktemp)
	chkCtid
  rmJunk
}

chkCtid() {
	LIST=$(vzlist -a | cut -d' ' -f8 | grep -v '^$' > "$listFile")
	echo -e "${BGre}Enter the CTID for which you want to change Disk space for:${RCol}"
	read -e userCtid
	if [[ -z "$userCtid" ]]; then
		echo -e "${BRed}This cannot be empty, try again${RCol}"
		chkCtid
	fi
	grep -w "$userCtid" "$listFile" >> /dev/null
	if [[ $? -ne 0 ]]; then
		echo -e "${BRed}CTID that you have mentioned, does not exist, try again:${RCol}"
		chkCtid
	else
		chkDNS
	fi
}

chkDNS() {
  echo -e "${BGre}Provide a valid nameserver address:${RCol}"
  read -e userDNS
  if echo "$userDNS" | egrep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' >> /dev/null 2<&1 #check if IP provided by user is in X.X.X.X format and no alphabets are there
    then
    validDNS="$(echo $userDNS | awk -F'.' '$1 <=254 && $2 <= 254 && $3 <= 254 && $4 <= 254')" >> /dev/null 2<&1 #check if the value of each octect is between 0-254, if not, error is shown
    if [ -z "$validDNS" ]
    then
        echo -e "${BRed}Invalid DNS address, octets must be less than 255. Try again${RCol}"
        sleep 2
        chkDNS
    else
        changeDNS
    fi
else
    echo -e "${BRed}Invalid DNS address, try again!${RCol}"
    sleep 2
    chkDNS
fi
}

changeDNS() {
  stopCtid
  vzctl set "$userCtid" --nameserver "$userDNS" --save >> /dev/null 2<&1
  if [[ $? = 0 ]]; then
    startCtid
    echo -e "${BGre}Successful!${RCol}"
    sleep 3
    sh master.sh
    exit $?
  else
    echo -e "${BRed}Oh boy! something went wrong!\nExiting!${RCol}"
    sleep 3
    exit $?
  fi
}

main
