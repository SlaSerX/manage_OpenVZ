#!/usr/bin/env bash
#
# Author: Aman Hanjrah
# Date: 21 Mar 2015
# License: GPLv2.0
#
# Description: This script takes user inputs to create and manage OpnVZ containters.
#
# Start
main() {
	. ./vars.sh #source vars.sh so that it can be used in this script
	optionDefined #run this function
}

prerequisites() {
	# Check if pre-requisite packages are installed or not
	while read -r pkg <&3 #read from 3rd file descriptor
	do
	  if rpm --quiet --query "$pkg"; then
	    echo -e "$pkg already installed."
	  else
			echo -e "Installing pre-requisites...please wait!"
	    yum install "$pkg" >> /dev/null
	  fi
	done 3< ./packages.txt #input data on 3rd descriptor
}

userInput() {
	clear
	echo -e "--------------------------------------------------"
	echo -e "${BGre}Select the task you want to perform:${RCol}"
	echo -e "--------------------------------------------------"
	echo -e "1. Create a new container"
	echo -e "2. Change RAM on current container"
	echo -e "3. Change disk space on a current container"
	echo -e "4. Change hostname for a current container"
	echo -e "5. Change IP address for a current container"
	echo -e "6. Change the DNS(nameserver) entry for a container"
	echo -e "7. Change the name for a current container"
	echo -e "8. Mark a current container to autoboot or not"
	echo -e "9. Change 'root' user password for a container"
	echo -e "10. Change number of CPU cores of a container"
	echo -e "11. Add a description to a container"
	echo -e "12. Exit!"
	echo -e "--------------------------------------------------"
	read -e USERINPUT
	if [[ -z $USERINPUT ]]; then #if user input is empty
		echo -e "${BWhi}You must specify atleast one option, try again:${RCol}"
		sleep 3
		userInput #ask for input again
	fi
}

optionDefined() {
	userInput
	if [[ "$USERINPUT" = 12 ]]; then #if user input is equal to 12
		sh takeMeOut.sh #call exit script
		exit 0
	fi
	echo -e "Checking few pre-requisites...pleae wait!"

	case "$USERINPUT" in #take user input in numbers
		1)
			clear
			prerequisites
			sh createContainer.sh
			;;
		2)
			clear
			prerequisites
			sh changeRAM.sh
			;;
		3)
			clear
			prerequisites
			sh changeDiskSpace.sh
			;;
		4)
			clear
			prerequisites
			sh changeHostname.sh
			;;
		5)
			clear
			prerequisites
			sh changeIP.sh
			;;
		6)
			clear
			prerequisites
			sh changeDNS.sh
			;;
		7)
			clear
			prerequisites
			sh changeName.sh
			;;
		8)
			clear
			prerequisites
			sh autoBoot.sh
			;;
		9)
			clear
			prerequisites
			sh changeRootPass.sh
			;;
		10)
			clear
			prerequisites
			sh changeCpuCores.sh
			;;
		11)
			clear
			prerequisites
			sh addDesc.sh
			;;
		12)
			clear
			prerequisites
			sh takeMeOut.sh
			;;
		*)
			echo -e "${txtBold}You need to select a valid option, try again!${txtNormal}" #echo this line if user inputs anything except numbers from 1 to 12
			sleep 3
			optionDefined
			;;
	 esac
}

main #call 'main' function
# End
