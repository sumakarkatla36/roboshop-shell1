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

VALIDATE $? "Disabling current node js" 

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "enabling nodejs 18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $?  "installing nodejs"

useradd roboshop &>> $LOGFILE

VALIDATE $?  "creating a roboshop user"

mkdir /app &>> $LOGFILE

VALIDATE $?  "creating a app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

VALIDATE $? "downloading the catalogue application"

cd /app

unzip /tmp/catalogue.zip 

VALIDATE $? "changing the location to app directory  and unziping"

npm install 

VALIDATE $? "installing the npm dependencies"

cp /home/centos/roboshop-shell1/catalogue.service /etc/systemd/system/catalogue.service 

VALIDATE $? "copying catalogue service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon reloading"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enabling catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "starting the catalogue"

cp /home/centos/roboshop-shell1/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copying the mongo repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "installing mongoDB client"

mongo --host mongodb.katla.space </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "loading catalogue data into mongodb"



