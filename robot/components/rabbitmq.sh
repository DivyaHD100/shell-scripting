#!/bin/bash

#set -e
COMPONENT=rabbitmq
source components/common.sh

echo -n "INstalling and Configuring dependency:"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>$LOGFILE
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>$LOGFILE
Stat $?


echo -n "Installing $COMPONENT:"
yum install rabbitmq-server -y &>>$LOGFILE
Stat $?

echo -n "Starting $COMPONENT :"
systemctl enable $COMPONENT-server &>>$LOGFILE
systemctl start $COMPONENT-server &>>$LOGFILE
Stat $?

rabbitmqctl list_users | grep $APPUSER &>>$LOGFILE
if [ $? -ne 0 ]; then 
    echo -n "Creating $COMPONENT Application user:"
    rabbitmqctl add_user roboshop roboshop123 &>>$LOGFILE
    Stat $?
fi

echo -n "Adding required privileges to the $APPUSER: "
rabbitmqctl set_user_tags roboshop administrator
rabbitmqlctl set_permissions -p / roboshop ".*" ".*" ".*"
Stat $?