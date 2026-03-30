#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGFILE="/tmp/script.log"

VALIDATE() {
  if [ $1 -ne 0 ]; then 
    echo -e "$2 ... ${R}FAILED${N}"
    exit 1
  else
    echo -e "$2 ... ${G}SUCCESS${N}"
  fi
}

# Root check
if [ $ID -ne 0 ]; then 
  echo -e "${R}ERROR:: PLEASE RUN THIS SCRIPT THROUGH ROOT USER${N}"
  exit 1
else
  echo -e "${G}you are root user${N}"
fi

# NodeJS installation
dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Disabling current NodeJS"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "Enabling NodeJS 18"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing NodeJS"

# Roboshop user and app directory
id roboshop &>/dev/null || useradd roboshop &>> $LOGFILE
VALIDATE $? "Creating roboshop user"

mkdir -p /app &>> $LOGFILE
VALIDATE $? "Creating /app directory"

curl -o curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "Downloading users"

cd /app
unzip /tmp/user.zip &>> $LOGFILE
VALIDATE $? "Unzipping user"

npm install &>> $LOGFILE
VALIDATE $? "Installing npm dependencies"

cp /home/centos/roboshop-shell1/user.service /etc/systemd/system/user.service

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon reload"

systemctl enable user &>> $LOGFILE
VALIDATE $? "Enabling user service"

systemctl start user &>> $LOGFILE
VALIDATE $? "Starting user service"

# MongoDB client
cp /home/centos/roboshop-shell1/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copying Mongo repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "Installing MongoDB client"

mongo --host mongodb.katla.space </app/schema/user.js &>> $LOGFILE
VALIDATE $? "Loading user data into MongoDB"














