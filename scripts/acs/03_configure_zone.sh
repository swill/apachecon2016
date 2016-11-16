#!/usr/bin/env bash

### FOR THE DEMO I MOVED THIS TO `00_update_os.sh` BECAUSE NETWORK IS SLOW!!!
## install marvin requirements
#echo "installing packages"
#yum -y install gcc libffi-devel nmap-ncat openssl-devel python-cffi python-devel python-pip

# get and install marvin
wget -P /tmp/ http://172.16.254.1/marvin/Marvin-4.9.0.tar.gz
wget -P /tmp/ http://172.16.254.1/marvin/deployDataCenter.py
pip install --upgrade /tmp/Marvin-*.tar.gz

# turn on the api authentication port
echo "updating database to push details required to script zone creation"
mysql -u cloud -ppassword cloud --exec "UPDATE cloud.configuration SET value='8096' where name='integration.api.port';"

# setup the correct host for the acs server in global configs
mysql -u cloud -ppassword cloud --exec "UPDATE cloud.configuration SET value='172.16.254.10' where name='host';"

# restart the cloudstack managment server and make sure it goes down
echo "restarting cloudstack-management service..."
systemctl stop cloudstack-management
systemctl stop cloudstack-management # known bug
systemctl start cloudstack-management

# make sure the service is back up before we try to deploy the configuration
echo "waiting for cloudstack-management to restart..."
sleep 15
while ! nc -w 2 172.16.254.10 8080 </dev/null; do
  sleep 10
done
echo "cloudstack-management service is back..."

# deploy the zone using marvin
echo "setting the datacenter in cloudstack"
python /tmp/deployDataCenter.py -i demo.cfg

# turn off the api authentication port
mysql -u cloud -ppassword cloud --exec "UPDATE cloud.configuration SET value=NULL where name='integration.api.port';"

# restart the cloudstack managment server and make sure it goes down
echo "restarting cloudstack-management service..."
systemctl stop cloudstack-management
systemctl stop cloudstack-management # known bug
systemctl start cloudstack-management

# make sure the service is back up before we try to deploy the configuration
echo "waiting for cloudstack-management to restart..."
sleep 15
while ! nc -w 2 172.16.254.10 8080 </dev/null; do
  sleep 10
done
echo "cloudstack-management service is back..."

