#!/bin/bash

dhcpd -cf dhcpd.conf -4 -f $IFNAME
