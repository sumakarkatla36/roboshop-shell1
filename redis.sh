#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGFILE="/tmp/script.log"
exec &>$LOGFILE

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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
VALIDATE $? "Installing Remi release"

dnf module enable redis:remi-6.2 -y
VALIDATE $? "enabling redis"

dnf install redis -y
VALIDATE $? "INSTALLING REDIS"

sed -i 's/127.0.0.1/0.0.0.0/g'/etc/redis/redis.conf
VALIDATE $? "allowing remote connections"

systemctl enable redis
VALIDATE $? "Enable Redis"

systemctl start redis
VALIDATE $? "started redis"

























