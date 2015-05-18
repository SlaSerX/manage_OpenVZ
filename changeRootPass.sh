#!/usr/bin/env bash
#
# Author: Aman Hanjrah
# Date: 30 Mar 2015
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
		userPass
	fi
}

userPass() {
  echo -e "${BGre}Enter the new password${RCol}"
	read -e userPassInput
  if [[ -z "$userPassInput" ]]; then
		echo -e "${BRed}This cannot be empty, try again${RCol}"
    userPass
  else
    changePass
	fi
}
changePass() {
  stopCtid
  vzctl set "$userCtid" --userpasswd root:"$userPassInput" >> /dev/null 2<&1
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
# End
