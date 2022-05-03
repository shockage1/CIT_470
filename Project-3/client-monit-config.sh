#!/bin/bash

# Team 4 - Derek, Jalen, Adam
# Bash script file for installing and configuring monit/rsyslog
# CIT 470-001 Spring 2022 - Darci Guriel

# Function for displaying script usage
usage() {
  echo "Usage: client-monit-config	[ -h | --help ]
                        	[ -n | --network [IP_ADDRESS] ]"
  exit 0
}

# Function for displaying help when invoked by -h option
helpPage() {
  echo "Usage: client-monit-config	[ -h | --help ]
                    		[ -n | --network [IP_ADDRESS] ]
Automated bash install script for monit and remote rsyslog
Uses defined IP address to configure rsyslog server

  -h, --help                  displays this help page
  -n, --network               rsyslog server network address
                              e.g., '--network 10.2.6.1'"
}

# Exit the script if no arguments are supplied
if [ $# -eq 0 ]; then
  usage
  exit 1
fi

# Option parameters
options=$(getopt -o 'hn:' -l 'help,network:' -- "$@")
eval set -- "$options"
while true; do
    case "$1" in
    -h | --help)
        helpPage;
        exit 0;
        ;;
    -n | --network)
        NETWORK="$2";
        # Regex for determining correct IP address inputs
        [[ "$NETWORK" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] || { echo "IP Address is invalid. Please try again"; exit 1; }
        # Use ipcalc to determine if valid IP address/network, otherwise exit
        ipcalc -c $NETWORK || { echo "IP Address is invalid. Please try again"; exit 1; }
        shift 2;;
    --) shift; break;;
    esac
done


# Redirect all stdout and stderr to log file
exec 3>&1 # Stream 3 is used to output messages
exec 1>"$0".log 2>&1
# All output below will go to the file 'client-monit-config.log':

function monitSetup {
	echo "Configuring remote rsyslog..."
	echo "Configuring remote rsyslog..." >&3
  # Sets up remote syslog monitoring through UDP
	sed -i "/#*.* @@remote-host:514/a *.* @$NETWORK:514" /etc/rsyslog.conf
	systemctl restart rsyslog
	echo "Installing sendmail..."
	echo "Installing sendmail..." >&3
	yum -y install sendmail
	systemctl start sendmail
	systemctl enable sendmail
	echo "Installing monit..."
	echo "Installing monit..." >&3
	yum -y install epel-release
	yum -y install monit
	echo "Downloading monitrc..."
	echo "Downloading monitrc..." >&3
	wget $NETWORK/cMonitRC # Retrieve from HTTP server
	chmod 600 cMonitRC # Monit allows maximum of 600 permissions on monitrc
	mv -f ./cMonitRC /etc/monitrc
	systemctl start monit
	systemctl enable monit
  echo "Finished!"
  echo "Finished!" >&3
}

# Execute main function
monitSetup
exit 0