#!/bin/bash -
#======================================================================
#        Name: put-ec2-alarms.sh
# Description: Setup ec2 alarms according to instance,group and
#              so forth
# ALARMs
# HighCPU (>=80% 15 min)  LowCPU (<=5% 60 min)
# HighMemory (>=95% 30 min), Actually, it is always not very
#   necessary for Linux
# HighDiskUsage (>90% 15 min)
#======================================================================

ALARM_SNS_TOPIC_ARN=$1

if [ -z ${ALARM_SNS_TOPIC_ARN} ]; then
    echo "Usage: $0 <SNS_TOPIC>"
    exit 1
fi

for EC2_INSTANCE_ID in `aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text`
do
    # Try to catch some properties of the Instance
    #EC2_INSTANCE_NAME=`aws ec2 describe-instances --instance-ids ${EC2_INSTANCE_ID} --query "Reservations[*].Instances[*].[Tags[*].[Value]]" --output text` # Name Tag
    EC2_IMAGE_ID=`aws ec2 describe-instances --instance-ids ${EC2_INSTANCE_ID} --query "Reservations[*].Instances[*].[ImageId]" --output text`
    EC2_INSTANCE_TYPE=`aws ec2 describe-instances --instance-ids ${EC2_INSTANCE_ID} --query "Reservations[*].Instances[*].[InstanceType]" --output text`
    AUTOSCALING_GROUP_NAME=`aws autoscaling describe-auto-scaling-instances --instance-ids ${EC2_INSTANCE_ID} --query AutoScalingInstances[].AutoScalingGroupName --output text`

    # CPUUtilization
    # If CPUUtilization >= 80% for 15 minutes
    aws cloudwatch put-metric-alarm --alarm-name HighCPU-${EC2_INSTANCE_ID} --alarm-description "HighCPU ALARM: CPU usage is >=80% in 15 mins" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 80 --comparison-operator GreaterThanOrEqualToThreshold --dimensions Name=InstanceId,Value=${EC2_INSTANCE_ID} --evaluation-periods 3 --unit Percent --alarm-actions "${ALARM_SNS_TOPIC_ARN}" --ok-actions "${ALARM_SNS_TOPIC_ARN}" --insufficient-data-actions "${ALARM_SNS_TOPIC_ARN}"
    aws cloudwatch put-metric-alarm --alarm-name LowCPU-${EC2_INSTANCE_ID} --alarm-description "LowCPU ALARM: CPU usage is too low (<=5% in 60 mins)" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 5 --comparison-operator LessThanOrEqualToThreshold --dimensions Name=InstanceId,Value=${EC2_INSTANCE_ID} --evaluation-periods 12 --unit Percent --alarm-actions "${ALARM_SNS_TOPIC_ARN}" --ok-actions "${ALARM_SNS_TOPIC_ARN}" --insufficient-data-actions "${ALARM_SNS_TOPIC_ARN}"

    # NOTICE: MemoryUtilization DiskUtilization are customized CloudWatch metrics coming from go-aws-mon
    # https://github.com/a3linux/go-aws-mon
    # By Default the namespace is Linux/System

    # MemoryUtilization
    aws cloudwatch put-metric-alarm --alarm-name HighMemory-${EC2_INSTANCE_ID} --alarm-description "HighMemory ALARM: Memory Usage is >=95% in 30 mins" --metric-name MemoryUtilization --namespace Linux/System --statistic Average --period 300 --threshold 95 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 6 --unit Percent --alarm-actions "${ALARM_SNS_TOPIC_ARN}" --ok-actions ${ALARM_SNS_TOPIC_ARN} --insufficient-data-actions "${ALARM_SNS_TOPIC_ARN}" --dimensions Name=InstanceId,Value=${EC2_INSTANCE_ID} Name=InstanceType,Value=${EC2_INSTANCE_TYPE} Name=ImageId,Value=${EC2_IMAGE_ID}

    # DiskUtilization
    aws cloudwatch put-metric-alarm --alarm-name HighDiskUsage-Root-${EC2_INSTANCE_ID} --alarm-description "HighDiskUsage ALARM: / usage >=90% for 15 mins" --metric-name DiskUtilization --namespace Linux/System --statistic Average --period 300 --threshold 90 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 3 --unit Percent --alarm-actions "${ALARM_SNS_TOPIC_ARN}" --ok-actions "${ALARM_SNS_TOPIC_ARN}" --insufficient-data-actions "${ALARM_SNS_TOPIC_ARN}" --dimensions Name=InstanceId,Value=${EC2_INSTANCE_ID} Name=InstanceType,Value=${EC2_INSTANCE_TYPE} Name=ImageId,Value=${EC2_IMAGE_ID} Name=FileSystem,Value=/

    # Setup different disk alarm according to server group(AutoScaling Group)
    # The below sample is for DCOS Cluster nodes /var/lib
    if [ ! -z ${AUTOSCALING_GROUP_NAME} ]; then
        echo -n "${EC2_INSTANCE_ID} from ${AUTOSCALING_GROUP_NAME} group is "
        if [[ ${AUTOSCALING_GROUP_NAME} =~ ^DCOS.*$ ]]; then
            echo " DCOS Server"
            aws cloudwatch put-metric-alarm --alarm-name HighDiskUsage-varlib-${EC2_INSTANCE_ID} --alarm-description "HighDiskUsage ALARM: /var/lib usage >=90% for 15 mins" --metric-name DiskUtilization --namespace Linux/System --statistic Average --period 300 --threshold 90 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 3 --unit Percent --alarm-actions "${ALARM_SNS_TOPIC_ARN}" --ok-actions "${ALARM_SNS_TOPIC_ARN}" --insufficient-data-actions "${ALARM_SNS_TOPIC_ARN}" --dimensions Name=InstanceId,Value=${EC2_INSTANCE_ID} Name=InstanceType,Value=${EC2_INSTANCE_TYPE} Name=ImageId,Value=${EC2_IMAGE_ID} Name=FileSystem,Value=/var/lib
        else
            echo " Other Server"
        fi
    fi
done
