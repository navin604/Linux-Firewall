#! /bin/bash

source ./script.config

output_file="TestResults.txt"
password="password"
name="user"


echo "PLEASE RUN THE SCRIPT AS ROOT" >> $output_file
echo "THE SSH FOR MY MACHINES USE A PASSWORD, NOT A KEY, SPECIFY THE PASSWORD AND USERNAME ABOVE IN THIS FILE" >> $output_file

echo -e "\nStarting Test Script!" >> $output_file
echo -e "----------------------\n" >> $output_file

echo  "Test 1: Drop all packets destined for firewall host" >> $output_file
echo "-----------------------------------------------------" >> $output_file
echo "All packets should be dropped. 100% Loss is a success" >> $output_file
hping3 -c 3 $int_gw &>> $output_file
hping3 -c 3 $firewall_ext_ip &>> $output_file

echo -e "\n" >> $output_file
echo  "Test 2: Drop packets with a source address matching the internal network" >> $output_file
echo "--------------------------------------------------------------------------" >> $output_file
echo Using hping3 to spoof a source address of $internal_ip >> $output_file
echo "A result of 100% packet loss is a success" >> $output_file
hping3 -c 3 -a $internal_ip $firewall_ext_ip &>> $output_file

echo -e "\n" >> $output_file
echo  "Test 3: Drop wrong way connections" >> $output_file
echo "---------------------------------------" >> $output_file
echo "This test will send 3 SYN packets to the internal machine at a high port. It should be dropped with 100% packet loss" >> $output_file
hping3 -S -c 3 -p 2000 $firewall_ext_ip &>> $output_file
echo -e "\n" >> $output_file

echo  "Test 4: Drop TCP packets with SYN and FIN bit set" >> $output_file
echo "--------------------------------------------------------------------------" >> $output_file
echo "Sending 3 packets, a successful test results in 100% loss" >> $output_file
hping3 -S -F -c 3 $firewall_ext_ip &>> $output_file 

echo -e "\n" >> $output_file
echo  "Test 5:Do not allow Telnet packets" >> $output_file
echo "--------------------------------------------------------------------------" >> $output_file
echo "Attempting to connect to port 23(TELNET). A successful test results in 100% loss" >> $output_file

hping3 -S -s 23 -c 3 $firewall_ext_ip &>> $output_file

echo -e "\n" >> $output_file
echo  "Test 6: Traffic to port 80 from source port less than 1024" >> $output_file
echo "--------------------------------------------------------------------------" >> $output_file
echo "Sending 3 packets, a successful test results in 100% loss" >> $output_file
hping3 -S -s 1000 -c 3 -p 80 $firewall_ext_ip &>> $output_file


echo -e "\n" >> $output_file
echo  "Test 7: Permit inbound http packets from ports above 1024" >> $output_file
echo "--------------------------------------------------------------------------" >> $output_file
echo "Sending 3 packets, a successful test results in 0% loss" >> $output_file
hping3 -S -s 2000 -c 3 -p 80 $firewall_ext_ip &>> $output_file

echo -e "\n" >> $output_file
echo  "Test 8: Permit inbound/outbound packets to and from port 443(HTTPS)" >> $output_file
echo "--------------------------------------------------------------------------" >> $output_file
echo "Sending 3 packets, a successful test results in 0% loss" >> $output_file
hping3 -S -s 2000 -c 3 -p 443 $firewall_ext_ip &>> $output_file

echo -e "\n" >> $output_file
echo  "Test 9: Permit inbound/outbound packets to port 53(DNS)" >> $output_file
echo "--------------------------------------------------------------------------" >> $output_file
echo "Using SSH to access the internal machine. Successful test shows output of nslookup" >> $output_file
sshpass -p $password ssh "$name@$firewall_ext_ip" sudo nslookup www.google.com &>> $output_file

echo -e "\n" >> $output_file
echo  "Test 10: Permit inbound/outbound ssh packets" >> $output_file
echo "--------------------------------------------------------------------------" >> $output_file
echo "Using SSH to access the internal machine and run ifconfig. Should be able to see internal machines IP address: $internal_ip" >> $output_file
sshpass -p $password ssh "$name@$firewall_ext_ip" ifconfig &>> $output_file


echo -e "\n" >> $output_file
echo  "Test 11: Drop outbound traffic to port 0" >> $output_file
echo "--------------------------------------------------------------------------" >> $output_file
echo "Using SSH to access the internal machine and run hping3. Output should show a 100% packet loss" >> $output_file
sshpass -p $password ssh "$name@$firewall_ext_ip" sudo hping3 -S -s 1500 -c 3 -p 0 $ext_ip &>> $output_file

echo -e "\n" >> $output_file
echo  "Test 12: Drop inbound traffic to port 0" >> $output_file
echo "--------------------------------------------------------------------------" >> $output_file
echo "Using hping3, this will send traffic to port 0 of the internal machine which should result in 100% loss" >> $output_file
hping3 -S -s 2000 -c 3 -p 0 $firewall_ext_ip &>> $output_file

echo -e "\n"
echo "Testing Completed!" >> $output_file



