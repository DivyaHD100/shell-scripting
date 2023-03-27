#!/bin/bash

AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=DevOps-LabImage-CentOS7" | jq '.Images[].ImageId')
echo " AMI id is $AMI_ID "