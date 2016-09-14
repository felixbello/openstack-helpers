# Openstack Helpers

This is a small collection of Shell-Scripts to help with creating and removing Open Stack Environments. 

## Preparations
To use these scripts, you need to have the OpenStack-Client installed on your computer. See [How to install OpenStack CLI Client](http://docs.openstack.org/user-guide/common/cli-install-openstack-command-line-clients.html).
Once installed, make sure that you have sourced your openrc.sh file so that the nova and neutron tools are able to connect to your OpenStack Server.

## Usage
### Create FFHS RN Module Basic Network Setup
To automatically create the Basic Network Setup as described in the FFHS RN ("Rechnernetze") course, execute the following Shell-Script:
```bash
$ ./oshelper-create-ffhs-rn-network.sh
```
This will generate the following things:
* A Security Group called `SSH_INGRESS` with a tcp/22 rule.
* An SSH Keypair with a public key of your choice (default: ~/.ssh/id_rsa.pub)
* Instances R1 and R2 with 2048Mb, 20Gb, 2CPUs and Debian Jessie 8.1
* Networks NetA, NetB, NetC and NetD
* Subnets NetA_Sub1, NetB_Sub2, NetC_Sub3 and NetD_Sub4
* Ports NetA_Port1_R1, NetB_Port1_R1, NetB_Port2_R2, NetC_Port1_R2, NetD_Port1_R2
* Connect the Networks with the instances via the Ports

### Remove FFHS RN Module Basic Network Setup
To automatically remove all items of the setup, run the following Shell-Script:
```bash
$ ./oshelper-remove-ffhs-rn-network.sh
```
This removes all items in reverse order of the previously mentioned `create` command.

### Generic Removal-Script
There is also a simple removal script that will remove ALL instances, networks, subnets and ports there are on your OpenStack Server. Use with caution!
```bash
$ ./oshelper-erase-all.sh
```

## Disclaimer
Using these scripts is at your own risk. I do not take any responsibility for any effects or damages that could arise from using the scripts!


