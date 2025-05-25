#!/bin/bash

dnf module disable redis -y
VALIDATE $? "Disabling redis"

dnf module enable redis:7 -y
VALIDATE $? "Enabling redis"

dnf install redis -y 
VALIDATE $? "Installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Edited redis.conf to accept remote connections"

systemctl enable redis 
VALIDATE $? "Enabling redis service"

systemctl start redis 
VALIDATE $? "Starting redis service"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE