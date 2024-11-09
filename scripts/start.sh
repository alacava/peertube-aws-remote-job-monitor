#!/bin/bash

KEY="$AWSKEY"
SECRET="$AWSSECRET"
REGION="$AWSREGION"

aws configure set aws_access_key_id $KEY
aws configure set aws_secret_access_key $SECRET
aws configure set default.region $REGION

echo "output = text" >> /root/.aws/config

#systemctl start apache2