#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

# check the user has root priveleges or not
if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1 #give other than 0 upto 127
else
    echo "You are running with root access" | tee -a $LOG_FILE
fi

echo "please enter the root password"
read -s MYSQL_ROOT_PASSWORD

# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf install maven -y &>> $LOG_FILE
VALIDATE $? "Install maeven"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOG_FILE
VALIDATE $? "Adding the user"

mkdir -p /app &>> $LOG_FILE
VALIDATE $? "Creating the direcotory"

id roboshop
if [ $? -ne 0 ]
then 
 curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>> $LOG_FILE
 VALIDATE $? "Downloading the shipping content"
else 
 echo -e "system user is already created... $Y Skipping $N " 
fi

# rm -rf /app/*
# cd /app 
# unzip /tmp/shipping.zip &>> $LOG_FILE
# VALIDATE $? "Unzipping the files"
rm -rf /app/*
cd /app 
unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "unzipping shipping"

mvn clean package &>> $LOG_FILE
VALIDATE $? "Cleaing the maven package"

mv target/shipping-1.0.jar shipping.jar &>> $LOG_FILE
VALIDATE $? "Moving and renaming th ejar file"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Copying the services"

systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "Reloading hte services"

systemctl enable shipping &>> $LOG_FILE
systemctl start shipping &>> $LOG_FILE
VALIDATE $? "Starting the shipping"

dnf install mysql -y &>> $LOG_FILE
VALIDATE $? "Installing the mysql"

mysql -h mysql.neeraj.sbs -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql &>> $LOG_FILE
mysql -h mysql.neeraj.sbs -uroot -p$MYSQL_ROOT_PASSWORD  < /app/db/app-user.sql &>> $LOG_FILE
mysql -h mysql.neeraj.sbs -uroot -p$MYSQL_ROOT_PASSWORD  < /app/db/master-data.sql &>> $LOG_FILE
VALIDATE $? "Loading the data"

systemctl restart shipping &>> $LOG_FILE
VALIDATE $? "Restarting the services"


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

 echo -e "script executed successfully, $Y time taken : $TOTAL_TIME seconds $N " | tee -a $LOG_FILE
