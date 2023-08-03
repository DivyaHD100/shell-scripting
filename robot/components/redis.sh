#!/bin/bash

#set -e
COMPONENT=redis
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

echo -n "Configuring $COMPONENT repo :"
curl -L https://raw.githubusercontent.com/stans-robot-project/redis/main/redis.repo -o /etc/yum.repos.d/redis.repo &>> $LOGFILE
Stat $? 

echo -n "Installing $COMPONENT server :"
yum install redis-6.2.6 -y  &>> $LOGFILE
Stat $?

echo -n "Updating the $COMPONENT visibility:"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis/redis.conf
Stat $?

echo -n "Starting the $COMPONENT service:"
systemctl daemon-reload &>>$LOGFILE
systemctl restart $COMPONENT &>>$LOGFILE
Stat $?