#!/bin/bash
Userid=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD
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
dnf module disable nginx -y &>> $LOGS_FILE
VALIDATE $? "Disabling nginx server"

dnf module enable nginx:1.24 -y &>> $LOGS_FILE
VALIDATE $? "Enabling nginx server"

dnf install nginx -y &>> $LOGS_FILE
VALIDATE $? "Installing nginx server"

systemctl enable nginx &>> $LOGS_FILE
VALIDATE $? "Enabling nginx service"

cp $SCRIPT_DIR/nginx.config /etc/nginx/nginx.conf &>> $LOGS_FILE
VALIDATE $? "Copying content into nginx.conf"

systemctl start nginx &>> $LOGS_FILE
VALIDATE $? "Starting nginx service"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Removing existing content within html to replace our code"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "Downloading content from internet within link into temp directory"

cd /usr/share/nginx/html
VALIDATE $? "Navigating to the path"

unzip /tmp/frontend.zip
VALIDATE $? "Unzipping the frontend zipped file in /usr/share/nginx/html path"

rm -rf /etc/nginx/nginx.conf
cp $SCRIPT_DIR/nginx.config /etc/nginx/nginx.conf &>> $LOGS_FILE
VALIDATE $? "Copying content into nginx.conf"

systemctl restart nginx &>> $LOGS_FILE
VALIDATE $? "Restarting nginx service"