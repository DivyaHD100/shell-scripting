#!/bin/bash

if [-z "$1"]; then
    echo -e "\e[31m Component name is required \e[0m\t\t"
    echo -e "\t\t\t \e[32m Sample usage is: $bash create-ec2.sh user \e[0m\t\t"
    exit 1
fi

COMPONENT=$1
AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=DevOps-LabImage-CentOS7" | jq '.Images[].ImageId' | sed -e 's/"//g')
echo " AMI id is $AMI_ID "

echo -n "Launching the instance with $AMI_ID as AMI:"
aws ec2 run-instances --image-id $AMI_ID --instance-type t2.micro --tag-specifications "ResourceType=instance, Tags=[{Key=name,Value=$COMPONENT}]"