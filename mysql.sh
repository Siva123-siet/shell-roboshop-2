#!/bin/bash

source ./common.sh
app_name=mysql
check_root

echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD

dnf install mysql-server -y
VALIDATE $? "Installing MYSQL"

systemctl enable mysqld
VALIDATE $? "Enabling MYSQL service"

systemctl start mysqld  
VALIDATE $? "Starting MYSQL service"

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>> $LOG_FILE
VALIDATE $? "Setting MySQL root password"

print_time