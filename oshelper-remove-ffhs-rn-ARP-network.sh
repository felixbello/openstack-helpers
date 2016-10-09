#!/bin/bash

echo
echo
echo "*******************************"
echo "** Open Stack Client Helpers **"
echo "**                           **"
echo "**   FFHS RN Setup Cleaner   **"
echo "**                           **"
echo "** Removes the basic network **"
echo "** setup for the RN Module.  **"
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

echo -e "--> Instance R2 xxx NetB_Port_R2 xxx NetB...\c"
nova interface-detach R2 `neutron port-show NetB_Port_R2 -c id -f value`
echo "ok."

echo -e "--> Instance R2 xxx NetC_Port_R2 xxx NetC...\c"
nova interface-detach R2 `neutron port-show NetC_Port_R2 -c id -f value`
echo "ok."

echo -e "--> Instance R2 xxx NetD_Port_R2 xxx NetD...\c"
nova interface-detach R2 `neutron port-show NetD_Port_R2 -c id -f value`
echo "ok." 
echo

echo -e "--> Instance A xxx NetB_Port_A xxx NetA...\c"
nova interface-detach A `neutron port-show NetB_Port_A -c id -f value`
echo "ok." 
echo
echo -e "--> Instance C xxx NetA_Port_C xxx NetA...\c"
nova interface-detach C `neutron port-show NetA_Port_C -c id -f value`
echo "ok." 
echo
echo -e "--> Instance D xxx NetA_Port_D xxx NetA...\c"
nova interface-detach D `neutron port-show NetA_Port_D -c id -f value`
echo "ok." 
echo


# Delete Ports
echo
echo -e "--> Deleting Ports NetA_Port_R1 on NetA, NetB_Port_R1 on NetB, NetB_Port_R2 on NetB, NetC_Port_R2 on NetC and NetD_Port_R2 on NetD...\c"
neutron port-delete NetA_Port_R1 
neutron port-delete NetB_Port_R1 
neutron port-delete NetB_Port_R2 
neutron port-delete NetC_Port_R2 
neutron port-delete NetD_Port_R2
neutron port-delete NetA_Port_C 
neutron port-delete NetA_Port_D 
neutron port-delete NetB_Port_A 

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

# Delete Instances R1 & R2
echo
echo -e "--> Deleting Instance R1...\c"
nova delete R1
echo "done."

echo
echo -e "--> Deleting Instance R2...\c"
nova delete R2
echo "done."

echo
echo -e "--> Deleting Instance A...\c"
nova delete A
echo "done."

echo
echo -e "--> Deleting Instance C...\c"
nova delete C
echo "done."

echo
echo -e "--> Deleting Instance D...\c"
nova delete D
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


