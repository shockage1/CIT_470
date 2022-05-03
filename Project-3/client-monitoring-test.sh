#!/bin/bash

# Install stress for monit testing if it is not already installed
yum -y install stress

function LDAPtest { 
	echo "Killing LDAP..."
	systemctl kill nslcd
	sleep 65
	echo "Seeing if monit has restored LDAP..."
	systemctl status nslcd | head -n 3
	ps auxw | grep nslcd | head -n 1
	echo "LDAP testing complete"
}

function NFStest {
	echo "Stopping NFS..."
	umount /home
	sleep 65
	echo "Seeing if monit has restored NFS mount..."
	df -t nfs4 /home
	echo "NFS testing complete"
}

function rsyslogTest {
	echo "Killing rsyslog..."
	systemctl kill rsyslog
	sleep 65
	echo "Seeing if monit has restored rsyslog..."
	systemctl status rsyslog | head -n 3
	ps auxw | grep rsyslog | head -n 1
	echo "Syslog testing complete"
}

function sshdTest {
	echo "Killing sshd..."
	systemctl kill sshd
	sleep 65
	echo "Seeing if monit has restored sshd..."
	systemctl status sshd | head -n 3
	ps auxw | grep sshd | head -n 1
	echo "sshd testing complete"
}

function CPUstress {
	echo "Testing CPU..."
	stress --cpu 6 -t 160
	echo "Seeing if monit detected high CPU usage..."
	cat /var/log/monit.log | tail | grep 'cpu usage'
}

function RAMstress {
	echo "Testing RAM..."
	stress --vm-bytes $(awk '/MemAvailable/{printf "%d\n", $2 * 0.9;}' < /proc/meminfo)k --vm-keep -m 1 -t 80
	echo "Seeing if monit detected high RAM usage..."
	cat /var/log/monit.log | tail | grep 'mem usage'
}

function HDDstress {
	echo "Filling /..."
	fallocate -l $(df -B1 / | awk 'NR>1{printf "%d\n", $4 * 0.9}') /tmp/diskhog
	echo "Testing /var..."
	fallocate -l $(df -B1 /var | awk 'NR>1{printf "%d\n", $4 * 0.9}') /var/diskhog
	echo "Testing /home..."
	fallocate -x -l $(df -B1 /home | awk 'NR>1{printf "%d\n", $4 * 0.8}') /home/diskhog # could take awhile
	sleep 65
	echo "Seeing if monit detected high / partition space usage..."
	cat /var/log/monit.log | tail | grep "'root' space usage"
	rm -f /tmp/diskhog
	echo "Seeing if monit detected high /var partition space usage..."
	cat /var/log/monit.log | tail | grep "'var' space usage"
	rm -f /var/diskhog
	echo "Seeing if monit detected high /home partition space usage..."
	cat /var/log/monit.log | tail | grep "'home' space usage"
	rm -f /home/diskhog
}

function result {
	echo "Seeing if monit has fully recovered from testing in 65 seconds..."
	sleep 65
	monit summary

	for Line in $(monit summary | awk 'NR>2{print $2}')
	do
		if [ $Line != 'OK' ]; then
			echo "Monit failed to function properly"
			exit 1
		fi
	done

	echo "Monit is functioning properly!"
}

# Execute main functions
LDAPtest
NFStest
rsyslogTest
sshdTest
CPUstress
RAMstress
HDDstress
result
exit 0