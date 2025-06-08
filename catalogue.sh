#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FOLDER="/var/log/roboshop.logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_DIR=$PWD

mkdir -p $LOG_FOLDER
 echo "script started at : $TIMESTAMP " | tee -a $LOG_FILE

# check the user has root priveleges or not
if [ $USERID -ne 0 ]
then 
 echo "$R error:: please run the script with the root user $N"
else
 echo "$G script started with root user $N"
if

VALIDATE(){
if [ $1 -eq 0 ]
then 
 echo "$2...$G success " | tee -a $LOG_FILE

else 
 eccho "$2... $R Failure " | tee -a $LOG_FILE
fi 
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disabling the nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling the nodejs"

dnf install nodejs -y &>>$LOG_FILE &>>$LOG_FILE
VALIDATE $? "Installing the NODEJS" 

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
VALIDATE $? "user is created"

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Directory created successfully"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading Catalogue"

cd /app 
unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unzip the files successfully"

npm install &>>$LOG_FILE
VALIDATE $? "Instaaling the dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copied service file succcessfully"

systemctl daemon-reload &>>$LOG_FILE
systemctl enable catalogue &>>$LOG_FILE
systemctl start catalogue &>>$LOG_FILE
VALIDATE $? "Catalogue service started successfully"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service 

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing the mongod client"

mongosh --host mongodb.daws84s.site </app/db/master-data.js &>>$LOG_FILE
