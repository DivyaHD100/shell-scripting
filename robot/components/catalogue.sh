#!/bin/bash

#set -e
COMPONENT=Catalogue
LOGFILE="/tmp/$COMPONENT.log"
APPUSER=roboshop

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

echo -n "Configuring Nodejs repo:"
curl --silent --location https://rpm.nodesource.com/setup_16.x | sudo bash -
Stat $?

echo -n "Installing the Nodejs:"
yum install nodejs -y &>>$LOGFILE
Stat $?

echo -n "Creating the Application User Account:"
useradd $APPUSER &>>$LOGFILE
Stat $?

echo -n "Configuring the $COMPONENT repo:"
curl curl -s -L -o /tmp/$COMPONENT.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip" &>>$LOGFILE
Stat $?

echo -n "Extrracting the $COMPONENT in the $APPUSER directory:"
$ cd /home/$APPUSER 
$ unzip -o /tmp/$COMPONENT.zip &>>$LOGFILE
