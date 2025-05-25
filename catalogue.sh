#!/bin/bash

source ./common.sh
app_name=catalogue

check_root
app_setup

dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>> $LOG_FILE
VALIDATE $? "Enabling nodejs"

dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "Installing nodejs"

npm install &>> $LOG_FILE
VALIDATE $? "Installing dependencies using node package manager"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying catalogue service to path"

systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "Reloading after changes in systemctl service file"

systemctl enable catalogue &>> $LOG_FILE
VALIDATE $? "Enabling catalogue service"

systemctl start catalogue &>> $LOG_FILE
VALIDATE $? "Starting catalogue service"

rm -rf /etc/yum.repos.d/*
VALIDATE $? "removed all mongo repos content"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongodb.repo
VALIDATE $? "Copying mongo repo to the path"

dnf install mongodb-mongosh -y &>> $LOG_FILE
VALIDATE $? "Installing mongodb"

mongosh --host mongodb.daws-84s.store </app/db/master-data.js &>> $LOG_FILE
VALIDATE $? "Loading data to mongodb server"

print_time

