#!/bin/bash

echo
echo
echo "*******************************"
echo "** Open Stack Client Helpers **"
echo "**                           **"
echo "**   FFHS RN Setup Cleaner   **"
echo "**                           **"
echo "** Removes the ROUTING       **"
echo "** network setup for the RN  **"
echo "** block 4                   **"
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

echo -e "--> Instance PC3 xxx Port_PC3_NetR3PC3 xxx NetR3PC3...\c"
nova interface-detach PC3 `neutron port-show Port_PC3_NetR3PC3 -c id -f value`
echo "ok."

echo -e "--> Instance PC2 xxx Port_PC2_NetR2PC2 xxx NetR2PC2...\c"
nova interface-detach PC2 `neutron port-show Port_PC2_NetR2PC2 -c id -f value`
echo "ok."


echo -e "--> Instance R3 xxx Port_R3_NetR3PC3 xxx NetR3PC3...\c"
nova interface-detach R3 `neutron port-show Port_PC3_NetR3PC3 -c id -f value`
echo "ok."

echo -e "--> Instance R3 xxx Port_R3_NetR2R3 xxx NetR2R3...\c"
nova interface-detach R3 `neutron port-show Port_R3_NetR2R3 -c id -f value`
echo "ok."

echo -e "--> Instance R3 xxx Port_R3_NetR1R3 xxx NetR1R3...\c"
nova interface-detach R3 `neutron port-show Port_R3_NetR1R3 -c id -f value`
echo "ok."


echo -e "--> Instance R2 xxx Port_R2_NetR2PC2 xxx NetR2PC2...\c"
nova interface-detach R2 `neutron port-show Port_R2_NetR2PC2 -c id -f value`
echo "ok."

echo -e "--> Instance R2 xxx Port_R2_NetR2R3 xxx NetR2R3...\c"
nova interface-detach R2 `neutron port-show Port_R2_NetR2R3 -c id -f value`
echo "ok."

echo -e "--> Instance R2 xxx Port_R2_NetR1R2 xxx NetR1R2...\c"
nova interface-detach R2 `neutron port-show Port_R2_NetR1R2 -c id -f value`
echo "ok."


echo -e "--> Instance R1 xxx Port_R1_NetR1R3 xxx NetR1R3...\c"
nova interface-detach R1 `neutron port-show Port_R1_NetR1R3 -c id -f value`
echo "ok."

echo -e "--> Instance R1 xxx Port_R1_NetR1R2 xxx NetR1R2...\c"
nova interface-detach R1 `neutron port-show Port_R1_NetR1R2 -c id -f value`
echo "ok."

echo -e "--> Instance R1 xxx Port_R1_NetPC1R1 xxx NetPC1R1...\c"
nova interface-detach R1 `neutron port-show Port_R1_NetPC1R1 -c id -f value`
echo "ok."


echo -e "--> Instance PC1 xxx Port_PC1_NetPC1R1 xxx NetPC1R1...\c"
nova interface-detach PC1 `neutron port-show Port_PC1_NetPC1R1 -c id -f value`
echo "ok."


# Delete Ports
echo
echo -e "--> Deleting Ports ...\c"
neutron port-delete Port_PC3_NetR3PC3
neutron port-delete Port_PC2_NetR2PC2

neutron port-delete Port_R3_NetR3PC3
neutron port-delete Port_R3_NetR2R3
neutron port-delete Port_R3_NetR1R3

neutron port-delete Port_R2_NetR2PC2
neutron port-delete Port_R2_NetR2R3
neutron port-delete Port_R2_NetR1R2

neutron port-delete Port_R1_NetR1R3
neutron port-delete Port_R1_NetR1R2
neutron port-delete Port_R1_NetPC1R1

neutron port-delete Port_PC1_NetPC1R3
echo "done."

# Delete Networks
echo
echo -e "--> Deleting Networks ...\c"
neutron net-delete NetR3PC3
neutron net-delete NetR2PC2
neutron net-delete NetR2R3
neutron net-delete NetR1R3
neutron net-delete NetR1R2
neutron net-delete NetPC1R1
echo "done."

# Delete Instances R1, A and B
echo
echo -e "--> Deleting Instance PC3...\c"
nova delete PC3
echo "done."

echo
echo -e "--> Deleting Instance PC2...\c"
nova delete PC2
echo "done."

echo
echo -e "--> Deleting Instance R3...\c"
nova delete R3
echo "done."

echo
echo -e "--> Deleting Instance R2...\c"
nova delete R2
echo "done."

echo
echo -e "--> Deleting Instance R1...\c"
nova delete R1
echo "done."

echo
echo -e "--> Deleting Instance PC1...\c"
nova delete PC1
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


