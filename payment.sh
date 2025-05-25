#!/bin/bash

dnf install python3 gcc python3-devel -y
VALIDATE $? "Installing python3 server"

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

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
VALIDATE $? "Downloading the code in temp direcory"

cd /app 
VALIDATE $? "Moving to app directory"
rm -rf /app/*

unzip /tmp/payment.zip
VALIDATE $? "Unzipping payment file"

pip3 install -r requirements.txt &>> $LOG_FILE
VALIDATE $? "Installing dependencies using pip3"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Copying payment service to path"

systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "Reloading after changes in systemctl service file"

systemctl enable payment &>> $LOG_FILE
VALIDATE $? "Enabling payment service"

systemctl start payment &>> $LOG_FILE
VALIDATE $? "Starting payment service"

