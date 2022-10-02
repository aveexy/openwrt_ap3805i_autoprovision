#!/bin/bash

git clone https://github.com/aveexy/openwrt.git

cd openwrt

git checkout ap3805i_autoprovisioning

cp ../.config .

./scripts/feeds update -a
./scripts/feeds install -a

make -j20 download

make oldconfig
