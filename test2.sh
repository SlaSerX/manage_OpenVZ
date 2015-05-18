ChkDisk() {
	echo "${BGre}How much Disk space you want to allocate to container with ID: "$userCtid"?${RCol}"
	echo "${BGre}Examples:${RCol}"
	echo "${BGre}a) 10${RCol}"
	echo "${BGre}b) 512${RCol}"
	echo "${BCya}All the values must be in GB's.${RCol}"
	echo -e "-------------------------"
  echo -e "${BGre}Enter the ${BRed}soft${RCol} limit:${RCol}"
  echo -e "-------------------------"
  read -e userSoftLimit
  if [[ -z "$userSoftLimit" ]]; then
		echo -e "${BRed}This cannot be empty, try again${RCol}"
		chkDisk
	elif	[[ ! "$userSoftLimit" =~ ^[-+]?[0-9]+$ ]]; then
		echo "${BRed}Only integers are accepted. Try again${RCol}"
    chkDisk
  fi
  echo -e "-------------------------"
  echo -e "${BGre}Enter the ${BRed}hard${RCol} limit:${RCol}"
  echo -e "-------------------------"
  read -e userHardLimit
  if [[ -z "$userHardLimit" ]]; then
		echo -e "${BRed}This cannot be empty, try again${RCol}"
		chkDisk
	elif	[[ ! "$userHardLimit" =~ ^[-+]?[0-9]+$ ]]; then
		echo "${BRed}Only integers are accepted. Try again${RCol}"
    chkDisk
  fi
}

chkDisk() {
	echo "${BGre}How much Disk space you want to allocate to container with ID: "$userCtid"?${RCol}"
	echo "${BGre}Examples:${RCol}"
	echo "${BGre}a) 10${RCol}"
	echo "${BGre}b) 512${RCol}"
	chkSoftLimit
}

chkSoftLimit() {
	echo "${BCya}All the values must be in GB's.${RCol}"
	echo -e "-------------------------"
  echo -e "${BGre}Enter the ${BRed}soft${RCol} limit:${RCol}"
  echo -e "-------------------------"
  read -e userSoftLimit
  if [[ -z "$userSoftLimit" ]]; then
		echo -e "${BRed}This cannot be empty, try again${RCol}"
		chkSoftLimit
	elif	[[ ! "$userSoftLimit" =~ ^[-+]?[0-9]+$ ]]; then
		echo "${BRed}Only integers are accepted. Try again${RCol}"
    chkSoftLimit
	else
		chkHardLimit
  fi
}

chkHardLimit() {
	echo -e "-------------------------"
  echo -e "${BGre}Enter the ${BRed}hard${RCol} limit:${RCol}"
  echo -e "-------------------------"
  read -e userHardLimit
  if [[ -z "$userHardLimit" ]]; then
		echo -e "${BRed}This cannot be empty, try again${RCol}"
		chkHardLimit
	elif	[[ ! "$userHardLimit" =~ ^[-+]?[0-9]+$ ]]; then
		echo "${BRed}Only integers are accepted. Try again${RCol}"
    chkHardLimit
  fi
}
