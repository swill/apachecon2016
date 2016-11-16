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
## install the packages required by acs
#echo "installing packages"
#yum -y install http://mirror.karneval.cz/pub/linux/fedora/epel/epel-release-latest-7.noarch.rpm
#yum --enablerepo=epel -y install mysql-connector-python
#
#yum -y install cloudstack-management mariadb-server nfs-utils ntp vim

# disable SELinux
echo "disabling selinux"
setenforce permissive
sed -i "s/SELINUX=enforcing/SELINUX=permissive/" /etc/selinux/config

# configure secondary storage
echo "configuring primary and secondary storage mounts"
mkdir /primary
mkdir /secondary
echo "/secondary *(rw,async,no_root_squash,no_subtree_check)" >> /etc/exports
echo "/primary *(rw,async,no_root_squash,no_subtree_check)" >> /etc/exports
exportfs -a

sed -i "s/#LOCKD_TCPPORT=32803/LOCKD_TCPPORT=32803/" /etc/sysconfig/nfs
sed -i "s/#LOCKD_UDPPORT=32769/LOCKD_UDPPORT=32769/" /etc/sysconfig/nfs
sed -i "s/#MOUNTD_PORT=892/MOUNTD_PORT=892/" /etc/sysconfig/nfs
sed -i "s/#STATD_PORT=662/STATD_PORT=662/" /etc/sysconfig/nfs
sed -i "s/#STATD_OUTGOING_PORT=2020/STATD_OUTGOING_PORT=2020/" /etc/sysconfig/nfs
echo "RQUOTAD_PORT=875" >> /etc/sysconfig/nfs

# required for NFSv4
sed -i "/^\[General\]/a\Domain = acs.demo.lab" /etc/idmapd.conf

# rules for NFS communication ports
echo "configuring nfs iptables"
sed -i "/^:OUTPUT ACCEPT \[0:0\]/a\-A INPUT -s 172.16.254.0/24 -m state --state NEW -p udp --dport 111 -j ACCEPT" /etc/sysconfig/iptables
sed -i "/^:OUTPUT ACCEPT \[0:0\]/a\-A INPUT -s 172.16.254.0/24 -m state --state NEW -p tcp --dport 111 -j ACCEPT" /etc/sysconfig/iptables
sed -i "/^:OUTPUT ACCEPT \[0:0\]/a\-A INPUT -s 172.16.254.0/24 -m state --state NEW -p tcp --dport 2049 -j ACCEPT" /etc/sysconfig/iptables
sed -i "/^:OUTPUT ACCEPT \[0:0\]/a\-A INPUT -s 172.16.254.0/24 -m state --state NEW -p udp --dport 2049 -j ACCEPT" /etc/sysconfig/iptables
sed -i "/^:OUTPUT ACCEPT \[0:0\]/a\-A INPUT -s 172.16.254.0/24 -m state --state NEW -p tcp --dport 32803 -j ACCEPT" /etc/sysconfig/iptables
sed -i "/^:OUTPUT ACCEPT \[0:0\]/a\-A INPUT -s 172.16.254.0/24 -m state --state NEW -p udp --dport 32769 -j ACCEPT" /etc/sysconfig/iptables
sed -i "/^:OUTPUT ACCEPT \[0:0\]/a\-A INPUT -s 172.16.254.0/24 -m state --state NEW -p tcp --dport 892 -j ACCEPT" /etc/sysconfig/iptables
sed -i "/^:OUTPUT ACCEPT \[0:0\]/a\-A INPUT -s 172.16.254.0/24 -m state --state NEW -p udp --dport 892 -j ACCEPT" /etc/sysconfig/iptables
sed -i "/^:OUTPUT ACCEPT \[0:0\]/a\-A INPUT -s 172.16.254.0/24 -m state --state NEW -p tcp --dport 875 -j ACCEPT" /etc/sysconfig/iptables
sed -i "/^:OUTPUT ACCEPT \[0:0\]/a\-A INPUT -s 172.16.254.0/24 -m state --state NEW -p udp --dport 875 -j ACCEPT" /etc/sysconfig/iptables
sed -i "/^:OUTPUT ACCEPT \[0:0\]/a\-A INPUT -s 172.16.254.0/24 -m state --state NEW -p tcp --dport 876 -j ACCEPT" /etc/sysconfig/iptables
sed -i "/^:OUTPUT ACCEPT \[0:0\]/a\-A INPUT -s 172.16.254.0/24 -m state --state NEW -p udp --dport 876 -j ACCEPT" /etc/sysconfig/iptables
sed -i "/^:OUTPUT ACCEPT \[0:0\]/a\-A INPUT -s 172.16.254.0/24 -m state --state NEW -p tcp --dport 662 -j ACCEPT" /etc/sysconfig/iptables
sed -i "/^:OUTPUT ACCEPT \[0:0\]/a\-A INPUT -s 172.16.254.0/24 -m state --state NEW -p udp --dport 662 -j ACCEPT" /etc/sysconfig/iptables
sed -i "/^:OUTPUT ACCEPT \[0:0\]/a\-A INPUT -s 172.16.254.0/24 -m state --state NEW -p tcp --dport 2020 -j ACCEPT" /etc/sysconfig/iptables
sed -i "/^:OUTPUT ACCEPT \[0:0\]/a\-A INPUT -s 172.16.254.0/24 -m state --state NEW -p udp --dport 2020 -j ACCEPT" /etc/sysconfig/iptables

