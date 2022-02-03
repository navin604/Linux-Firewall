#! /bin/bash

source ./script.config


#DROP as default policy
$IPT --policy INPUT DROP
$IPT --policy OUTPUT DROP
$IPT --policy FORWARD DROP


#Forward SSH requests to internal machine
$IPT -t nat -I PREROUTING -p tcp -d $firewall_ext_ip --dport ssh -j DNAT --to-destination $internal_ip
$IPT -t nat -I POSTROUTING -p tcp -d $internal_ip --dport ssh -j SNAT --to-source $firewall_ext_ip

#Route packets to internal machine
$IPT -t nat -A PREROUTING -i $firewall_ext_nic -p 0 ! --sport $PRIVPORTS  -j DNAT --to 192.168.3.2

#DROP packets destined for firewall host from outside
$IPT -A INPUT -i $firewall_ext_nic -d $firewall_ext_ip -j DROP

#Drop packets to port 80 from sources ports less than 1024
$IPT -A FORWARD -i $firewall_ext_nic -p TCP --dport 80 --sport $PRIVPORTS -j DROP

#DROP packets with source address matching internal network
$IPT -A FORWARD -s $internal_subnet -i $firewall_ext_nic -j DROP 

#DROP connections coming the wrong way(i.e. syn packets to high ports)
$IPT -A FORWARD -p tcp -m multiport --dport $UNPRIVPORTS --syn -j DROP

#DROP TCP packets with SYN and FIN bit set
$IPT -A FORWARD -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP

#Do not allow any TELNET packets
$IPT -A FORWARD -p tcp --dport 23 -j DROP
$IPT -A FORWARD -p tcp --sport 23 -j DROP


#DROP traffic to and from port 0
$IPT -A FORWARD -p tcp --dport 0 -j DROP
$IPT -A FORWARD -p tcp --sport 0 -j DROP

$IPT -A FORWARD -p udp  --dport 0 -j DROP
$IPT -A FORWARD -p udp  --sport 0 -j DROP

#Enable forwarding of packets from firewall to internal
$IPT -A FORWARD -i $firewall_ext_nic -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A FORWARD -o $firewall_ext_nic -m state --state NEW,ESTABLISHED -j ACCEPT

#ACCEPT ICMP packet based off type number
for i in ${accepted_ICMP_type[@]}
do
	$IPT -A FORWARD -p icmp --icmp-type $i  -m state --state NEW,ESTABLISHED -j ACCEPT
done


#Allow WWW packets
$IPT -A FORWARD -p TCP -m multiport --dport 80,443,53 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A FORWARD -p TCP -m multiport --sport 80,443,53 -m state --state NEW,ESTABLISHED -j ACCEPT


#Accept tcp and udp ports based on user config
$IPT -A FORWARD -p tcp -m multiport --sport $accepted_tcp -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A FORWARD -p tcp -m multiport --dport $accepted_tcp -m state --state NEW,ESTABLISHED -j ACCEPT

$IPT -A FORWARD -p udp -m multiport --sport $accepted_udp -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A FORWARD -p udp -m multiport --dport $accepted_udp -m state --state NEW,ESTABLISHED -j ACCEPT



#Allow inbound/outbound ssh packets
$IPT -A FORWARD -i $firewall_ext_nic -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A FORWARD -o $firewall_internal_nic -p tcp --sport 22 -m state --state NEW,ESTABLISHED -j ACCEPT


#For FTP & SSH, set Minimum Delay and for FTP Data set Maximum Throughput
$IPT -A PREROUTING -t mangle -p tcp --sport ssh -j TOS --set-tos Minimize-Delay
$IPT -A PREROUTING -t mangle -p tcp --sport ftp -j TOS --set-tos Minimize-Delay
$IPT -A PREROUTING -t mangle -p tcp --sport ftp-data -j TOS --set-tos Maximize-Throughput
