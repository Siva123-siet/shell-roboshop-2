#!/bin/bash

source ./common.sh
app_name=cart

check_root
app_setup
nodejs_setup

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "Copying cart service to path"

systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "Reloading after changes in systemctl service file"

systemctl enable cart &>> $LOG_FILE
VALIDATE $? "Enabling cart service"

systemctl start cart &>> $LOG_FILE
VALIDATE $? "Starting cart service"

print_time