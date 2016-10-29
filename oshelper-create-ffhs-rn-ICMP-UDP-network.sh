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
echo "** Creates the ICMP/UDP      **"
echo "** network setup for the     **"
echo "** RN Module 3               **"
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

# Create Instances R1, A and B
echo -e "--> Creating Instance R1...\c"
nova boot --security-groups default,SSH_INGRESS --flavor c1.medium --image ae13a837-4c1d-4f8a-a716-021e33a8bdbf --key-name generic_keypair R1 > $LOG_PATH/R1.log
echo "done."

echo -e "--> Creating Instance A...\c"
nova boot --security-groups default,SSH_INGRESS --flavor c1.medium --image ae13a837-4c1d-4f8a-a716-021e33a8bdbf --key-name generic_keypair A > $LOG_PATH/A.log
echo "done."

echo -e "--> Creating Instance B...\c"
nova boot --security-groups default,SSH_INGRESS --flavor c1.medium --image ae13a837-4c1d-4f8a-a716-021e33a8bdbf --key-name generic_keypair B > $LOG_PATH/B.log
echo "done."

# Create Networks
echo -e "--> Creating Networks NetA, NetB...\c"
neutron net-create --port_security_enabled=False --router:external=False NetA > $NETWORK_PATH
neutron net-create --port_security_enabled=False --router:external=False NetB >> $NETWORK_PATH
echo "done."

# Create Ports
echo -e "--> Creating Ports NetA_Port_R1 on NetA, NetB_Port_R1 on NetB, NetB_Port_R2 on NetB, NetC_Port_R2 on NetC and NetD_Port_R2 on NetD...\c"
neutron port-create --name NetA_Port_A --fixed-ip 192.168.0.2 NetA > $PORT_PATH
neutron port-create --name NetB_Port_B --fixed-ip 172.16.0.2 NetB >> $PORT_PATH
neutron port-create --name NetA_Port_R1 --fixed-ip 192.168.0.1 NetA >> $PORT_PATH
neutron port-create --name NetB_Port_R1 --fixed-ip 172.16.0.1 NetB >> $PORT_PATH
echo "done."

# Attach Ports to Instances
echo 
echo "Attaching Instances to Network..."
echo "================================="
echo -e "--> Instance R1 <--> NetA_Port_R1 <--> NetA...\c"
nova interface-attach --port-id `neutron port-show NetA_Port_R1 -c id -f value` R1 > $ATTACH_PATH
echo "ok."

echo -e "--> Instance R1 <--> NetB_Port_R1 <--> NetB...\c"
nova interface-attach --port-id `neutron port-show NetB_Port_R1 -c id -f value` R1 > $ATTACH_PATH
echo "ok."

echo -e "--> Instance A <--> NetA_Port_A <--> NetA...\c"
nova interface-attach --port-id `neutron port-show NetA_Port_A -c id -f value` A >> $ATTACH_PATH
echo "ok."

echo -e "--> Instance B <--> NetB_Port_B <--> NetB...\c"
nova interface-attach --port-id `neutron port-show NetB_Port_B -c id -f value` B >> $ATTACH_PATH
echo "ok."

echo
echo "Finished"