# acs agent and ports
echo "configuring cloudstack iptables"
sed -i "/^:OUTPUT ACCEPT \[0:0\]/a\-A INPUT -s 172.16.254.0/24 -m state --state NEW -p tcp --dport 8096 -j ACCEPT" /etc/sysconfig/iptables
sed -i "/^:OUTPUT ACCEPT \[0:0\]/a\-A INPUT -s 172.16.254.0/24 -m state --state NEW -p tcp --dport 3922 -j ACCEPT" /etc/sysconfig/iptables
sed -i "/^:OUTPUT ACCEPT \[0:0\]/a\-A INPUT -s 172.16.254.0/24 -m state --state NEW -p tcp --dport 8250 -j ACCEPT" /etc/sysconfig/iptables
systemctl restart iptables

# configure mysql
echo "configuring mysql"
sed -i "/^\[mysqld\]/a\innodb_rollback_on_timeout=1" /etc/my.cnf
sed -i "/^\[mysqld\]/a\innodb_lock_wait_timeout=600" /etc/my.cnf
sed -i "/^\[mysqld\]/a\max_connections=700" /etc/my.cnf
sed -i "/^\[mysqld\]/a\log-bin=mysql-bin" /etc/my.cnf
sed -i "/^\[mysqld\]/a\binlog-format='ROW'" /etc/my.cnf
sed -i "/^\[mysqld\]/a\expire_logs_days=10" /etc/my.cnf
sed -i "/^\[mysqld\]/a\max_binlog_size=100M" /etc/my.cnf
sed -i "/^\[mysqld\]/a\skip-name-resolve" /etc/my.cnf

# start/enable required services
echo "starting / bouncing services"
systemctl enable ntpd
systemctl start ntpd
systemctl enable rpcbind
systemctl stop rpcbind
systemctl start rpcbind
systemctl enable nfs-server
systemctl stop nfs-server
systemctl start nfs-server
systemctl enable mariadb
systemctl start mariadb

# setup cloudstack database
echo "setting up cloudstack database"
cloudstack-setup-databases cloud:password@localhost --deploy-as=root

# configure a vm template
mysql -u cloud -ppassword cloud --exec "UPDATE cloud.vm_template SET url='http://172.16.254.1/macchinina-kvm.qcow2.bz2', guest_os_id=140, name='tiny linux kvm', display_text='tiny linux kvm', hvm=1 where id=4;"

# setup cloudstack management service
echo "setting up cloudstack managment server"
cloudstack-setup-management --tomcat7

# install the systemvm template
echo "installing the default system vm template"
/usr/share/cloudstack-common/scripts/storage/secondary/cloud-install-sys-tmplt \
-m /secondary \
-u http://cloudstack.apt-get.eu/systemvm/4.6/systemvm64template-4.6.0-kvm.qcow2.bz2 \
-h kvm -F
