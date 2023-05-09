#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "\e[31m Component name is required \e[0m\t\t"
    echo -e "\t\t\t \e[32m Sample usage is: $ bash create-ec2.sh user dev \e[0m\t\t"
    exit 1
fi
HOSTEDZONEID="Z01460382LDVHUYMKWW6K"
COMPONENT=$1
ENV=$2

AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=DevOps-LabImage-CentOS7" | jq '.Images[].ImageId' | sed -e 's/"//g')
SGID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=b53-allow-all | jq ".SecurityGroups[].GroupId" | sed -e 's/"//g')
echo " AMI id is $AMI_ID "

echo -n "Launching the instance with $AMI_ID as AMI:"


create_server() {

    echo "*** Launching $COMPONENT server ***"
IPADDRESS=$(aws ec2 run-instances --image-id $AMI_ID \
                    --instance-type t2.micro \
                    --security-group-ids ${SGID} \
                    --instance-market-options "MarketType=spot, SpotOptions={SpotInstanceType=persistent,InstanceInterruptionBehavior=stop}" \
                    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$COMPONENT-$ENV}]" | jq '.Instances[].PrivateIpAddress' | sed -e 's/"//g')

sed -e "s/COMPONENT/${COMPONENT}-${ENV}/" -e  "s/IPADDRESS/${IPADDRESS}/" record.json > /tmp/r53.json #search for Component in record.json and replace with COMPONENt-ENV
aws route53 change-resource-record-sets --hosted-zone-id $HOSTEDZONEID --change-batch file:///tmp/r53.json | jq
    echo "*** $COMPONENT server completed ***"
}

if [ "$1" == "all" ] ; then
    for component in frontend mongodb catalogue redis cart user mysql shipping rabbitmq payment ; do
    COMPONENT=$component
    create_server
done

else 
   create_server
fi 