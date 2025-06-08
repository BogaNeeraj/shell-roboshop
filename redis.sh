#!/bin/bash

USERID=$(id -u)
START_TIME=$(date +%s)
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

dnf module disable redis -y &>> $LOG_FILE
VALIDATE $? "Disabling the redis"
dnf module enable redis:7 -y &>> $LOG_FILE
VALIDATE "Enabling the redis"

dnf install redis -y &>> $LOG_FILE
VALIDATE $? "Install redis"

sed -i 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no ' /etc/redis/redis.conf

systemctl enable redis &>> $LOG_FILE
systemctl start redis &>> $LOG_FILE
VALIDATE $? "Staring the redis"

END_TIME=$(date +%s)

TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE




