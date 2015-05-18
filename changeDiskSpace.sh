#!/usr/bin/env bash
#
# Author: Aman Hanjrah
# Date: 25 Mar, 2015
# License: GPLv2
#
# Start
main() {
  . ./vars.sh
	vzlist -a
	listFile=$(mktemp)
	chkCtid
}

# This function lists current container's unique CTID and takes the user input
chkCtid() {
	LIST=$(vzlist -a | cut -d' ' -f8 | grep -v '^$' > "$listFile")
	echo -e "${BGre}Enter the CTID for which you want to change Disk space for:${RCol}"
	read -e userCtid
	if [[ -z "$userCtid" ]]; then #check if user input is empty
		echo -e "${BRed}This cannot be empty, try again${RCol}"
		chkCtid
	fi
	grep -w "$userCtid" "$listFile" >> /dev/null #check if user provided a unique CTID which does not exist previously
	if [[ $? -ne 0 ]]; then
		echo -e "${BRed}CTID that you have mentioned, does not exist, try again:${RCol}"
		chkCtid
	else
		chkDisk
	fi
}

# This function takes user input for soft limit of Disk Space
chkDisk() {
	echo -e "${BGre}How much Disk space you want to allocate to container with ID: "$userCtid"?${RCol}"
	echo -e "${BGre}Examples:${RCol}"
	echo -e "${BGre}a) 10${RCol}"
	echo -e "${BGre}b) 512${RCol}"
	chkSoftLimit
}

# This function takes user input for soft limit of Disk Space
chkSoftLimit() {
	echo -e "${BCya}All the values must be in GB's.${RCol}"
	echo -e "-------------------------"
  echo -e "${BGre}Enter the ${BRed}soft${RCol} limit:${RCol}"
  echo -e "-------------------------"
  read -e userSoftLimit
  if [[ -z "$userSoftLimit" ]]; then
		echo -e "${BRed}This cannot be empty, try again${RCol}"
		chkSoftLimit
	elif	[[ ! "$userSoftLimit" =~ ^[-+]?[0-9]+$ ]]; then  # Make sure user input is integer only
		echo -e "${BRed}Only integers are accepted. Try again${RCol}"
    chkSoftLimit  # Ask input again if above check fails
	else
		chkHardLimit
  fi
}

# This function takes user input for hard limit of Disk Space
chkHardLimit() {
	echo -e "-------------------------"
  echo -e "${BGre}Enter the ${BRed}hard${RCol} limit:${RCol}"
  echo -e "-------------------------"
  read -e userHardLimit
  if [[ -z "$userHardLimit" ]]; then
		echo -e "${BRed}This cannot be empty, try again${RCol}"
		chkHardLimit
	elif	[[ ! "$userHardLimit" =~ ^[-+]?[0-9]+$ ]]; then  # Make sure user input is integer only
		echo -e "${BRed}Only integers are accepted. Try again${RCol}"
    chkHardLimit  # Ask input again if above check fails
  else
    changeDisk
  fi
}

# This function makes the changes
changeDisk() {
  stopCtid
  vzctl set "$userCtid" --diskspace "${userSoftLimit}"G:"${userHardLimit}"G --save >> /dev/null 2<&1
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
# End
