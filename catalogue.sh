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

dnf module disable nodejs -y

VALIDATE $? "Diabling current node js" &>> $LOGFILE

dnf module enable nodejs:18 -y

VALIDATE $? "enabling nodejs 18"&>> $LOGFILE

dnf install nodejs -y

VALIDATE $?  "installing nodejs"&>> $LOGFILE

useradd roboshop

VALIDATE $?  "creating a roboshop user"&>> $LOGFILE

mkdir /app

VALIDATE $?  "creating a app directory"&>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "downloading the catalogue application"&>> $LOGFILE

cd /app 

unzip /tmp/catalogue.zip

VALIDATE $? "changing the location to app directory  and unziping"&>> $LOGFILE

npm install 

VALIDATE $? "installing the npm dependencies"&>> $LOGFILE

cp /home/centos/roboshop-shell1/catalogue.service /etc/systemd/system/catalogue.service

VALIDATE $? "copying catalogue service file"&>> $LOGFILE

systemctl daemon-reload

VALIDATE $? "daemon reloading"&>> $LOGFILE

systemctl enable catalogue

VALIDATE $? "enabling catalogue"&>> $LOGFILE

systemctl start catalogue

VALIDATE $? "staring the catalogue"&>> $LOGFILE

cp /home/centos/roboshop-shell1/mogo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying the mongo repo"&>> $LOGFILE

dnf install mongodb-org-shell -y

VALIDATE $? "installing mongoDB client"&>> $LOGFILE

mongo --host mongodb.katla.space </app/schema/catalogue.js

VALIDATE $? "loading catalogue data into mongodb"&>> $LOGFILE

