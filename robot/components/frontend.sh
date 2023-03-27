#!/bin/bash

#set -e
COMPONENT=frontend

LOGFILE="/tmp/$COMPONENT.log"
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
yum install nginx -y &>> $LOGFILE
Stat $?

echo -n "Downloading the $COMPONENT component:"
curl -s -L -o /tmp/$COMPONENT.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip"
Stat $?

echo -n "Performing cleanup of old $COMPONENT content:"
cd /usr/share/nginx/html
rm -rf * &>> $LOGFILE
Stat $?

echo -n "Copying the downloaded $COMPONENT content:"
unzip /tmp/$COMPONENT.zip &>> $LOGFILE
mv $COMPONENT-main/* .
mv static/* .
rm -rf $COMPONENT-main README.md
mv localhost.conf /etc/nginx/default.d/roboshop.conf
Stat $?

for component in catalogue user cart shipping payment; do 
    echo -n "updating the proxy details in the reverese proxy file:"
    sed -i "/$component/s/localhost/$component.roboshop.internal/"  /etc/nginx/default.d/roboshop.conf
done

echo -n "Starting the Nginx:"
systemctl enable nginx &>> $LOGFILE
systemctl start nginx &>> $LOGFILE
Stat $?