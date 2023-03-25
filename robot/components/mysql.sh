#!/bin/bash

#set -e
COMPONENT=mysql
source components/common.sh #source is going to load the file, so that you call all of them you need

echo -n "Downloading the $COMPONENT repo:"
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/stans-robot-project/mysql/main/mysql.repo
Stat $?

echo -n "Installing $COMPONENT:"
yum install mysql-community-server -y &>>$LOGFILE
Stat $? 

echo -n "Starting $COMPONENT :"
systemctl enable mysqld &>>$LOGFILE
systemctl start  mysqld &>>$LOGFILE
Stat $?

echo -n "Grab $COMPONENT default password :"
DEFAULT_ROOT_PWD=$(grep "temporary password" /var/log/mysqld.log | awk '{print $NF}')
stat $? 

# This should only run for the first time or when the default password is not changed.
echo "show databases;" | mysql -uroot -pRoboShop@1   &>> $LOGFILE 
if [ $? -ne 0 ] ; then 

    echo -n "Password Reset of root user :"
    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1';" | mysql --connect-expired-password -uroot -p${DEFAULT_ROOT_PWD} &>> $LOGFILE 
    stat $?

fi 

# Ensure you run this only when the password validate plugin exist 
echo "show plugins;" | mysql -uroot -pRoboShop@1 | grep validate_password  &>> $LOGFILE 
if [ $? -eq 0 ] ; then 

    echo -n "Uninstalling Password Validation Plugin :"
    echo "uninstall plugin validate_password;" | mysql -uroot -pRoboShop@1   &>> $LOGFILE
    stat $?

fi 

echo -n "Downloading the $COMPONENT Schema :"
curl -s -L -o /tmp/$COMPONENT.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip"  &>> $LOGFILE
stat $? 

echo -n "Extracting the $COMPONENT Schema :"
cd /tmp 
unzip -o /tmp/$COMPONENT.zip &>> $LOGFILE
stat $? 

echo -n "Injecting the schema :"
cd $COMPONENT-main
mysql -uroot -pRoboShop@1 < shipping.sql 
stat $?

