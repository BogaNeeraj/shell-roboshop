#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0cfc44495ae5411e9"
INSTANCES=("mongodb" "cart" "user" "catalogue" "redis" "mysql" "rabbitmq" "shipping" 
"payment" "dispatch" "frontend")
ZONE_ID="Z04262502A9244YCHSN99"
DOMAIN_NAME="neeraj.sbs"

for instance in ${INSTANCES[@]}
do
    aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids s
    g-0cfc44495ae5411e9 --tag-specifications "ResourceType=instance,
    Tags=[{Key=Name, Value=test}]" --query 'Instances[*].instance_id' --output text
    if [ $instance != "frontend" ]
    then 
     IP=aws ec2 describe-instances --instance-ids $INSTANCCE_ID
     --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text
    else 
     IP=aws ec2 describe-instances --instance-ids $INSTANCCE_ID
     --query 'Reservations[*].Instances[*].PublicIpAddress' --output text
    fi
    echo "$Instance IP address :$IP"
done