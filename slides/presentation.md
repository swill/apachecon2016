# Cloud: Zero to Sixty

### Deploy your own cloud

Will Stevens  
VP @ Apache CloudStack  
Lead Developer @ CloudOps  

Follow Along: `github.com/swill/apachecon2016`


---

## Straight into the weeds

We will be configuring an Apache CloudStack (ACS) cloud on my laptop using VMware Fusion.  

<img src="./img/network_architecture_tight.png" alt="network_architecture" width="700" />


---

## Upstream Networking

The ACS environment will be connected to my Mac's network through a VyOS router.

![vyos_network](./img/vyos_network.png)

`./vyos/01_configure.sh`

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

ACS Management node.  
ACS MySQL database node.  
NFS for Primary and Secondary storage.  

![acs_network](./img/acs_network.png)

`./acs/01_network_config.sh`
`./acs/02_install_acs.sh`

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

## ACS & KVM

ACS orchestrates the resources on the KVM Host.

![acs_kvm](./img/acs_kvm.png)

ACS Mgmt mimics a SAN for Primary and Secondary storage.


---

## Deploy Datacenter

ACS and KVM are both ready to go now.

- Setup Zone, Pod, Cluster and KVM Host.
- Configure the orchestrated network ranges.
- Start System VMs (SSVM + Console)

`./acs/03_configure_zone.sh`


---

## Lets Review

![network_architecture_tight](./img/network_architecture_tight.png)
