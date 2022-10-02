#!/bin/bash

cd openwrt

make -j$(nproc)

mkdir ../built_deps

cp bin/targets/ath79/generic/openwrt-ath79-generic-extreme-networks_ws-ap3805i-squashfs-sysupgrade.bin ../built_deps/sysupgrade.bin

cp build_dir/target-mips_24kc_musl/root-ath79/lib/ld-musl-mips-sf.so.1 ../built_deps/
cp build_dir/target-mips_24kc_musl/root-ath79/usr/sbin/fw_setenv ../built_deps/
#cp build_dir/target-mips_24kc_musl/root-ath79/etc/fw_env.config ../built_deps/

patch -p0 < ../provisioning_pw.patch

make -j$(nproc)

cp bin/targets/ath79/generic/openwrt-ath79-generic-extreme-networks_ws-ap3805i-initramfs-kernel.bin ../built_deps/bootp-image.bin

patch -p0 -R < ../provisioning_pw.patch
