#!/bin/vbash
source /opt/vyatta/etc/functions/script-template

configure

## manual steps to be able to scp config file
#set service ssh port '22'
#set interfaces ethernet eth0 address 'dhcp'

set service ssh port '22'
set system host-name 'acs-vyos-router'
set system name-server '8.8.8.8'
set service dns forwarding cache-size '0'
set service dns forwarding listen-on 'eth1'
set service dns forwarding listen-on 'eth2'
set service dns forwarding name-server '8.8.8.8'
set service dns forwarding name-server '8.8.4.4'
set system time-zone 'UTC'
set interfaces ethernet eth0 address 'dhcp'
set interfaces ethernet eth0 duplex 'auto'
set interfaces ethernet eth0 speed 'auto'
set interfaces ethernet eth1 address '192.168.80.5/24'
set interfaces ethernet eth1 duplex 'auto'
set interfaces ethernet eth1 speed 'auto'
set interfaces ethernet eth2 address '172.16.254.5/24'
set interfaces ethernet eth2 duplex 'auto'
set interfaces ethernet eth2 speed 'auto'
set nat source rule 100 'destination'
set nat source rule 100 outbound-interface 'eth0'
set nat source rule 100 source address '192.168.80.0/24'
set nat source rule 100 translation address 'masquerade'
set nat source rule 200 'destination'
set nat source rule 200 outbound-interface 'eth0'
set nat source rule 200 source address '172.16.254.0/24'
set nat source rule 200 translation address 'masquerade'
set firewall name block-management 'enable-default-log'
set firewall name block-management rule 100 action 'drop'
set firewall name block-management rule 100 destination address '172.16.254.0/24'
set firewall name block-management rule 100 source address '192.168.80.0/24'
set interfaces ethernet eth1 firewall in name 'block-management'

commit
save
