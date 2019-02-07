#!/bin/sh
#
# Simple Firewall configuration.
#
# Author: Nicolargo
# Update by : DanyBadoinot
#
# chkconfig: 2345 9 91
# description: Activates/Deactivates the firewall at boot time
#
### BEGIN INIT INFO
# Provides:          firewall.sh
# Required-Start:    $syslog $network
# Required-Stop:     $syslog $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start firewall daemon at boot time
# Description:       Custom Firewall scrip.
### END INIT INFO

# set to true if it is CentOS / RHEL / Fedora box
RHEL=false

### no need to edit below  ###
IPT=/sbin/iptables
IPT6=/sbin/ip6tables

# Services that the system will offer to the network
TCP_SERVICES="80 21 5666" # SSH only
UDP_SERVICES=""

# Services the system will use from the network
REMOTE_TCP_SERVICES="80 443" # web browsing
REMOTE_UDP_SERVICES="53" # DNS

SSH_PORT="22"

if ! [ -x $IPT ]; then
 echo "Sorry we can't find iptables at $IPT"
 exit 0
fi

##########################
# Start the Firewall rules
##########################

fw_start () {

# Input traffic:
$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# Services
if [ -n "$TCP_SERVICES" ] ; then
 for PORT in $TCP_SERVICES; do
  $IPT -A INPUT -p tcp --dport ${PORT} -j ACCEPT
 done
fi
if [ -n "$UDP_SERVICES" ] ; then
 for PORT in $UDP_SERVICES; do
  $IPT -A INPUT -p udp --dport ${PORT} -j ACCEPT
 done
fi
/sbin/iptables -A INPUT -p tcp --dport ${SSH_PORT}  -j ACCEPT

# Remote testing
$IPT -A INPUT -p icmp -j ACCEPT
$IPT -A INPUT -i lo -j ACCEPT
$IPT -P INPUT DROP
$IPT -A INPUT -j LOG


# Output:
$IPT -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# So are security package updates:
# Note: You can hardcode the IP address here to prevent DNS spoofing
# and to setup the rules even if DNS does not work but then you
# will not "see" IP changes for this service:
if [ ! "$RHEL" == "true" ]; then
 $IPT -A OUTPUT -p tcp -d security.debian.org --dport 80 -j ACCEPT
fi

# As well as the services we have defined:
if [ -n "$REMOTE_TCP_SERVICES" ] ; then
for PORT in $REMOTE_TCP_SERVICES; do
 $IPT -A OUTPUT -p tcp --dport ${PORT} -j ACCEPT
done
fi
if [ -n "$REMOTE_UDP_SERVICES" ] ; then
for PORT in $REMOTE_UDP_SERVICES; do
 $IPT -A OUTPUT -p udp --dport ${PORT} -j ACCEPT
done
fi
# All other connections are registered in syslog
$IPT -A OUTPUT -p icmp -j ACCEPT
$IPT -A OUTPUT -j ACCEPT -o lo
$IPT -P OUTPUT DROP
$IPT -A OUTPUT -j LOG
$IPT -A OUTPUT -j REJECT

# Other network protections
# (some will only work with some kernel versions)
echo 1 > /proc/sys/net/ipv4/tcp_syncookies
echo 0 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
echo 1 > /proc/sys/net/ipv4/conf/all/log_martians
echo 1 > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter
echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route

}

##########################
# Stop the Firewall rules
##########################

fw_stop () {
$IPT -F
$IPT -t nat -F
$IPT -t mangle -F
$IPT -P INPUT DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT ACCEPT
}

##########################
# Clear the Firewall rules
##########################

fw_clear () {
$IPT -F
$IPT -t nat -F
$IPT -t mangle -F
$IPT -P INPUT ACCEPT
$IPT -P FORWARD ACCEPT
$IPT -P OUTPUT ACCEPT
}

############################
# Restart the Firewall rules
############################

fw_restart () {
   fw_stop
   fw_start
}

##########################
# Test the Firewall rules
##########################

fw_save () {
   $IPT-save > /etc/iptables.backup
}

fw_restore () {
   if [ -e /etc/iptables.backup ]; then
    $IPT-restore < /etc/iptables.backup
   fi
}

fw_test () {
   fw_save
   fw_restart
   sleep 20
   fw_restore
}

confirm(){
   read -r -p "Are you sure? [y/N] " response
   response=${response,,}    # tolower
   if [[ ! $response =~ ^(yes|y)$ ]]; then
      echo "Abording"
      exit 0
   fi
}

case "$1" in
start|restart)
 echo -n "Starting firewall..."
 fw_restart
 echo "done."
 ;;
stop)
 echo "Il semblerait que vous vouliez couper toutes les connexions entrantes et sortantes"
 confirm
 echo -n "Stopping firewall..."
 fw_stop
 echo "done."
 ;;
clear)
 echo -n "Clearing firewall rules..."
 fw_clear
 echo "done."
 ;;
test)
 echo -n "Test Firewall rules..."
 echo -n "Previous configuration will be restore in 30 seconds"
 fw_test
 echo -n "Configuration as been restored"
 ;;
*)
 echo "Usage: $0 {start|stop|restart|clear|test}"
 echo "Be aware that stop drop all incoming/outgoing traffic !!!"
 exit 1
 ;;
esac
exit 0
