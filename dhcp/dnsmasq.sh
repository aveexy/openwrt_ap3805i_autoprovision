#!/bin/bash

cd ../built_deps/

dnsmasq \
--user=$USER \
--no-daemon \
--listen-address 10.69.69.254 \
--bind-interfaces \
-p0 \
--bootp-dynamic \
--enable-tftp \
--tftp-root=$(pwd) \
--dhcp-boot=bootp-image.bin
