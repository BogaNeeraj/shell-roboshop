#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
TIMESTAMP=TIMESTAMP=$(date +%F-%H-%M-%S)

mkdir -p $LOGS_FOLDER
echo "script starting at: $TIMESTAMP " | tee -a $LOG_FILE

if [ $USERID -ne 0 ]
then 
 echo "$R ERROR:: please run this as root user $N"
 exit 1
else 
 echo "you are running eith the root user" |tee -a $LOG_FILE
fi
VALIDATE() {
    if [ $1 -eq 0 ]
     echo -e "$2....$G success $N" |tee -a $LOG_FILE
    else
     echo -e "$2....$R Failure $N" |tee -a $LOG_FILE
    fi
} 

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "coping the mongo.repo"

dnf install mongodb-org -y 
VALIDATE $? "Installing mongodb"

systemctl enable mongod 
systemctl start mongod 
VALIDATE $? "started mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Editing MongoDB conf file for remote connections"

systemctl restart mongod
VALIDATE $? "Restarting Mongodb"



 
