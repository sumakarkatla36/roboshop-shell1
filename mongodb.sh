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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "copied mongodb repo"

dnf install mongodb-org -y &>> $LOGFILE

VALIDATE $? "Installing Mongodb"

systemctl enable mongod &>> $LOGFILE

VALIDATE $? "enabling mongodb"

systemctl start mongod &>> $LOGFILE

VALIDATE $? "starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>LOGFILE

VALIDATE $? "Remote access to Mongodb"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "Restarting Mongodb"
