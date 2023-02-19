#!/bin/bash

cd dhcp

export IFNAME=enp4s0
export USER=$SUDO_USER

nmcli d d "$IFNAME"
ip l s down dev "$IFNAME"

ip addr replace 10.69.69.254/24 dev $IFNAME
ip link set dev $IFNAME up

trap terminate SIGINT
terminate(){
    pkill -SIGKILL -P $$
    exit
}

./dhcpd.sh &
./dnsmasq.sh &

wait
