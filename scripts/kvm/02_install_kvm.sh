#!/usr/bin/env bash

echo "setting up /etc/hosts"
# target a repo hosted on the parent mac (i don't trust conference wifi)
echo "172.16.254.1    cloudstack.apt-get.eu" >> /etc/hosts

# configure host names for the boxes
echo "172.16.254.10   acs.demo.lab" >> /etc/hosts
echo "172.16.254.15   kvm.demo.lab" >> /etc/hosts
systemctl restart network

### FOR THE DEMO I MOVED THIS TO `00_update_os.sh` BECAUSE NETWORK IS SLOW!!!
## configure the yum repo for acs
#echo "setting up /etc/yum.repos.d/cloudstack.repo"
#acs_repo="/etc/yum.repos.d/cloudstack.repo"
#touch $acs_repo
#echo "[cloudstack]" >> $acs_repo
#echo "name=cloudstack" >> $acs_repo
#echo "baseurl=http://cloudstack.apt-get.eu/centos/7/4.9/" >> $acs_repo
#echo "enabled=1" >> $acs_repo
#echo "gpgcheck=0" >> $acs_repo
#
## prepare to use the new repo
#yum -y update
#
#echo "installing packages"
## install the packages required by kvm
#yum -y install cloudstack-agent ntp vim

echo "disabling selinux"
# disable SELinux
setenforce permissive
sed -i "s/SELINUX=enforcing/SELINUX=permissive/" /etc/selinux/config

echo "setting up qemu"
# setup qemu
sed -i "s/#vnc_listen/vnc_listen/" /etc/libvirt/qemu.conf

echo "setting up libvirt"
# setup libvirt
echo 'options kvm_intel nested=1' >> /etc/modprobe.d/kvm-nested.conf
echo 'listen_tls = 0' >> /etc/libvirt/libvirtd.conf
echo 'listen_tcp = 1' >> /etc/libvirt/libvirtd.conf
echo 'tcp_port = "16509"' >> /etc/libvirt/libvirtd.conf
echo 'mdns_adv = 0' >> /etc/libvirt/libvirtd.conf
echo 'auth_tcp = "none"' >> /etc/libvirt/libvirtd.conf
sed -i "s/#LIBVIRTD_ARGS/LIBVIRTD_ARGS/" /etc/sysconfig/libvirtd
echo 'guest.cpu.mode=host-model' >> /etc/cloudstack/agent/agent.properties
systemctl restart libvirtd

echo "mounting primary and secondary storage"
# setup nfs mounts
systemctl enable rpcbind
systemctl start rpcbind
mkdir /primary
mkdir /secondary
mount -t nfs 172.16.254.10:/primary /primary
mount -t nfs 172.16.254.10:/secondary /secondary
echo "172.16.254.10:/primary /primary nfs rw,hard,intr,rsize=8192,wsize=8192,timeo=14 0 0" >> /etc/fstab
echo "172.16.254.10:/secondary /secondary nfs rw,hard,intr,rsize=8192,wsize=8192,timeo=14 0 0" >> /etc/fstab
