#!/bin/bash
START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

app_setup(){
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

    curl -o /tmp/app_name.zip https://roboshop-artifacts.s3.amazonaws.com/app_name-v3.zip 
    VALIDATE $? "Downloading the code in temp direcory"

    cd /app 
    VALIDATE $? "Moving to app directory"
    rm -rf /app/*

    unzip /tmp/app_name.zip
    VALIDATE $? "Unzipping $app_name file"

}

nodejs_setup(){

    dnf module disable nodejs -y &>> $LOG_FILE
    VALIDATE $? "Disabling nodejs"

    dnf module enable nodejs:20 -y &>> $LOG_FILE
    VALIDATE $? "Enabling nodejs"

    dnf install nodejs -y &>> $LOG_FILE
    VALIDATE $? "Installing nodejs"

    npm install &>> $LOG_FILE
    VALIDATE $? "Installing dependencies using node package manager"
}

python_setup(){

    dnf install python3 gcc python3-devel -y
    VALIDATE $? "Installing python3 server"

    pip3 install -r requirements.txt &>> $LOG_FILE
    VALIDATE $? "Installing dependencies using pip3"

}

maven_setup(){

    dnf install maven -y
    VALIDATE $? "Installing Maven server"

    mvn clean package 
    VALIDATE $? "Installing dependencies using maven"

    mv target/shipping-1.0.jar shipping.jar 
    VALIDATE $? "Renaming shipping-1.0.jar with shipping.jar"
    
}
# check the user has root priveleges or not
check_root(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
        exit 1 #give other than 0 upto 127
    else
        echo "You are running with root access" | tee -a $LOG_FILE
    fi
}
# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

print_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME - $START_TIME))
    echo -e "Script executed successfully, $Y Time taken: $TOTAL_TIME seconds $N"
}