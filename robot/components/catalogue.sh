#!/bin/bash

#set -e
COMPONENT=catalogue
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
curl --silent --location https://rpm.nodesource.com/setup_16.x | bash - &>>$LOGFILE
Stat $?

echo -n "Installing the Nodejs:"
yum install nodejs -y &>>$LOGFILE
Stat $?

id $APPUSER &>>$LOGFILE
if [ $? -ne 0 ]; then   
    echo -n "Creating the Application User Account:"
    useradd roboshop &>>$LOGFILE
    Stat $?
fi

echo -n "Downloading the $COMPONENT repo:"
curl -s -L -o /tmp/$COMPONENT.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip"
Stat $?

echo -n "Extracting the $COMPONENT in the $APPUSER directory:"
cd /home/$APPUSER
rm -rf /home/$APPUSER/$COMPONENT
unzip -o /tmp/$COMPONENT.zip &>>$LOGFILE
Stat $?

echo -n "Configuring the permissions:"
mv /home/$APPUSER/$COMPONENT-main/ /home/$APPUSER/$COMPONENT/
chown -R $APPUSER:$APPUSER /home/$APPUSER/$COMPONENT
Stat $?

echo -n "Installing the $COMPONENT Application:"
cd /home/$APPUSER/$COMPONENT
npm install &>>$LOGFILE
Stat $?

echo -n "Updating the systemd file with DB details:"
sed -i -e 's/MONGO_DSNAME/mongodb.roboshop.internal/' /home/$APPUSER/$COMPONENT/systemd.service
mv /home/$APPUSER/$COMPONENT/systemd.service /etc/systemd/system/$COMPONENT.service
Stat $?

echo -n "Starting the $COMPONENT service:"
systemctl daemon-reload &>>$LOGFILE
systemctl enable $COMPONENT &>>$LOGFILE
systemctl restart $COMPONENT &>>$LOGFILE
Stat $?
