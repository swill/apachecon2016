#!/usr/bin/env bash

systemctl stop NetworkManager.service
systemctl disable NetworkManager.service

# get the names of the nics operate on each
ethnum=0
for eno in `dmesg | grep "e1000: eno" | tr " " "\n"` ; do 
	if [[ $eno == eno* ]] ; then
		# update the network cfg files
		oldpath="/etc/sysconfig/network-scripts/ifcfg-$eno"
		ethpath="/etc/sysconfig/network-scripts/ifcfg-eth$ethnum"

		echo "configuring eth$ethnum"
		mv $oldpath $ethpath
		sed -i "s/$eno/eth$ethnum/" $ethpath
		sed -i "s/BOOTPROTO=dhcp/BOOTPROTO=none/" $ethpath
		sed -i "s/IPV4_FAILURE_FATAL=no/IPV4_FAILURE_FATAL=yes/" $ethpath
		sed -i "s/ONBOOT=no/ONBOOT=yes/" $ethpath

		echo "IPADDR=172.16.254.10" >> $ethpath
		echo "DNS1=172.16.254.5" >> $ethpath
		echo "GATEWAY=172.16.254.5" >> $ethpath
		echo "PREFIX=24" >> $ethpath

		ethnum=$((ethnum + 1))
	fi
done

# update the grub cmd so eth0 will actually come up correctly
echo "updating grub to keep the new network config"
sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="net.ifnames=0 /' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

echo "rebooting in 5 seconds..."
sleep 5

reboot