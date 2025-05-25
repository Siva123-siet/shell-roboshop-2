#!/bin/bash

dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>> $LOG_FILE
VALIDATE $? "Enabling nodejs"

dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "Installing nodejs"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Creating roboshop system user"
else
    echo -e "System user roboshop already created ... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "Downloading the code in temp direcory"

cd /app 
VALIDATE $? "Moving to app directory"
rm -rf /app/*

unzip /tmp/catalogue.zip
VALIDATE $? "Unzipping catalogue file"

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


