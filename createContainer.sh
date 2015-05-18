#!/usr/bin/env bash
#
# Author: Aman Hanjrah
# Date: 24 Mar, 2015
# License: GPLv2
#
# Start
main() {
  . ./vars.sh #source vars.sh so that it can be used in this script
  listTemplate=$(mktemp) #create temp file to store template names
  listFile=$(mktemp) #create temp file to store CTID's
  vzRoot="/vz/template/cache" #directory in which templates are present
  chkOsTemplate
}

# This fuction lists the available templates present in /vz/template/cache and takes user input for which OS template is use.
chkOsTemplate() {
# List available templates
# Remove .tar.gz OR .tar.bz2 OR .tar.xz extension and save the output to 'listTemplate'.
  ls -l "$vzRoot" | cut -d' ' -f10 | grep -v '^$' | sed -e 's/.tar.gz//g' | sed -e 's/.tar.bz2//g' | sed -e 's/.tar.xz//g' > "$listTemplate"
  echo -e "${BGre}Available templates are listed below:${RCol}"
  cat "$listTemplate"
  echo -e "-------------------------"
  echo -e "${BCya}MAKE SURE TO COPY PASTE THE EXACT OUTPUT, valid example: centos-7-minimal (WITHOUT .tar.*)${RCol}"
  echo -e "-------------------------"
# Take user input for a template to use
  read -e slctdTemplate
  if [[ -z "$slctdTemplate" ]]; then #check if user input contains at least one template
    echo -e "${BRed}This field cannot be empty, try again${RCol}"
    chkOsTemplate #if user input is empty, user will be prompted again for the input
# Check if the template is of bz2, gz or xz format
  elif [[ -e "$vzRoot"/"$slctdTemplate".tar.gz || -e "$vzRoot"/"$slctdTemplate".tar.bz2 || -e "$vzRoot"/"$slctdTemplate".tar.xz ]]; then
    chkCtid #call next function
  else
    echo -e "${BRed}This template does not seems to be present, try again${RCol}"
    chkOsTemplate #Take input again if template provided is not valid
  fi
}

# This function lists current container's unique CTID and takes the user input
chkCtid() {
# List currently used CTID's
	LIST=$(vzlist -a | cut -d' ' -f8 | grep -v '^$' > "$listFile")
	echo -e "${BGre}Enter the CTID that you want to set:${RCol}"
# Take user input for a unique CTID
	read -e userCtid
	if [[ -z "$userCtid" ]]; then
		echo -e "${BRed}This cannot be empty, try again${RCol}"
		chkCtid
	fi
# Check if the provided CTID already exists
	grep -w "$userCtid" "$listFile" >> /dev/null
	if [[ $? -eq 0 ]]; then
		echo -e "${BRed}CTID that you have mentioned already exist, try again${RCol}"
# Take input again if above check fails
    chkCtid
	else
    chkHostname
	fi
}

# This function takes user input for hostname
chkHostname() {
  echo -e "${BGre}Provide a hostname for this container:${RCol}"
  read -e userHostName
  if [[ -z "$userHostName" ]]; then
		echo -e "${BRed}This cannot be empty, try again${RCol}"
# Take user input again if above check fails
    chkHostname
  else
    chkIPAddr
	fi
}

# This function takes user input for IP address
chkIPAddr() {
  echo -e "${BGre}Provide the IP address:${RCol}"
  echo -e "-------------------------"
  echo -e "${BCya}Be extra careful while defining the IP address as if this is out of range or not accessible over LAN, your containter will not be accessible!${RCol}"
  echo -e "-------------------------"
  read -e userIPAddr
  if [[ -z "$userIPAddr" ]]; then
    echo -e "${BRed}This cannot be empty, try again${RCol}"
# Take user input again if above check fails
    chkIPAddr
  else
    chkDNS
  fi
}

# This function takes user input for DNS server
chkDNS() {
  echo -e "${BGre}Provide a DNS server's IP address${RCol}"
  echo -e "-------------------------"
  echo -e "${BCya}If your container can access the internet, I recommend to use google's DNS server, 8.8.8.8${RCol}"
  echo -e "-------------------------"
  read -e userDNS
  if [[ -z "$userDNS" ]]; then
    echo -e "${BRed}This cannot be empty, try again${RCol}"
# Take user input again if above check fails
    chkDNS
  else
    chkComName
  fi
}

# This function takes user input for a common name
chkComName() {
  echo -e "${BGre}Provide a name for your container, this will be visible to you when you list the containers${RCol}"
  read -e userComName
  if [[ -z "$userComName" ]]; then
    echo -e "${BRed}This cannot be empty, try again${RCol}"
# Take user input again if above check fails
    chkComName
  else
    createContainer
  fi
}

# This function creates a container if all the above checks (defined in individual funtions) pass
createContainer() {
  vzctl create "$userCtid" --ostemplate "$slctdTemplate" --config basic 2> /tmp/createContainer.log
  if [[ $(echo $?) -ne 0 ]]; then
    echo -e "${BRed}Container was not created, something went wrong. Check logs at: /tmp/createContainer.log${RCol}"
    exit 1
  fi
  vzctl set "$userCtid" --hostname "$userHostName" --save >> /dev/null
  vzctl set "$userCtid" --ipadd "$userIPAddr" --save >> /dev/null
  vzctl set "$userCtid" --nameserver "$userDNS" --save >> /dev/null
  vzctl set "$userCtid" --name "$userComName" --save >> /dev/null
  vzctl set "$userCtid" --onboot yes --save >> /dev/null
  startCtid
  echo " "
  echo -e "${BGre}Container created successfully and started.${RCol}"
  echo " "
  sleep 3
  sh master.sh
}

main
# End
