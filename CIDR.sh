#!/bin/bash
#Example bash script from the "Bash Scripting" module on HackTheBox Academy

# Check for given argument
if [ $# -eq 0 ] #If nothing is entered for the argument by the user
then
	echo -e "You need to specify the target domain.\n" #Instructions for the user when they misuse the script
	echo -e "Usage:"
	echo -e "\t$0 <domain>" #Command example with \t for tabbed output. The -e option is needed to escape the forward slash.
	exit 1 #Signifies exiting the process due to an error. 0 would be a success code and everything above it is a different type of error.
else
	domain=$1
fi

# Available options shown as a tabbed list
echo -e "Additional options available:"
echo -e "\t1) Identify the corresponding network range of target domain."
echo -e "\t2) Ping discovered hosts."
echo -e "\t3) All checks."
echo -e "\t*) Exit.\n"

read -p "Select your option: " opt

case $opt in #Takes the option from the previous section and picks a function based on that.
	"1") network_range ;;
	"2") ping_host ;;
	"3") network_range && ping_host ;;
	"*") exit 0 ;;
esac

# Identify IP address of the specified domain
hosts=$(host $domain | grep "has address" | cut -d" " -f4 | tee discovered_hosts.txt)

#Ping hosts	to determine if they're up
function ping_host {
  echo -e "\nPinging host(s):"
  	for host in $cidr_ips
  	do
  		stat=1
  		while [ $stat -eq 1 ]
  		do
  			ping -c 2 $host > /dev/null 2>&1 #Pings the specified host and passes errors to null/void space.
  			if [ $? -eq 0 ]
  			then
  				echo "$host is up."
  				((stat--))
  				((hosts_up++))
  				((hosts_total++))
  			else
  				echo "$host is down."
  				((stat--))
  				((hosts_total++))
  			fi
  		done
  	done
}

# Identify Network range for the specified IP address(es)
function network_range {
	for ip in $ipaddr
	do
		netrange=$(whois $ip | grep "NetRange\|CIDR" | tee -a CIDR.txt)
		cidr=$(whois $ip | grep "CIDR" | awk '{print $2}')
		cidr_ips=$(prips $cidr)
		echo -e "\nNetRange for $ip:"
		echo -e "$netrange"
	done
}
