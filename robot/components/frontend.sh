#!/bin/bash

set -e
ID=$(id -u)

if [ "$ID" -ne 0 ]; then
    echo -e "\e[31m you need to execute this script as root user or use a sudo as prefix \e[0m"
    exit 1
fi
Stat(){
    if [ $1 -eq 0 ]; then
        echo -e "\e[32m Success \e[0m"
    else
        echo -e "\e[31m failure \e[0m"
        exit 2
    fi 
}
echo -n "Installing the nginx:" 
yum install nginx -y &>> /tmp/frontend.log
Stat $?

curl -s -L -o /tmp/frontend.zip "https://github.com/stans-robot-project/frontend/archive/main.zip"
cd /usr/share/nginx/html

rm -rf * &>> /tmp/frontend.log
unzip /tmp/frontend.zip &>> /tmp/frontend.log
mv frontend-main/* .
mv static/* .
rm -rf frontend-main README.md
mv localhost.conf /etc/nginx/default.d/roboshop.conf

systemctl enable nginx &>> /tmp/frontend.log
systemctl start nginx &>> /tmp/frontend.log