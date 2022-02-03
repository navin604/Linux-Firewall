#! /bin/bash

#Author:Navin Parmar

#How to use: You have 3 options. Run this script with the required argument on each machine.
#If you use any other argument it will not work

#1. /setup.sh internal
#2. /setup.sh firewall
#3. /setup.sh external


source ./script.config



if [ $1 = "firewall" ]; then
	sudo systemctl disable firewalld
	sudo ifconfig $firewall_internal_nic $int_gw up
	sudo echo "1" >/proc/sys/net/ipv4/ip_forward

	#Set gateway for each internal and external subnet
	# -net  used to specify target network
	route add -net $ext_subnet netmask 255.255.255.0 gw $ext_gw
	route add -net $internal_subnet gw $int_gw
	#NAT, Redirects incoming packets to internal network.
	iptables -t nat -A POSTROUTING -o $firewall_ext_nic -j MASQUERADE
	iptables -A FORWARD -i $firewall_internal_nic -o $firewall_ext_nic -j ACCEPT
	sudo rm /etc/resolv.conf
	sudo echo "nameserver 8.8.8.8" >> /etc/resolv.conf
	sudo echo "nameserver 8.8.4.4" >> /etc/resolv.conf
	
fi
if [ $1 = "internal" ]; then
	sudo systemctl disable firewalld
	sudo ifconfig $internal_ext_nic down
	sudo ifconfig $internal_nic 192.168.3.2 up
	route add default gw $int_gw
	sudo rm /etc/resolv.conf
	sudo echo "nameserver 8.8.8.8" >> /etc/resolv.conf
	sudo echo "nameserver 8.8.4.4" >> /etc/resolv.conf
fi 
if [ $1 = "external" ]; then
	sudo systemctl disable firewalld
	route add -net 192.168.3.0 netmask 255.255.255.0 gw $firewall_ext_ip
fi
