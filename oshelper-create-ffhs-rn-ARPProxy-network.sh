#!/bin/bash

# SETTINGS
LOG_PATH=created_objects
NETWORK_PATH=$LOG_PATH/network.log
SUBNET_PATH=$LOG_PATH/subnets.log
PORT_PATH=$LOG_PATH/ports.log
SECURITY_PATH=$LOG_PATH/security_groups.log
ATTACH_PATH=$LOG_PATH/attach.log

echo
echo
echo "*******************************"
echo "** Open Stack Client Helpers **"
echo "**                           **"
echo "**   FFHS RN Setup Runner    **"
echo "**                           **"
echo "** Creates the ARP Proxy     **"
echo "** network setup for the     **"
echo "** RN Module 2               **"
echo "*******************************"
echo

echo -e "Please specify the path to your public SSH-Key, leave blank to use default '~/.ssh/id_rsa.pub' > \c"
read $PATH_SSH_KEY
if ! [ $PATH_SSH_KEY ]; then PATH_SSH_KEY=~/.ssh/id_rsa.pub; fi
 
# Make sure log directory exists and is empty
mkdir -p $LOG_PATH
rm $LOG_PATH/* 2>/dev/null

# Create SSH Security Group
echo -e "--> Creating SSH Port 22 Security Group...\c"
neutron security-group-create SSH_INGRESS > $SECURITY_PATH 
neutron security-group-rule-create --direction ingress --ethertype IPv4 --protocol tcp --port-range-min 22 --port-range-max 22 SSH_INGRESS >> $SECURITY_PATH
echo "done."

# Create SSH Keypair
echo -e "--> Creating SSH Keypair using $PATH_SSH_KEY ...\c"
nova keypair-add --pub-key $PATH_SSH_KEY generic_keypair
echo "done."

# Create Instances R1 & R2
echo -e "--> Creating Instance INTERNET...\c"
nova boot --security-groups default,SSH_INGRESS --flavor c1.medium --image ae13a837-4c1d-4f8a-a716-021e33a8bdbf --key-name generic_keypair INTERNET > $LOG_PATH/INTERNET.log
echo "done."

echo -e "--> Creating Instance ARP_PROXY...\c"
nova boot --security-groups default,SSH_INGRESS --flavor c1.medium --image ae13a837-4c1d-4f8a-a716-021e33a8bdbf --key-name generic_keypair ARP_PROXY > $LOG_PATH/ARP_PROXY.log
echo "done."

echo -e "--> Creating Instance H1_NetA...\c"
nova boot --security-groups default,SSH_INGRESS --flavor c1.medium --image ae13a837-4c1d-4f8a-a716-021e33a8bdbf --key-name generic_keypair H1_NetA > $LOG_PATH/H1_NetA.log
echo "done."

echo -e "--> Creating Instance H2_NetB...\c"
nova boot --security-groups default,SSH_INGRESS --flavor c1.medium --image ae13a837-4c1d-4f8a-a716-021e33a8bdbf --key-name generic_keypair H2_NetB > $LOG_PATH/H2_NetB.log
echo "done."

echo -e "--> Creating Instance H3_NetC...\c"
nova boot --security-groups default,SSH_INGRESS --flavor c1.medium --image ae13a837-4c1d-4f8a-a716-021e33a8bdbf --key-name generic_keypair H3_NetC > $LOG_PATH/H3_NetC.log
echo "done."

# Create Networks
echo -e "--> Creating Networks NetA, NetB, NetC and NetD...\c"
neutron net-create --port_security_enabled=False --router:external=False NetA > $NETWORK_PATH
neutron net-create --port_security_enabled=False --router:external=False NetB >> $NETWORK_PATH
neutron net-create --port_security_enabled=False --router:external=False NetC >> $NETWORK_PATH
neutron net-create --port_security_enabled=False --router:external=False NetD >> $NETWORK_PATH
echo "done."

# Create Subnets
echo -e "--> Creating Subnets NetA_Sub1, NetB_Sub1, NetC_Sub1 and NetD_Sub1...\c"
neutron subnet-create --name NetA_Sub1 --no-gateway --disable-dhcp NetA 192.168.0.0/24 > $SUBNET_PATH
neutron subnet-create --name NetB_Sub1 --no-gateway --disable-dhcp NetB 172.10.20.128/25 >> $SUBNET_PATH
neutron subnet-create --name NetC_Sub1 --no-gateway --disable-dhcp NetC 172.10.21.128/25 >> $SUBNET_PATH
neutron subnet-create --name NetD_Sub1 --no-gateway --disable-dhcp NetD 172.10.21.0/25 >> $SUBNET_PATH
echo "done."

# Create Ports
echo -e "--> Creating Ports NetA_Port_R1 on NetA, NetB_Port_R1 on NetB, NetB_Port_R2 on NetB, NetC_Port_R2 on NetC and NetD_Port_R2 on NetD...\c"
neutron port-create --name NetA_Port_INTERNET --fixed-ip subnet_id=NetA_Sub1,ip_address=192.168.0.250 NetA > $PORT_PATH
neutron port-create --name NetB_Port_INTERNET --fixed-ip subnet_id=NetB_Sub1,ip_address=172.10.20.129 NetB >> $PORT_PATH
neutron port-create --name NetB_Port_ARP_PROXY --fixed-ip subnet_id=NetB_Sub1,ip_address=172.10.20.200 NetB >> $PORT_PATH
neutron port-create --name NetC_Port_ARP_PROXY --fixed-ip subnet_id=NetC_Sub1,ip_address=172.10.21.200 NetC >> $PORT_PATH
neutron port-create --name NetD_Port_ARP_PROXY NetD >> $PORT_PATH

neutron port-create --name NetA_Port_H1_NetA --fixed-ip subnet_id=NetA_Sub1,ip_address=192.168.0.251 NetA > $PORT_PATH
neutron port-create --name NetB_Port_H2_NetB --fixed-ip subnet_id=NetB_Sub1,ip_address=172.10.20.201 NetB >> $PORT_PATH
neutron port-create --name NetC_Port_H3_NetC --fixed-ip subnet_id=NetC_Sub1,ip_address=172.10.21.202 NetC >> $PORT_PATH

echo "done."

# Attach Ports to Instances
echo 
echo "Attaching Instances to Network..."
echo "================================="
echo -e "--> Instance INTERNET <--> NetA_Port_INTERNET <--> NetA...\c"
nova interface-attach --port-id `neutron port-show NetA_Port_INTERNET -c id -f value` INTERNET > $ATTACH_PATH
echo "ok."

echo -e "--> Instance INTERNET <--> NetB_Port_INTERNET <--> NetB...\c"
nova interface-attach --port-id `neutron port-show NetB_Port_INTERNET -c id -f value` INTERNET >> $ATTACH_PATH
echo "ok."

echo -e "--> Instance ARP_PROXY <--> NetB_Port_ARP_PROXY <--> NetB...\c"
nova interface-attach --port-id `neutron port-show NetB_Port_ARP_PROXY -c id -f value` ARP_PROXY >> $ATTACH_PATH
echo "ok."

echo -e "--> Instance ARP_PROXY <--> NetC_Port_ARP_PROXY <--> NetC...\c"
nova interface-attach --port-id `neutron port-show NetC_Port_ARP_PROXY -c id -f value` ARP_PROXY >> $ATTACH_PATH
echo "ok."

echo -e "--> Instance ARP_PROXY <--> NetD_Port_ARP_PROXY <--> NetD...\c"
nova interface-attach --port-id `neutron port-show NetD_Port_ARP_PROXY -c id -f value` ARP_PROXY >> $ATTACH_PATH
echo "ok." 

echo -e "--> Instance H1_NetA <--> NetA_Port_H1_NetA <--> NetA...\c"
nova interface-attach --port-id `neutron port-show NetA_Port_H1_NetA -c id -f value` H1_NetA >> $ATTACH_PATH
echo "ok." 

echo -e "--> Instance H2_NetB <--> NetB_Port_H2_NetB <--> NetB...\c"
nova interface-attach --port-id `neutron port-show NetB_Port_H2_NetB -c id -f value` H2_NetB >> $ATTACH_PATH
echo "ok." 

echo -e "--> Instance H3_NetC <--> NetC_Port_H3_NetC <--> NetC...\c"
nova interface-attach --port-id `neutron port-show NetC_Port_H3_NetC -c id -f value` H3_NetC >> $ATTACH_PATH
echo "ok." 

echo
echo "Finished"


