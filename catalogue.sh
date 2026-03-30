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

# Download and unzip catalogue app
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "Downloading catalogue app"

cd /app
unzip /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "Unzipping catalogue app"

npm install &>> $LOGFILE
VALIDATE $? "Installing npm dependencies"

# Configure systemd service
cp /home/centos/roboshop-shell1/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "Copying catalogue service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon reload"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "Enabling catalogue service"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "Starting catalogue service"

# MongoDB client
cp /home/centos/roboshop-shell1/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copying Mongo repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "Installing MongoDB client"

mongo --host mongodb.katla.space </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "Loading catalogue data into MongoDB"