#!/usr/bin/env bash

### I am cheating a little bit here.  I don't want people to have to wait for packages to install
### during the demo, so I am pre-installing the packages that will be required here.
### I have commented out these details in the actual code I will be running in the demo.

# target a repo hosted on my mac (i don't trust conference wifi)
echo "172.16.113.1    cloudstack.apt-get.eu" >> /etc/hosts
systemctl restart network

yum -y update
yum -y upgrade

# required before `01_network_config.sh` to configure bridges
yum -y install bridge-utils

# configure the yum repo for acs
echo "setting up /etc/yum.repos.d/cloudstack.repo"
acs_repo="/etc/yum.repos.d/cloudstack.repo"
touch $acs_repo
echo "[cloudstack]" >> $acs_repo
echo "name=cloudstack" >> $acs_repo
echo "baseurl=http://cloudstack.apt-get.eu/centos/7/4.9/" >> $acs_repo
echo "enabled=1" >> $acs_repo
echo "gpgcheck=0" >> $acs_repo

# prepare to use the new repo
yum -y update

# pre-install everything requiring the internet and without other dependancies for the demo
echo "installing packages"
yum -y install cloudstack-agent ntp vim

# clean up the reference to the `172.16.113.0/24` network as it won't exist later.
sed -i "/172.16.113.1/d" /etc/hosts
systemctl restart network