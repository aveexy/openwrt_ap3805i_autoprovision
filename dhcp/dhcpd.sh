#!/bin/bash

dhcpd -lf /tmp/gluon.leases -cf dhcpd.conf -4 -f $IFNAME
