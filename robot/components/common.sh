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

CREATE_USER() {
    id $APPUSER &>>$LOGFILE
if [ $? -ne 0 ]; then   
    echo -n "Creating the Application User Account:"
    useradd roboshop &>>$LOGFILE
    Stat $?
fi
}

DOWNLOAD_AND_EXTRACT(){
    echo -n "Downloading the $COMPONENT repo:"
    curl -s -L -o /tmp/$COMPONENT.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip"
    Stat $?

    echo -n "Extracting the $COMPONENT in the $APPUSER directory:"
    cd /home/$APPUSER
    rm -rf /home/$APPUSER/$COMPONENT
    unzip -o /tmp/$COMPONENT.zip &>>$LOGFILE
    Stat $?

    echo -n "Configuring the permissions:"
    mv /home/$APPUSER/$COMPONENT-main /home/$APPUSER/$COMPONENT
    chown -R $APPUSER:$APPUSER /home/$APPUSER/$COMPONENT
    Stat $?
}

NPM_INSTALL(){
   echo -n "Installing the $COMPONENT Application:"
    cd /home/$APPUSER/$COMPONENT
    npm install &>>$LOGFILE
    Stat $? 
}

CONFIG_SVC(){

echo -n "Updating the systemd file with DB details:"
sed -i -e 's/DBHOST/mysql.roboshop.internal/' -e 's/CARTENDPOINT/cart.roboshop.internal/' -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' /home/$APPUSER/$COMPONENT/systemd.service
mv /home/$APPUSER/$COMPONENT/systemd.service /etc/systemd/system/$COMPONENT.service
Stat $?

echo -n "Starting the $COMPONENT service:"
systemctl daemon-reload &>>$LOGFILE
systemctl enable $COMPONENT &>>$LOGFILE
systemctl restart $COMPONENT &>>$LOGFILE
Stat $?

}

MVN_PACKAGE(){
    echo -n "Creating the $COMPONENT package:"
    cd /home/$APPUSER/$COMPONENT
    mvn clean package &>>$LOGFILE
    mv target/shipping-1.0.jar shipping.jar
    Stat $? 
}

PYTHON() {
    echo -n "Installing Python and dependencies :"
    yum install python36 gcc python3-devel -y  &>> $LOGFILE
    stat $?

    # Calling Create-User Functon 
    CREATE_USER

    # Calling Download_And_Extract Function
    DOWNLOAD_AND_EXTRACT

    echo -n "Installing $COMPONENT :"
    cd /home/roboshop/$COMPONENT/ 
    pip3 install -r requirements.txt   &>> $LOGFILE
    stat $? 

    USERID=$(id -u roboshop)
    GROUPID=$(id -g roboshop)
    
    echo -n "Updating the $COMPONENT.ini file :"
    sed -i -e "/^uid/ c uid=${USERID}" -e "/^gid/ c gid=${GROUPID}"  /home/$APPUSER/$COMPONENT/$COMPONENT.ini 

    # Calling Config-Svc Function
    CONFIG_SVC

}


JAVA() {
    echo -n "Installing the MAVEN:"
    yum install maven -y &>>$LOGFILE
    Stat $? 

    CREATE_USER

    DOWNLOAD_AND_EXTRACT

    MVN_PACKAGE

    CONFIG_SVC
}

NODEJS() {
    echo -n "Configuring Nodejs repo:"
    curl --silent --location https://rpm.nodesource.com/setup_16.x | bash - &>>$LOGFILE
    Stat $?

    echo -n "Installing the Nodejs:"
    yum install nodejs -y &>>$LOGFILE
    Stat $? 

    CREATE_USER

    DOWNLOAD_AND_EXTRACT

    NPM_INSTALL

    CONFIG_SVC
}