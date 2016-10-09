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
echo "** Creates the ARP network   **"
echo "** setup for the RN Module 2 **"
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
echo -e "--> Creating Instance R1...\c"
nova boot --security-groups default,SSH_INGRESS --flavor c1.medium --image ae13a837-4c1d-4f8a-a716-021e33a8bdbf --key-name generic_keypair R1 > $LOG_PATH/R1.log
echo "done."

echo -e "--> Creating Instance R2...\c"
nova boot --security-groups default,SSH_INGRESS --flavor c1.medium --image ae13a837-4c1d-4f8a-a716-021e33a8bdbf --key-name generic_keypair R2 > $LOG_PATH/R2.log
echo "done."

echo -e "--> Creating Instance A...\c"
nova boot --security-groups default,SSH_INGRESS --flavor c1.medium --image ae13a837-4c1d-4f8a-a716-021e33a8bdbf --key-name generic_keypair A > $LOG_PATH/R2.log
echo "done."

echo -e "--> Creating Instance C...\c"
nova boot --security-groups default,SSH_INGRESS --flavor c1.medium --image ae13a837-4c1d-4f8a-a716-021e33a8bdbf --key-name generic_keypair C > $LOG_PATH/R2.log
echo "done."

echo -e "--> Creating Instance D...\c"
nova boot --security-groups default,SSH_INGRESS --flavor c1.medium --image ae13a837-4c1d-4f8a-a716-021e33a8bdbf --key-name generic_keypair D > $LOG_PATH/R2.log
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
neutron subnet-create --name NetC_Sub1 --no-gateway --disable-dhcp NetC 172.10.21.0/25 >> $SUBNET_PATH
neutron subnet-create --name NetD_Sub1 --no-gateway --disable-dhcp NetD 172.10.21.128/25 >> $SUBNET_PATH
echo "done."

# Create Ports
echo -e "--> Creating Ports NetA_Port_R1 on NetA, NetB_Port_R1 on NetB, NetB_Port_R2 on NetB, NetC_Port_R2 on NetC and NetD_Port_R2 on NetD...\c"
neutron port-create --name NetA_Port_R1 --fixed-ip subnet_id=NetA_Sub1,ip_address=192.168.0.22 NetA > $PORT_PATH
neutron port-create --name NetB_Port_R1 --fixed-ip subnet_id=NetB_Sub1,ip_address=172.10.20.144 NetB >> $PORT_PATH
neutron port-create --name NetB_Port_R2 NetB >> $PORT_PATH
neutron port-create --name NetC_Port_R2 NetC >> $PORT_PATH
neutron port-create --name NetD_Port_R2 NetD >> $PORT_PATH

neutron port-create --name NetA_Port_C --fixed-ip subnet_id=NetA_Sub1,ip_address=192.168.0.33 NetA > $PORT_PATH
neutron port-create --name NetA_Port_D --fixed-ip subnet_id=NetA_Sub1,ip_address=192.168.0.44 NetA >> $PORT_PATH
neutron port-create --name NetB_Port_A --fixed-ip subnet_id=NetB_Sub1,ip_address=172.10.20.133 NetB >> $PORT_PATH
echo "done."

# Attach Ports to Instances
echo 
echo "Attaching Instances to Network..."
echo "================================="
echo -e "--> Instance R1 <--> NetA_Port_R1 <--> NetA...\c"
nova interface-attach --port-id `neutron port-show NetA_Port_R1 -c id -f value` R1 > $ATTACH_PATH
echo "ok."

echo -e "--> Instance R1 <--> NetB_Port_R1 <--> NetB...\c"
nova interface-attach --port-id `neutron port-show NetB_Port_R1 -c id -f value` R1 >> $ATTACH_PATH
echo "ok."

echo -e "--> Instance R2 <--> NetB_Port_R2 <--> NetB...\c"
nova interface-attach --port-id `neutron port-show NetB_Port_R2 -c id -f value` R2 >> $ATTACH_PATH
echo "ok."

echo -e "--> Instance R2 <--> NetC_Port_R2 <--> NetC...\c"
nova interface-attach --port-id `neutron port-show NetC_Port_R2 -c id -f value` R2 >> $ATTACH_PATH
echo "ok."

echo -e "--> Instance R2 <--> NetD_Port_R2 <--> NetD...\c"
nova interface-attach --port-id `neutron port-show NetD_Port_R2 -c id -f value` R2 >> $ATTACH_PATH
echo "ok." 

echo -e "--> Instance A <--> NetB_Port_A <--> NetB...\c"
nova interface-attach --port-id `neutron port-show NetB_Port_A -c id -f value` A >> $ATTACH_PATH
echo "ok." 

echo -e "--> Instance C <--> NetA_Port_C <--> NetA...\c"
nova interface-attach --port-id `neutron port-show NetA_Port_C -c id -f value` C >> $ATTACH_PATH
echo "ok." 

echo -e "--> Instance D <--> NetA_Port_D <--> NetA...\c"
nova interface-attach --port-id `neutron port-show NetA_Port_D -c id -f value` D >> $ATTACH_PATH
echo "ok." 

echo
echo "Finished"


