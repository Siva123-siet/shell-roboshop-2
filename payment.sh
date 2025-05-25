#!/bin/bash
source ./common.sh
app_name=payment

check_root
app_setup
python_setup

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Copying payment service to path"

systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "Reloading after changes in systemctl service file"

systemctl enable payment &>> $LOG_FILE
VALIDATE $? "Enabling payment service"

systemctl start payment &>> $LOG_FILE
VALIDATE $? "Starting payment service"

print_time

