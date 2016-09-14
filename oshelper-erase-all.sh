#!/bin/bash

echo
echo
echo "*******************************"
echo "** Open Stack Client Helpers **"
echo "**                           **"
echo "**       E R A Z O R         **"
echo "**                           **"
echo "*******************************"
echo
echo -e "This will eraze all your ports, subnets, networks and instances! \nAre you brave enough to continue (Yes, this is the point of no return!)? [y/N] > \c"
read DO_IT

if ! [[ $DO_IT =~ [yY] ]]
then
	echo "Aborted by user"
	exit 1
fi

echo
echo "OK, let's do this!"
echo
echo "Deleting all Ports"
echo "=================="
AVAILABLE_PORTS=`neutron port-list -c id -f value`
if [ "$AVAILABLE_PORTS" ]
then
	echo -e "Available Ports: \c"
	echo $AVAILABLE_PORTS | xargs echo
	echo $AVAILABLE_PORTS | xargs neutron port-delete
else
	echo "No available Ports found, skipping ..."
fi
echo "done."
echo
echo "Deleting all Subnets"
echo "===================="
AVAILABLE_SUBNETS=`neutron subnet-list -c id -f value`
if [ "$AVAILABLE_SUBNETS" ]
then
	echo -e "Available Subnets: \c"
	echo $AVAILABLE_SUBNETS | xargs echo
	echo $AVAILABLE_SUBNETS | xargs neutron subnet-delete
else
	echo "No available Subnets found, skipping ..."
fi
echo "done."
echo
echo "Deleting all Networks"
echo "====================="
AVAILABLE_NETWORKS=`neutron net-list -c id -f value`
if [ "$AVAILABLE_NETWORKS" ]
then
	echo -e "Available Networks: \c"
	echo $AVAILABLE_NETWORKS | xargs echo
	echo $AVAILABLE_NETWORKS | xargs neutron net-delete
else
	echo "No available Networks found, skipping ..."
fi
echo "done."
echo
echo "Deleting all Instances"
echo "======================"
AVAILABLE_INSTANCES=`openstack server list -c ID -f value`
AVAILABLE_INSTANCES_NAMES=`openstack server list -c Name -f value`
if [ "$AVAILABLE_INSTANCES" ]
then
	echo -e "Available Instances: \c"
	echo $AVAILABLE_INSTANCES_NAMES | xargs echo
	echo $AVAILABLE_INSTANCES | xargs nova delete
else
	echo "No available Instances found, skipping ..."
fi
echo "done."



