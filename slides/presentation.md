# Cloud: Zero to Sixty

## Deploy a cloud in 40 mins

**Will Stevens&nbsp;&nbsp;<img src="./img/twitter.png" alt="@" style="border:0; width:30px; margin:0; background:none; box-shadow:none;" />&nbsp;&nbsp;@swillops**  

VP @ Apache CloudStack  
Lead Developer @ CloudOps  

[`github.com/swill/apachecon2016`](https://github.com/swill/apachecon2016)


---

## On The Menu

We will be configuring an Apache CloudStack (ACS) cloud on my laptop using VMware Fusion.  

<img src="./img/network_architecture_tight.png" alt="network_architecture" width="700" />


---

## Upstream Networking

The ACS environment will be connected to my Mac's network through a VyOS router.

![vyos_network](./img/vyos_network.png)

`./vyos/01_configure.sh`

___

## VyOS Duties

- The network uplink for the entire environment.
- Gateway for both Management and Public networks.
- Edge firewall.  In this case just a pass through.
- Firewall to protect the Management network.

___

## VyOS VM Resources

Small VM since we don't expect much load.

![vmware_vyos_resources](./img/vmware_vyos_resources.png)

___

## Internet NIC (eth0)

![vmware_vyos_network1](./img/vmware_vyos_network1.png)

___

## ACS Public NIC (eth1)

![vmware_vyos_network2](./img/vmware_vyos_network2.png)

___

## ACS Management NIC (eth2)

![vmware_vyos_network3](./img/vmware_vyos_network3.png)


---

## ACS Management VM

ACS Management node, MySQL and NFS mounts.

![acs_network](./img/acs_network.png)

`./acs/01_network_config.sh`
`./acs/02_install_acs.sh`

___

## ACS Management Duties

- Management entry point for both Web and API.
- Orchestrates all the host compute resources.
- Orchestrates the Guest and Public networks.
- Orchestrates VM storage (Root and Data).
- Our Case: MySQL database for ACS.
- Our Case: NFS mounts for storage.

___

## ACS Management VM Resources

Restricted by the size of my laptop obviously.

![vmware_acs_resources](./img/vmware_acs_resources.png)

___

## ACS Management NIC (eth0)

![vmware_acs_networking](./img/vmware_acs_networking.png)


---

## KVM Hypervisor VM

KVM Hypervisor Host for ACS to orchestrate.

![kvm_network](./img/kvm_network.png)

`./kvm/01_network_config.sh`
`./kvm/02_install_kvm.sh`

___

## KVM Duties

- Provide compute resources to be orchestrated.
- Hosts the System VMs (more on this later).
- Guest network isolation and hosts the Guest VRs.
- Implements the snapshotting functionality.
- Implements the VM recovery point feature.

___

## KVM Host VM Resources

Again, very limited due to the size of my Mac.

<img src="./img/vmware_kvm_resources.png" alt="vmware_kvm_resources" width="600" />

___

## ACS Management NIC (eth0 / cloudbr0)

![vmware_kvm_network1](./img/vmware_kvm_network1.png)

___

## ACS Public NIC (eth1 / cloudbr1)

![vmware_kvm_network2](./img/vmware_kvm_network2.png)

___

## ACS Guest NIC (eth2 / cloudbr2)

![vmware_kvm_network3](./img/vmware_kvm_network3.png)


---

## Deploy Datacenter

ACS and KVM are both ready to go now, but not configured...

- Setup Zone, Pod, Cluster and KVM Host.
- Configure the orchestrated network ranges.
- Start System VMs (SSVM + Console)

`./acs/03_configure_zone.sh`

___

![architecture_overview](./img/architecture_overview.png)

___

## Functional Groupings

- Region: A grouping of Zones.
- Zone: Usually a single data center.
	- Secondary Storage, Guest & Public IP Ranges
- Pod: Usually a rack with one or more Clusters.
	- Management Network, Cluster connectivity
- Cluster: A group of hosts of the same hypervisor type.
	- Primary Storage
- Host: The actual hypervisor host being orchestrated.
	- VMware, XenServer, KVM, HyperV


---

## Architecture Review

![network_architecture_tight](./img/network_architecture_tight.png)


---

## ACS & KVM

ACS orchestrates the resources on the KVM Host.

![acs_kvm](./img/acs_kvm.png)

___

## More Details

- ACS Mgmt is exposing Primary Storage over NFS.
- ACS Mgmt is exposing Secondary Storage over NFS.
- KVM hosts the guest VMs provisioned by ACS.
- KVM hosts the Guest networks provisioned by ACS.
- KVM hosts the System VMs (SSVM + Console VM).

___

## Secondary Storage VM (SSVM)

Handles everything related to templates and snapshots.

- Transfer snapshots from Primary to Secondary storage.
- Converting snapshots to templates to launch VMs.
- Uploading and exposing templates to launch guest VMs.

___

## Console Proxy VM

Exposes VM consoles through a web UI.

<img src="./img/console_proxy.png" alt="console_proxy" width="700" />


---

## Let's Go Explore...

<a href="http://172.16.254.10:8080/client/" target="_blank"><code>172.16.254.10:8080/client</code></a>


---

## CloudStack Advanced Networking

![advanced_networking](./img/advanced_networking.png)

___

## Isolated Guest Networks

- Single tier network.
- Network Features:
	- Source Nat
	- Static Nat
	- Port Forwarding
	- Load Balancing
	- Firewall Rules (Ingress & Egress)
	- DHCP & DNS
	- Remote Access VPN

___

## VPC Networks

- Multi-tier network.
- Network Features:
	- Source Nat
	- Static Nat
	- Port Forwarding
	- Load Balancing
	- Network ACLs (like Firewall Rules)
	- DHCP & DNS
	- Remote Access VPN
	- Site-to-Site VPN
	- Private Gateways (datacenter connect)
		- Static Routes


---

# Questions?
