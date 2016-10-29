#!/bin/bash

echo
echo
echo "*******************************"
echo "** Open Stack Client Helpers **"
echo "**                           **"
echo "**   FFHS RN Setup Cleaner   **"
echo "**                           **"
echo "** Removes the ICMP/UDP      **"
echo "** network setup for the RN  **"
echo "** block 3                   **"
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
echo -e "--> Instance R1 xxx NetA_Port_R1 xxx NetA...\c"
nova interface-detach R1 `neutron port-show NetA_Port_R1 -c id -f value`
echo "ok."

echo -e "--> Instance R1 xxx NetB_Port_R1 xxx NetB...\c"
nova interface-detach R1 `neutron port-show NetB_Port_R1 -c id -f value`
echo "ok."

echo -e "--> Instance A xxx NetA_Port_A xxx NetA...\c"
nova interface-detach A `neutron port-show NetA_Port_A -c id -f value`
echo "ok."

echo -e "--> Instance B xxx NetB_Port_B xxx NetB...\c"
nova interface-detach B `neutron port-show NetB_Port_B -c id -f value`
echo "ok."

# Delete Ports
echo
echo -e "--> Deleting Ports ...\c"
neutron port-delete NetA_Port_R1
neutron port-delete NetB_Port_R1
neutron port-delete NetA_Port_A
neutron port-delete NetB_Port_B
echo "done."

# Delete Networks
echo
echo -e "--> Deleting Networks NetA, NetB...\c"
neutron net-delete NetA
neutron net-delete NetB
echo "done."

# Delete Instances R1, A and B
echo
echo -e "--> Deleting Instance R1...\c"
nova delete R1
echo "done."

echo
echo -e "--> Deleting Instance A...\c"
nova delete A
echo "done."

echo
echo -e "--> Deleting Instance B...\c"
nova delete B
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


