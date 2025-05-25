#!/bin/bash

source ./common.sh
app_name=user

check_root
app_setup
nodejs_setup

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Copying user service to path"

systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "Reloading after changes in systemctl service file"

systemctl enable user &>> $LOG_FILE
VALIDATE $? "Enabling user service"

systemctl start user &>> $LOG_FILE
VALIDATE $? "Starting user service"

print_time

