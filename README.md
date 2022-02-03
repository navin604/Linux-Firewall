# Linux-Firewall
Scripts to set up a specific network config and firewall to control access to an internal network

Rules implemented:  
  • Inbound/Outbound TCP packets on allowed ports.  
  • Inbound/Outbound UDP packets on allowed ports.  
  • Inbound/Outbound ICMP packets based on type numbers.  
  
  • Drop all packets destined for the firewall host from the outside.  
  • Drop packets with a source address from the outside matching your internal network.  
  • Rejects those connections that are coming the “wrong” way (i.e., inbound SYN packets to high ports).  
  • Accept all TCP packets that belong to an existing connection (on allowed ports).
  • Drop all TCP packets with the SYN and FIN bit set.  
  • Do not allow Telnet packets at all.  
  • For FTP and SSH services, set control connections to "Minimum Delay" and FTP data to "Maximum Throughput".  
  • Permit inbound/outbound ssh packets.  
  • Permit inbound/outbound www packets.  
  • Drop inbound traffic to port 80 (http) from source ports less than 1024.  
  • Drop all incoming packets from reserved port 0 as well as outbound traffic to port 0.  
