#!/bin/env bash
#
# Author: Aman Hanjrah
# License: GPL
# Usage: Simply run this script on the machine/server on which you want to install the OpenVZ and rest is all taken care of.
# About: This script is for system administrators who want to configure OpenVZ on their server without getting into much detail of editing the files manually. This script can work with any flavour of Linux with a few modifictaions. I have tested it with CentOS 6 only and I am pretty sure that it works as expected. 
#
# Fore any questions/reviews/donations etc., please visit: http://techlinux.net
#
# START
DIR="/tmp/"
TMPLTE="http://download.openvz.org/template/precreated/centos-6-x86_64.tar.gz"
TMPLTE_DIR="/vz/template/cache"
REPO_DIR="/etc/yum.repos.d/"
REPO="http://download.openvz.org/openvz.repo"
KEY="rpm --import http://download.openvz.org/RPM-GPG-Key-OpenVZ"
function install() {
cd "$DIR"
wget "$REPO"
mv openvz.repo "$REPO_DIR"
if [[ `echo $?` -eq 0 ]]; then
	echo "I am going to install the openvz kernel with some goodies now. Hit 'ENTER' to continue!"
	echo " "
	yum install vzkernel vzctl vzquota -y 2&> /tmp/vz-error.txt
		if [[ `echo $?` -eq 0 ]]; then
			echo "Installation of vz kernel finished."
		else
			echo "Something went wrong while installing the kernel. You can review the error from: /tmp/vz-error.txt"
			exit 127
		fi
else
	echo "Before installing the openvz kernel, the repo must be defined. Exiting now!"
	sleep 1
exit 127
fi }
function changes() {
echo "Making changes in /etc/sysctl.conf"
	sed -i 's/net.ipv4.ip_forward = [0-9]*/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf
	sed -i 's/kernel.sysrq = [0-9]*/kernel.sysrq = 1/g' /etc/sysctl.conf
	echo "net.ipv4.conf.default.proxy_arp = 0" > /etc/sysctl.conf
	echo "net.ipv4.conf.all.rp_filter = 1" > /etc/sysctl.conf
	echo "net.ipv4.conf.default.send_redirects = 1" > /etc/sysctl.conf
	echo "net.ipv4.conf.all.send_redirects = 0" > /etc/sysctl.conf
	echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" > /etc/sysctl.conf
	echo "net.ipv4.conf.default.forwarding = 1" > /etc/sysctl.conf
echo "Reloading sysctl..."
sysctl -p
# Check if SELinux is enabled or disabled.
if [[ `getenforce` == Enabled ]]; then
	echo "Selinux is enabled. Attempting to disable it."
	setenforce 0
	sed -i 's/SELINUX=[*]/SELINUX=Disabled/g' /etc/sysconfig/selinux
	echo "Done!"
	echo " "
	sleep 2
elif [[ `getenforce == Disabled` ]]; then
	echo "SELinux is already disabled."
	echo " "
else
	echo "Cannot get any status, are you sure you are using CentOS or Red Hat?"
	echo "Exiting..."
	echo " "
fi }
# Going to download a CentOS 6 template.
function download() {
cd "$TMPLTE_DIR"
echo "This might take some time, please be patient."
wget -c "$TMPLTE"
echo " "
echo "Next, I am going to install OpenVZ web panel for easy management of your OpenVZ containers."
wget -O - http://ovz-web-panel.googlecode.com/svn/installer/ai.sh | sh
echo "All Done!"
echo " "
}
function rebt() {
echo "A reboot is necessary to make all this work. Please let me know if I should reboot the machine or not by pressing either '1' or '2':"
echo "1 : Reboot"
echo "2 : Not Now"
read -e "OPT"
	if [[ "$OPT" -eq 1 ]]; then
	sleep 1
	echo "Cleaning up..."
	unset {DIR,TMPLTE,TMPLTE_DIR,REPO_DIR,REPO,KEY,OPT}
	echo " "
	echo "#####-------------------------------------#####"
	echo " "
	echo "#####  	 http://techlinux.net   	#####"
	echo " "
	echo "#####-------------------------------------#####"
	sleep 2
	reboot
	elif [[ "$OPT" -eq 2 ]]; then
	echo "You chose not to reboot the system. Please note that this setup won't work without a reboot."
	else
	echo " "
	echo "You need to choose one option"
	echo " "
fi
}
if [[ `rpm -qa | grep vzkernel` && `echo $?` == 0 ]]; then
	echo "'vzkernel' is already installed."
else
	install
	changes
	download
fi
for i in "$OPT"; do
	rebt
done
# END