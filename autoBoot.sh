#!/usr/bin/env bash
#
# Author: Aman Hanjrah
# Date: 28 Mar 2015
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
    chkUserOpts
	fi
}

chkUserOpts() {
  echo -e "${BGre}Enter 'YES' or 'NO':${RCol}"
	read -e userOpt
  if [[ -z "$userOpt" ]]; then
		echo -e "${BRed}This cannot be empty, try again${RCol}"
    chkUserOpts
  else
    autoBootOpts
	fi
}

autoBootOpts() {
  case "$userOpt" in
    [yY] | [yY][Ee][Ss] )
      stopCtid
      vzctl set "$userCtid" --onboot yes --save >> /dev/null 2<&1
      if [[ $? = 0 ]]; then
        echo -e "${BGre}Container $userCtid marked to start on boot."
        startCtid
        sh master.sh
      fi
    ;;
    [nN] | [nN][oO] )
      stopCtid
      vzctl set "$userCtid" --onboot no --save >> /dev/null 2<&1
      if [[ $? = 0 ]]; then
        echo -e "${BGre}Container $userCtid unmarked to start on boot.${RCol}"
        startCtid
        sh master.sh
      fi
    ;;
    *)
      echo -e "${BRed}Invalid option supplied, try again.${RCol}"
      chkUserOpts
    ;;
  esac
}

main
