#!/bin/bash

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
