#!/usr/bin/env bash
#
# Author: Aman Hanjrah
# Date: 24 Mar, 2015
# License: GPLv2
#
# Start
main() {
	. ./vars.sh
	vzlist -a
	listFile=$(mktemp)
	chkCtid
	rmJunk
}

# This function lists current container's unique CTID and takes the user input
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
		chkRam
	fi
}

# This function takes user input for RAM
chkRam() {
	echo -e "${BGre}How much RAM you want to allocate to $userCtid container?${RCol}"
	echo -e "${BGre}Examples:${RCol}"
	echo -e "${BGre}a) 10${RCol}"
	echo -e "${BGre}b) 512${RCol}"
	echo -e "${BCya}All the values must be in MB's.${RCol}"
	read -e userRam
	if [[ -z "$userRam" ]]; then
		echo -e "${BRed}This cannot be empty, try again${RCol}"
# If the above check fails, user will be prompted again
		chkRam
	elif	[[ ! "$userRam" =~ ^[-+]?[0-9]+$ ]]; then
		echo -e "${BRed}Only integers are accepted. Try again${RCol}"
		chkRam
	else
		chkSwap
	fi
}

# This function takes user input for SWAP
chkSwap() {
	echo -e "${BGre}How much SWAP you want to allocate to $userCtid container?${RCol}"
	echo -e "${BGre}Examples:${RCol}"
	echo -e "${BGre}a) 1024${RCol}"
	echo -e "${BGre}b) 512${RCol}"
	echo -e "${BCya}All the values must be in MB's.${RCol}"
	read -e userSwap
	if [[ -z "$userSwap" ]]; then
		echo -e "${BRed}This cannot be empty, try again${RCol}"
# If the above check fails, user will be prompted again
		chkSwap
	elif	[[ ! "$userSwap" =~ ^[-+]?[0-9]+$ ]]; then
		echo -e "${BRed}Only integers are accepted. Try again${RCol}"
		chkSwap
	else
		changeRam
	fi
}

# This function make the entry in corresponding file and save it
changeRam() {
	stopCtid
	vzctl set "$userCtid" --ram "${userRam}M" --swap "${userSwap}M" --save >> /dev/null 2<&1
	if [[ $? = 0 ]]; then
    startCtid
    echo -e "${BGre}Successful!${RCol}"
    sleep 3
# Return to main menu
    sh master.sh
    exit $?
  else
    echo -e "${BRed}Oh boy! something went wrong!\nExiting!${RCol}"
    sleep 3
    exit $?
  fi
}

main
#End
