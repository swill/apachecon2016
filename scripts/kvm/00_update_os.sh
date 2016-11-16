#!/usr/bin/env bash

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