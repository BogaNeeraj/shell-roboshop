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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling nodejs:20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing nodejs:20"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating roboshop system user"
else
    echo -e "System user roboshop already created ... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading cart"

rm -rf /app/*
cd /app 
unzip /tmp/cart.zip &>>$LOG_FILE
VALIDATE $? "unzipping cart"

npm install &>>$LOG_FILE
VALIDATE $? "Installing Dependencies"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "Copying cart service"

systemctl daemon-reload &>>$LOG_FILE
systemctl enable cart  &>>$LOG_FILE
systemctl start cart
VALIDATE $? "Starting cart"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

 echo -e "script executed successfully, $Y time taken : $TOTAL_TIME seconds $N " | tee -a $LOG_FILE
# 
#!/bin/bash
# START_TIME=$(date +%s)
# USERID=$(id -u)
# R="\e[31m"
# G="\e[32m"
# Y="\e[33m"
# N="\e[0m"

# LOG_FOLDER="/var/log/roboshop.logs"
# SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
# LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
# TIMESTAMP=$(date +%F-%H-%M-%S)
# SCRIPT_DIR=$PWD

# mkdir -p $LOG_FOLDER
#  echo "script started at : $TIMESTAMP " | tee -a $LOG_FILE

# # check the user has root priveleges or not
# if [ $USERID -ne 0 ]
# then 
#  echo -e "$R error:: please run the script with the root user $N"
# else
#  echo -e "$G script started with root user $N"
# fi

# VALIDATE(){
# if [ $1 -eq 0 ]
# then 
#  echo -e "$2...$G success $N" | tee -a $LOG_FILE

# else 
#  echo -e "$2... $R Failure $N" | tee -a $LOG_FILE
# fi 
# }

# dnf module disable nodejs -y &>> $LOG_FILE
# VALIDATE $? "Disbaling the user"
# dnf module enable nodejs:20 -y &>> $LOG_FILE
# VALIDATE $? "Enabling the user"
# dnf install nodejs -y &>> $LOG_FILE
# VALIDATE $? "Installing the nodejs"

# id roboshop
# if [ $? -ne 0 ]
# then 
#  useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
#  VALIDATE $? "creating the user roboshop"
#  echo " user created successufully"
# else
#  echo "user already exit"
# fi

# mkdir -p /app 
# VALIDATE $? "Created the directory"

# curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>> $LOG_FILE
# VALIDATE $? "Downloaded the user"

# rm -rf /app/*
# cd /app 
# unzip /tmp/user.zip &>> $LOG_FILE
# VALIDATE $? "Unzip the user"

# npm install &>> $LOG_FILE
# VALIDATE $? "Install the dependencies"

# cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
# VALIDATE $? "Copying the services"

# systemctl daemon-reload &>> $LOG_FILE
# VALIDATE $? "Reloaded the services"

# systemctl enable user &>> $LOG_FILE
# systemctl start user &>> $LOG_FILE
# VALIDATE $? "Started the services"

# START_TIME=$(date +%s)
# TOTAL_TIME=$(( $END_TIME - $START_TIME ))

# echo " script executed successfully, $Y time taken : $TOTAL_TIME seconds $N " | tee -a $LOG_FILE




