#!/bin/bash

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>log.out 2>&1

EC2_AZ=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
EC2_IP=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`

ZONE_TAG=$(aws ec2 describe-tags --filters "Name=resource-id,Values=${EC2_ID}" \
    --query 'Tags[?Key==`AUTO_DNS_ZONE`].Value' --output text --region us-west-2)
NAME_TAG=$(aws ec2 describe-tags --filters "Name=resource-id,Values=${EC2_ID}" \
    --query 'Tags[?Key==`AUTO_DNS_NAME`].Value' --output text --region us-west-2)

aws route53 change-resource-record-sets --hosted-zone-id $ZONE_TAG \
    --change-batch '{"Changes":[{"Action":"UPSERT","ResourceRecordSet":{"Name":"'$NAME_TAG'","Type":"A","TTL":60,"ResourceRecords":[{"Value":"'$EC2_IP'"}]}}]}'
