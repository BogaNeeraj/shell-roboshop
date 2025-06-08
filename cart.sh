#!/bin/bash
START_TIME=$(date +%s)
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

dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disabling the services"
dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling the services"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing the nodejs"
 
id roboshop
if [ $? -ne 0 ]
then 
 useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
 VALIDATE $? "Creating the user"
 echo "creating the user"
else 
 echo "user already exist"
fi

mkdir -p /app 
VALIDATE $? "Creating the directory"

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloadin the cart"

rm -rf /app/*
cd /app 
unzip /tmp/cart.zip
VALIDATE $? "unzip the cart"

npm install &>>$LOG_FILE
VALIDATE $? "downloading the dependencies"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "copying the services"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reload the services"

systemctl enable cart &>>$LOG_FILE
systemctl start cart &>>$LOG_FILE
VALIDATE $? "Starting the servies"

END_TIME=$(date +%s)

TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo " script executed successfully, $Y time taken : $TOTAL_TIME seconds $N " | tee -a $LOG_FILE



