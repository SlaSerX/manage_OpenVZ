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
		takeUserInput
	fi
}

takeUserInput() {
  echo -e "${BGre}How many CPU cores you want to assign to $userCtid?${RCol}"
  read -p userCores
  if ! [[ "$userCores" =~ ^[0-9]+$ ]]; then #if the value is anything except integers, code exits with an error
    echo -e "${BRed}Invalid value, only integers are accepted, try again${RCol}"
    takeUserInput
  else
    compareCores
  fi
}

compareCores() {
  # check number of current CPU cores
  coresNumber="$(nproc)"
  if [[ "$userCores" -ge "$coresNumber" ]]; then #compare number of cores provided by user and available cores
    echo -e "${BRed}You cannot assign more CPU cores to a comtainer than available, try again${RCol}"
    takeUserInput
  else
    changeCores
  fi
}

changeCores() {
  stopCtid
  vzctl set "$userCtid" --cpus "$userCores" --save >> /dev/null 2<&1
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
