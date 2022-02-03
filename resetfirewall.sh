#! /bin/bash

iptables --policy INPUT ACCEPT
iptables --policy OUTPUT ACCEPT
iptables --policy FORWARD ACCEPT

iptables -F
iptables -X
iptables -t mangle -F
iptables -t nat -F
