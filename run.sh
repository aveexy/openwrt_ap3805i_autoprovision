#!/bin/bash

cd dhcp

export IFNAME=enp0s13f0u4
export USER=$SUDO_USER

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
