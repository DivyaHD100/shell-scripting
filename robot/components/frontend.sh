#!/bin/bash

#set -e
COMPONENT=frontend

LOGFILE="/tmp/$Component.log"
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
yum install nginx -y &>> $Logfile
Stat $?

echo -n "Downloading the $Component component:"
curl -s -L -o /tmp/$Component.zip "https://github.com/stans-robot-project/$Component/archive/main.zip"
Stat $?

echo -n "Performing cleanup of old $Component content:"
cd /usr/share/nginx/html
rm -rf * &>> $Logfile
Stat $?

echo -n "Copying the downloaded $Component content:"
unzip /tmp/$Component.zip &>> $Logfile
mv $Component-main/* .
mv static/* .
rm -rf $Component-main README.md
mv localhost.conf /etc/nginx/default.d/roboshop.conf
Stat $?

echo -n "Starting the Nginx:"
systemctl enable nginx &>> $Logfile
systemctl start nginx &>> $Logfile
Stat $?