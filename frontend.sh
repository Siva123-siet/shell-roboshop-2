#!/bin/bash

source ./common.sh
check_root

dnf module disable nginx -y &>> $LOG_FILE
VALIDATE $? "Disabling nginx server"

dnf module enable nginx:1.24 -y &>> $LOG_FILE
VALIDATE $? "Enabling nginx server"

dnf install nginx -y &>> $LOG_FILE
VALIDATE $? "Installing nginx server"

systemctl enable nginx &>> $LOG_FILE
VALIDATE $? "Enabling nginx service"

cp $SCRIPT_DIR/nginx.config /etc/nginx/nginx.conf &>> $LOG_FILE
VALIDATE $? "Copying content into nginx.conf"

systemctl start nginx &>> $LOG_FILE
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
cp $SCRIPT_DIR/nginx.config /etc/nginx/nginx.conf &>> $LOG_FILE
VALIDATE $? "Copying content into nginx.conf"

systemctl restart nginx &>> $LOG_FILE
VALIDATE $? "Restarting nginx service"

print_time