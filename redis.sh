#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGFILE="/tmp/script.log"
exec &> >(tee -a $LOGFILE)

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
  echo -e "${R}ERROR:: PLEASE RUN AS ROOT${N}"
  exit 1
else
  echo -e "${G}you are root user${N}"
fi

# Install Redis
yum install redis -y
VALIDATE $? "Installing Redis"

# Enable remote access
if [ -f /etc/redis.conf ]; then
    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf
    VALIDATE $? "Allowing remote connections"
else
    echo "Redis config file not found!"
    exit 1
fi

# Start service
systemctl enable redis
VALIDATE $? "Enable Redis"

systemctl start redis
VALIDATE $? "Start Redis"

