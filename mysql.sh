#!/bin/bash
START_TIME=$(date +%s)
Userid=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD
mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOGS_FILE
if [ $Userid -ne 0 ]
then
    echo -e "$R Error: Please run script with root access $N" | tee -a $LOGS_FILE
    exit 1
else
    echo "You are running with root access" | tee -a $LOGS_FILE
fi
echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD
VALIDATE()
{
if [ $1 -eq 0 ]
then
    echo -e "$2 is ...$G Success $N" | tee -a $LOGS_FILE
else
    echo -e "$2 is ...$R FAILURE $N" | tee -a $LOGS_FILE
    exit 1
fi 
}

dnf install mysql-server -y
VALIDATE $? "Installing MYSQL"

systemctl enable mysqld
VALIDATE $? "Enabling MYSQL service"

systemctl start mysqld  
VALIDATE $? "Starting MYSQL service"

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>> $LOGs_FILE
VALIDATE $? "Setting MySQL root password"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE