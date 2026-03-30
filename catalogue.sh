#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGFILE="/tmp/script.log"

VALIDATE() {
  if [ $1 -ne 0 ]
  then 
    echo -e "$2 ... ${R}FAILED${N}"
    exit 1
  else
    echo -e "$2 ... ${G}SUCCESS${N}"
  fi
}

if [ $ID -ne 0 ]
then 
  echo -e "${R}ERROR:: PLEASE RUN THIS SCRIPT THROUGH ROOT USER${N}"
  exit 1
else
  echo -e "${G}you are root user${N}"
fi

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Diabling current node js" &>> $LOGFILE

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "enabling nodejs 18"&>> $LOGFILE

dnf install nodejs -y &>> $LOGFILE

VALIDATE $?  "installing nodejs"&>> $LOGFILE

useradd roboshop &>> $LOGFILE

VALIDATE $?  "creating a roboshop user"&>> $LOGFILE

mkdir /app &>> $LOGFILE

VALIDATE $?  "creating a app directory"&>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "downloading the catalogue application"&>> $LOGFILE

cd /app &>> $LOGFILE

unzip /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "changing the location to app directory  and unziping"&>> $LOGFILE

npm install &>> $LOGFILE

VALIDATE $? "installing the npm dependencies"&>> $LOGFILE

cp /home/centos/roboshop-shell1/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copying catalogue service file"&>> $LOGFILE

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon reloading"&>> $LOGFILE

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enabling catalogue"&>> $LOGFILE

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "staring the catalogue"&>> $LOGFILE

cp /home/centos/roboshop-shell1/mogo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copying the mongo repo"&>> $LOGFILE

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "installing mongoDB client"&>> $LOGFILE

mongo --host mongodb.katla.space </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "loading catalogue data into mongodb"&>> $LOGFILE



