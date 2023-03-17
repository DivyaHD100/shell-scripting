#!/bin/bash

#set -e
COMPONENT=mongodb

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

echo -n "Configuring the $COMPONENT repo:"
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/stans-robot-project/mongodb/main/mongo.repo &>> $LOGFILE 
Stat $?

echo -n "Installing $COMPONENT:"
yum install -y mongodb-org &>>$LOGFILE
Stat $?

echo -n "Starting $COMPONENT :"
systemctl enable mongod &>>$LOGFILE
systemctl start mongod &>>$LOGFILE
Stat $?

echo -n "Updating the $COMPONENT visibility:"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
Stat $?

echo -n "Performing Daemon-Reload:"
systemctl Daemon-Reload &>>$LOGFILE
systemctl restart mongod 
Stat $?

echo -n "Downloading the $COMPONENT schema: "
curl -s -L -o /tmp/mongodb.zip "https://github.com/stans-robot-project/mongodb/archive/main.zip"

echo -n "Extracting the $COMPONENT schema: "
cd /tmp
unzip -o $COMPONENT.zip &>>$LOGFILE
Stat $?

echo -n "Injecting the schema:"
cd $COMPONENT-main
mongo < catalogue.js &>>$LOGFILE
mongo < users.js &>>$LOGFILE
Stat $?

