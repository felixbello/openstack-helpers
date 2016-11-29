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
echo "** Creates the ROUTING       **"
echo "** network setup for the     **"
echo "** RN Module 4               **"
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

# Create Instances R1, R2, R3, PC1, PC2 and PC3
echo -e "--> Creating Instance R1...\c"
nova boot --security-groups default,SSH_INGRESS --flavor c1.medium --image ae13a837-4c1d-4f8a-a716-021e33a8bdbf --key-name generic_keypair R1 > $LOG_PATH/R1.log
echo "done."

echo -e "--> Creating Instance R2...\c"
nova boot --security-groups default,SSH_INGRESS --flavor c1.medium --image ae13a837-4c1d-4f8a-a716-021e33a8bdbf --key-name generic_keypair R2 > $LOG_PATH/R2.log
echo "done."

echo -e "--> Creating Instance R3...\c"
nova boot --security-groups default,SSH_INGRESS --flavor c1.medium --image ae13a837-4c1d-4f8a-a716-021e33a8bdbf --key-name generic_keypair R3 > $LOG_PATH/R3.log
echo "done."

echo -e "--> Creating Instance PC1...\c"
nova boot --security-groups default,SSH_INGRESS --flavor c1.medium --image ae13a837-4c1d-4f8a-a716-021e33a8bdbf --key-name generic_keypair PC1 > $LOG_PATH/PC1.log
echo "done."

echo -e "--> Creating Instance PC2...\c"
nova boot --security-groups default,SSH_INGRESS --flavor c1.medium --image ae13a837-4c1d-4f8a-a716-021e33a8bdbf --key-name generic_keypair PC2 > $LOG_PATH/PC2.log
echo "done."

echo -e "--> Creating Instance PC3...\c"
nova boot --security-groups default,SSH_INGRESS --flavor c1.medium --image ae13a837-4c1d-4f8a-a716-021e33a8bdbf --key-name generic_keypair PC3 > $LOG_PATH/PC3.log
echo "done."

# Create Networks
echo -e "--> Creating Networks NetPC1R1, NetR1R2, NetR1R3, NetR2R3, NetR2PC2, NetR3PC3...\c"
neutron net-create --port_security_enabled=False --router:external=False NetPC1R1 > $NETWORK_PATH
neutron net-create --port_security_enabled=False --router:external=False NetR1R2 >> $NETWORK_PATH
neutron net-create --port_security_enabled=False --router:external=False NetR1R3 >> $NETWORK_PATH
neutron net-create --port_security_enabled=False --router:external=False NetR2R3 >> $NETWORK_PATH
neutron net-create --port_security_enabled=False --router:external=False NetR2PC2 >> $NETWORK_PATH
neutron net-create --port_security_enabled=False --router:external=False NetR3PC3 >> $NETWORK_PATH
echo "done."

# Create Ports
echo -e "--> Creating Ports...\c"
neutron port-create --name Port_PC1_NetPC1R1 NetPC1R1 > $PORT_PATH

neutron port-create --name Port_R1_NetPC1R1 NetPC1R1 > $PORT_PATH
neutron port-create --name Port_R1_NetR1R2 NetR1R2 > $PORT_PATH
neutron port-create --name Port_R1_NetR1R3 NetR1R3 > $PORT_PATH

neutron port-create --name Port_R2_NetR1R2 NetR1R2 > $PORT_PATH
neutron port-create --name Port_R2_NetR2R3 NetR2R3 > $PORT_PATH
neutron port-create --name Port_R2_NetR2PC2 NetR2PC2 > $PORT_PATH

neutron port-create --name Port_R3_NetR1R3 NetR1R3 > $PORT_PATH
neutron port-create --name Port_R3_NetR2R3 NetR2R3 > $PORT_PATH
neutron port-create --name Port_R3_NetR3PC3 NetR3PC3 > $PORT_PATH

neutron port-create --name Port_PC2_NetR2PC2 NetR2PC2 > $PORT_PATH
neutron port-create --name Port_PC3_NetR3PC3 NetR3PC3 > $PORT_PATH^
echo "done."

# Attach Ports to Instances
echo 
echo "Attaching Instances to Network..."
echo "================================="

echo -e "--> Instance PC1 <--> Port_PC1_NetPC1R1 <--> NetPC1R1...\c"
nova interface-attach --port-id `neutron port-show Port_PC1_NetPC1R1 -c id -f value` PC1 > $ATTACH_PATH
echo "ok."


echo -e "--> Instance R1 <--> Port_R1_NetPC1R1 <--> NetPC1R1...\c"
nova interface-attach --port-id `neutron port-show Port_R1_NetPC1R1 -c id -f value` R1 > $ATTACH_PATH
echo "ok."

echo -e "--> Instance R1 <--> Port_R1_NetR1R2 <--> NetR1R2...\c"
nova interface-attach --port-id `neutron port-show Port_R1_NetR1R2 -c id -f value` R1 > $ATTACH_PATH
echo "ok."

echo -e "--> Instance R1 <--> Port_R1_NetR1R3 <--> NetR1R3...\c"
nova interface-attach --port-id `neutron port-show Port_R1_NetR1R3 -c id -f value` R1 > $ATTACH_PATH
echo "ok."


echo -e "--> Instance R2 <--> Port_R2_NetR1R2 <--> NetR1R2...\c"
nova interface-attach --port-id `neutron port-show Port_R2_NetR1R2 -c id -f value` R2 > $ATTACH_PATH
echo "ok."

echo -e "--> Instance R2 <--> Port_R2_NetR2R3 <--> NetR2R3...\c"
nova interface-attach --port-id `neutron port-show Port_R2_NetR2R3 -c id -f value` R2 > $ATTACH_PATH
echo "ok."

echo -e "--> Instance R2 <--> Port_R2_NetR2PC2 <--> NetR2PC2...\c"
nova interface-attach --port-id `neutron port-show Port_R2_NetR2PC2 -c id -f value` R2 > $ATTACH_PATH
echo "ok."


echo -e "--> Instance R3 <--> Port_R3_NetR1R3 <--> NetR1R3...\c"
nova interface-attach --port-id `neutron port-show Port_R3_NetR1R3 -c id -f value` R3 > $ATTACH_PATH
echo "ok."

echo -e "--> Instance R3 <--> Port_R3_NetR2R3 <--> NetR2R3...\c"
nova interface-attach --port-id `neutron port-show Port_R3_NetR2R3 -c id -f value` R3 > $ATTACH_PATH
echo "ok."

echo -e "--> Instance R3 <--> Port_R3_NetR3PC3 <--> NetR3PC3...\c"
nova interface-attach --port-id `neutron port-show Port_R3_NetR3PC3 -c id -f value` R3 > $ATTACH_PATH
echo "ok."


echo -e "--> Instance PC2 <--> Port_PC2_NetR2PC2 <--> NetR2PC2...\c"
nova interface-attach --port-id `neutron port-show Port_PC2_NetR2PC2 -c id -f value` PC2 > $ATTACH_PATH
echo "ok."

echo -e "--> Instance PC3 <--> Port_PC3_NetR3PC3 <--> NetR3PC3...\c"
nova interface-attach --port-id `neutron port-show Port_PC3_NetR3PC3 -c id -f value` PC3 > $ATTACH_PATH
echo "ok."


echo
echo "Finished"
