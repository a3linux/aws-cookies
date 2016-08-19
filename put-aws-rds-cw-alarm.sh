#!/bin/bash -
#===============================================================================
# Description:
#       Put AWS Cloudwatch Alarm with CLI for AWS RDS (MySQL, PostgreSQL)
# Requirment:
#       AWS CLI tool should setup correctly.
#
# ALARMs
#       CPUUtilization >= 80%
#       DB Connections >= 100
#       FreeStorageSpace =< 1GB
#       FreeableMemory =< 1GB
#
#===============================================================================

RDS_IDENTIFIER=$1

if [ -z ${RDS_IDENTIFIER} ]; then
    echo "Usage: $0 RDS_NAME"
    exit 0
fi

aws cloudwatch put-metric-alarm --alarm-name awsrds-${RDS_IDENTIFIER}-High-CPU-Utilization --alarm-description "CPU Usage >=80% for 15 minutes" --metric-name "CPUUtilization" --namespace "AWS/RDS" --statistic Average --period 300 --threshold 80 --comparison-operator GreaterThanOrEqualToThreshold --dimensions Name=DBInstanceIdentifier,Value=${RDS_IDENTIFIER} --evaluation-periods 3 --unit Percent --alarm-actions "arn:aws:sns:us-west-1:261991560536:sns-adp-nonprod-alarm" --ok-actions "arn:aws:sns:us-west-1:261991560536:sns-adp-nonprod-alarm" --insufficient-data-actions "arn:aws:sns:us-west-1:261991560536:sns-adp-nonprod-alarm"

aws cloudwatch put-metric-alarm --alarm-name awsrds-${RDS_IDENTIFIER}-High-DB-Connections --alarm-description "High DB Connections > 100" --metric-name "DatabaseConnections" --namespace "AWS/RDS" --statistic Average --period 300 --threshold 100 --comparison-operator GreaterThanOrEqualToThreshold --dimensions Name=DBInstanceIdentifier,Value=${RDS_IDENTIFIER} --evaluation-periods 1 --alarm-actions "arn:aws:sns:us-west-1:261991560536:sns-adp-nonprod-alarm" --ok-actions "arn:aws:sns:us-west-1:261991560536:sns-adp-nonprod-alarm" --insufficient-data-actions "arn:aws:sns:us-west-1:261991560536:sns-adp-nonprod-alarm"

aws cloudwatch put-metric-alarm --alarm-name awsrds-${RDS_IDENTIFIER}-Low-Free-Storage-Space --alarm-description "DB Storage free space is lower than 1GB" --metric-name "FreeStorageSpace" --namespace "AWS/RDS" --statistic Average --period 300 --threshold 1073741824 --comparison-operator LessThanOrEqualToThreshold --dimensions Name=DBInstanceIdentifier,Value=${RDS_IDENTIFIER} --evaluation-periods 1 --alarm-actions "arn:aws:sns:us-west-1:261991560536:sns-adp-nonprod-alarm" --ok-actions "arn:aws:sns:us-west-1:261991560536:sns-adp-nonprod-alarm" --insufficient-data-actions "arn:aws:sns:us-west-1:261991560536:sns-adp-nonprod-alarm"

aws cloudwatch put-metric-alarm --alarm-name awsrds-${RDS_IDENTIFIER}-Low-Freeable-Memory --alarm-description "DB Free Memory is lower than 1GB" --metric-name "FreeableMemory" --namespace "AWS/RDS" --statistic Average --period 300 --threshold 1073741824 --comparison-operator LessThanOrEqualToThreshold --dimensions Name=DBInstanceIdentifier,Value=${RDS_IDENTIFIER} --evaluation-periods 1 --alarm-actions "arn:aws:sns:us-west-1:261991560536:sns-adp-nonprod-alarm" --ok-actions "arn:aws:sns:us-west-1:261991560536:sns-adp-nonprod-alarm" --insufficient-data-actions "arn:aws:sns:us-west-1:261991560536:sns-adp-nonprod-alarm"
