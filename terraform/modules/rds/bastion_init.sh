#!/bin/bash

yum update -y
yum install -y vim mysql

aws s3 cp s3://am-utopia-items/db-create.sql .
mysql -h "${DB_ENDPOINT}" -u "${DB_USERNAME}" -p"${DB_PASSWORD}" < db-create.sql
