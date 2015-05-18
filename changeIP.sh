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
		chkIP
	fi
}

chkIP() {
  echo -e "${BGre}Provide a valid IP address:${RCol}"
  read -e userIP
  if echo "$userIP" | egrep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' >> /dev/null 2<&1 #check if IP provided by user is in X.X.X.X format and no alphabets are there
    then
    validIP="$(echo $userIP | awk -F'.' '$1 <=254 && $2 <= 254 && $3 <= 254 && $4 <= 254')" >> /dev/null 2<&1 #check if the value of each octect is between 0-254, if not, error is shown
    if [ -z "$validIP" ]; then
        echo -e "${BRed}Invalid IP address, octets must be less than 255. Try again${RCol}"
        sleep 2
        chkIP
    else
        changeIP
    fi
else
    echo -e "${BRed}Invalid IP address, try again!${RCol}"
    sleep 2
    chkIP
fi
}

changeIP() {
  stopCtid
  vzctl set "$userCtid" --ipdel all --save >> /dev/null 2<&1
  vzctl set "$userCtid" --ipadd "$userIP" --save >> /dev/null 2<&1
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
