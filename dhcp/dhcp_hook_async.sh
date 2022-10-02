#!/bin/bash

IP=$2
MAC=$3

cd ../built_deps

E() {
  echo $(tput bold)\# $IP $@$(tput sgr0)
}

ssh_host() {
  sshpass -p "$1" ssh -o "UserKnownHostsFile=/dev/null" -o StrictHostKeyChecking=no $2@$IP "$3" &>/dev/null
}

ssh_host_exnet() {
  ssh_host "new2day" admin "$1"
}

ssh_host_openwrt() {
  ssh_host "provision" root "$1"
}

scp_file() {
  sshpass -p "$1" scp -o "UserKnownHostsFile=/dev/null" -o StrictHostKeyChecking=no $3 "$4" "$2"@$IP:/"$5" &>/dev/null

  if [ $? -ne 0 ]; then
    E "failed to upload file" $3

    exit 1
  fi
}

scp_file_exnet() {
  scp_file "new2day" admin "" "$1" "$2"
}

scp_file_exnet_dl() {
  sshpass -p "new2day" scp -o "UserKnownHostsFile=/dev/null" -o StrictHostKeyChecking=no admin@$IP:/"$1" "$2" &>/dev/null

    if [ $? -ne 0 ]; then
      E "failed to download file" $3

      exit 1
    fi
}

scp_file_openwrt() {
  scp_file "provision" root "-O" "$1" "$2"
}

E AP connected

timeout 5 /bin/sh -c -- "while ! timeout 0.5 ping -c 1 -n $IP &>/dev/null; do :; done"
if [ $? -ne 0 ]; then
  E "timeout, aborting"

  exit 1
fi

sleep 1

ssh_host_exnet
if [ $? -eq 0 ]; then
  E EXTREME NETWORKS AP: creating mtd dump

  ssh_host_exnet "sh -c 'i=0; while [ \$i -ne 11 ]; do dd if=/dev/mtd\$i of=/tmp/tftp/mtd\$i.bin; i=\$((\$i+1)); done'"

  mkdir -p "../mtd/$MAC"

  E EXTREME NETWORKS AP: downloading mtd dump

  scp_file_exnet_dl "*" "../mtd/$MAC/"

  E EXTREME NETWORKS AP: configuring bootloader

  scp_file_exnet ld-musl-mips-sf.so.1
  scp_file_exnet fw_setenv
  scp_file_exnet fw_env.config

  ssh_host_exnet "cd /tmp/tftp/; mv ld-musl-mips-sf.so.1 /lib/; mv fw_env.config /etc/; mkdir /var/lock"
  ssh_host_exnet "/tmp/tftp/fw_setenv bootcmd 'bootp; bootm'; reboot"

  E EXTREME NETWORKS AP: configured, rebooting ...

  exit 0
fi

ssh_host "" root
if [ $? -eq 0 ]; then
  E OPENWRT AP: install finished $MAC

  exit 0
fi

ssh_host_openwrt
if [ $? -eq 0 ]; then
  E OPENWRT BOOTP AP: configuring bootloader and sysupgrade

  scp_file_openwrt fw_env.config /etc/

  scp_file_openwrt sysupgrade.bin /tmp

  ssh_host_openwrt "fw_setenv boot_openwrt 'setenv bootargs; bootm 0xa1280000'"
  ssh_host_openwrt "fw_setenv ramboot_openwrt 'setenv serverip 192.168.1.66; tftpboot; bootm'"
  ssh_host_openwrt "fw_setenv bootcmd 'run boot_openwrt'"

  E OPENWRT BOOTP AP: executing sysupgrade

  ssh_host_openwrt "sysupgrade -n /tmp/sysupgrade.bin"

  E OPENWRT BOOTP AP: rebooting

  exit 0
fi
