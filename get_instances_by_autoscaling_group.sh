#===============================================================================
# Get Instances list by AWS AutoScaling Group
#===============================================================================

group=$1
if [ -z $group ]; then
    echo "Usage: $0 <group>"
    exit 1
fi

IFS=$'\n'
set -f
for line in `aws autoscaling describe-auto-scaling-instances --region us-west-1 --query AutoScalingInstances[].[InstanceId,AutoScalingGroupName] --output text`
do
    id=`echo $line | cut -f1`
    groupname=`echo $line | cut -f2`
    if [ ${groupname} == ${group}  ]; then
        aws ec2 describe-instances --instance-ids $id --region us-west-1 --query Reservations[].Instances[].PrivateIpAddress --output text
    fi
done
