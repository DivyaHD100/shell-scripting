#!/bin/bash

if [ -z "$1" ]; then
    echo -e "\e[31m Component name is required \e[0m\t\t"
    echo -e "\t\t\t \e[32m Sample usage is: $bash create-ec2.sh user \e[0m\t\t"
    exit 1
fi
HOSTEDZONEID="Z01460382LDVHUYMKWW6K"
COMPONENT=$1
AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=DevOps-LabImage-CentOS7" | jq '.Images[].ImageId' | sed -e 's/"//g')
SGID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=b53-allow-all | jq ".SecurityGroups[].GroupId" | sed -e 's/"//g')
echo " AMI id is $AMI_ID "

echo -n "Launching the instance with $AMI_ID as AMI:"
IPADDRESS=$(aws ec2 run-instances --image-id $AMI_ID \
                    --instance-type t2.micro \
                    --security-group-ids ${SGID} \
                    --instance-market-options "MarketType=spot, SpotOptions={SpotInstanceType=persistent,InstanceInterruptionBehavior=stop}" \
                    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$COMPONENT}]" | jq '.Instances[].PrivateIpAddress' | sed -e 's/"//g')

sed -e "s/COMPONENT/${COMPONENT}/" -e  "s/IPADDRESS/${IPADDRESS}/" record.json > /tmp/r53.json
aws route53 change-resource-record-sets --hosted-zone-id $HOSTEDZONEID --change-batch file:///tmp/r53.json | jq