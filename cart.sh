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

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip 
VALIDATE $? "Downloading the code in temp direcory"

cd /app 
VALIDATE $? "Moving to app directory"
rm -rf /app/*

unzip /tmp/cart.zip
VALIDATE $? "Unzipping cart file"

npm install &>> $LOG_FILE
VALIDATE $? "Installing dependencies using node package manager"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "Copying cart service to path"

systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "Reloading after changes in systemctl service file"

systemctl enable cart &>> $LOG_FILE
VALIDATE $? "Enabling cart service"

systemctl start cart &>> $LOG_FILE
VALIDATE $? "Starting cart service"