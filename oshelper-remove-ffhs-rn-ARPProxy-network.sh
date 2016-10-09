#!/bin/bash

echo
echo
echo "*******************************"
echo "** Open Stack Client Helpers **"
echo "**                           **"
echo "**   FFHS RN Setup Cleaner   **"
echo "**                           **"
echo "** Removes the ARPProxy      **"
echo "** network setup for the RN  **"
echo "** block 2                   **"
echo "*******************************"
echo

echo -e "Are you sure you want to delete all Instances, Networks, Subnets, Ports, Security Groups and Keypairs of the FFHS RN Basic Network Setup? (Yes, this is the point of no return!)? [y/N] > \c"
read DO_IT

if ! [[ $DO_IT =~ [yY] ]]
then
        echo "Aborted deletion"
        exit 1
fi

# Detach Ports from Instances
echo 
echo "Detaching Instances from Network..."
echo "==================================="
echo -e "--> Instance INTERNET xxx NetA_Port_INTERNET xxx NetA...\c"
nova interface-detach INTERNET `neutron port-show NetA_Port_INTERNET -c id -f value`
echo "ok."

echo -e "--> Instance INTERNET xxx NetB_Port_INTERNET xxx NetB...\c"
nova interface-detach INTERNET `neutron port-show NetB_Port_INTERNET -c id -f value`
echo "ok."

echo -e "--> Instance ARP_PROXY xxx NetB_Port_ARP_PROXY xxx NetB...\c"
nova interface-detach ARP_PROXY `neutron port-show NetB_Port_ARP_PROXY -c id -f value`
echo "ok."

echo -e "--> Instance ARP_PROXY xxx NetC_Port_ARP_PROXY xxx NetC...\c"
nova interface-detach ARP_PROXY `neutron port-show NetC_Port_ARP_PROXY -c id -f value`
echo "ok."

echo -e "--> Instance ARP_PROXY xxx NetD_Port_ARP_PROXY xxx NetD...\c"
nova interface-detach ARP_PROXY `neutron port-show NetD_Port_ARP_PROXY -c id -f value`
echo "ok." 
echo

echo -e "--> Instance H1_NetA xxx NetA_Port_H1_NetA xxx NetA...\c"
nova interface-detach H1_NetA `neutron port-show NetA_Port_H1_NetA -c id -f value`
echo "ok." 
echo
echo -e "--> Instance H2_NetB xxx NetB_Port_H2_NetB xxx NetB...\c"
nova interface-detach H2_NetB `neutron port-show NetB_Port_H2_NetB -c id -f value`
echo "ok." 
echo
echo -e "--> Instance H3_NetC xxx NetC_Port_H3_NetC xxx NetC...\c"
nova interface-detach H3_NetC `neutron port-show NetC_Port_H3_NetC -c id -f value`
echo "ok." 
echo


# Delete Ports
echo
echo -e "--> Deleting Ports ...\c"
neutron port-delete NetA_Port_INTERNET 
neutron port-delete NetB_Port_INTERNET 
neutron port-delete NetB_Port_ARP_PROXY 
neutron port-delete NetC_Port_ARP_PROXY 
neutron port-delete NetD_Port_ARP_PROXY
neutron port-delete NetA_Port_H1_NetA
neutron port-delete NetB_Port_H2_NetB
neutron port-delete NetC_Port_H3_NetC

echo "done."

# Delete Subnets
echo
echo -e "--> Deleting Subnets NetA_Sub1, NetB_Sub1, NetC_Sub1 and NetD_Sub1...\c"
neutron subnet-delete NetA_Sub1
neutron subnet-delete NetB_Sub1
neutron subnet-delete NetC_Sub1
neutron subnet-delete NetD_Sub1
echo "done."

# Delete Networks
echo
echo -e "--> Deleting Networks NetA, NetB, NetC and NetD...\c"
neutron net-delete NetA
neutron net-delete NetB
neutron net-delete NetC
neutron net-delete NetD
echo "done."

# Delete Instances INTERNET & ARP_PROXY
echo
echo -e "--> Deleting Instance INTERNET...\c"
nova delete INTERNET
echo "done."

echo
echo -e "--> Deleting Instance ARP_PROXY...\c"
nova delete ARP_PROXY
echo "done."

echo
echo -e "--> Deleting Instance H1_NetA...\c"
nova delete H1_NetA
echo "done."

echo
echo -e "--> Deleting Instance H2_NetB...\c"
nova delete H2_NetB
echo "done."

echo
echo -e "--> Deleting Instance H3_NetC...\c"
nova delete H3_NetC
echo "done."


# Delete SSH Keypair
echo
echo -e "--> Deleting SSH Keypair...\c"
nova keypair-delete generic_keypair
echo "done."

# Delete SSH Security Group
echo
echo -e "--> Deleting SSH Port 22 Security Group...\c"
sleep 5
neutron security-group-delete SSH_INGRESS 
echo "done."

echo "Finished"


