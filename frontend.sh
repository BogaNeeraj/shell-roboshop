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
 echo -e "$R error:: please run the script with the root user $N"
else
 echo -e "$G script started with root user $N"
fi

VALIDATE(){
if [ $1 -eq 0 ]
then 
 echo -e "$2...$G success $N" | tee -a $LOG_FILE

else 
 echo -e "$2... $R Failure $N" | tee -a $LOG_FILE
fi 
}

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabled nginx"
dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enbaled nginx"
dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installed nginx"

systemctl enable nginx &>>$LOG_FILE
systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Nginx started"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Removing the default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Download the content"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip #&>>$LOG_FILE
VALIDATE $? "Unzipping frontend"

rm -rf /etc/nginx/nginx.conf
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copied the cconfing file"

systemctl restart nginx #&>>$LOG_FILE
VALIDATE $? "Restart the nginx"