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

# Download and unzip cart app
curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "Downloading cart app"

cd /app
unzip /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "Unzipping cart app"

npm install &>> $LOGFILE
VALIDATE $? "Installing npm dependencies"

# Configure systemd service
cp /home/centos/roboshop-shell1/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE $? "Copying cart service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon reload"

systemctl enable cart &>> $LOGFILE
VALIDATE $? "Enabling cart service"

systemctl start cart &>> $LOGFILE
VALIDATE $? "Starting cart service"

