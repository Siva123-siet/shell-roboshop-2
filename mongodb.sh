#!/bin/bash
Userid=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOGS_FILE
if [ $Userid -ne 0 ]
then
    echo -e "$R Error: Please run script with root access $N" | tee -a $LOGS_FILE
    exit 1
else
    echo "You are running with root access" | tee -a $LOGS_FILE
fi
VALIDATE()
{
if [ $1 -eq 0 ]
then
    echo -e "$2 is ...$G Success $N" | tee -a $LOGS_FILE
else
    echo -e "$2 is ...$R FAILURE $N" | tee -a $LOGS_FILE
    exit 1
fi 
}

cp mongo.repo /etc/yum.repos.d/mongodb.repo
VALIDATE $? "copying Mongodb repo"

dnf install mongodb-org -y &>> $LOGS_FILE
VALIDATE $? "Installing mongodb server"

systemctl enable mongod &>> $LOGS_FILE
VALIDATE $? "Enabling mongodb server"

systemctl start mongod &>> $LOGS_FILE
VALIDATE $? "Starting mongodb server"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Editing mongodb conf file for remote connections"

systemctl restart mongod &>> $LOGS_FILE
VALIDATE $? "Restarting mongodb server"
