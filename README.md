#### Some personal AWS dirty scripts, tools and so forth

- *put-aws-rds-cw-alarms.sh*  Put four most popular CloudWatch Alarms of AWS RDS for given RDS
- *handler.js*  A quick AWS Lambda NodeJS script to handler CloudWatch Alarm deliveried to AWS SNS and raise alert message to Slack by Slack WebIncoming hook
- *put-ec2-alarms.sh* Put ALARMs of CPU, Memory and Disk Utilizations for EC2 instances

- ddb_export_table.py and ddb_import_table.py can be use to export and import small DynamoDB table. For large amount data table, please go to AWS Datapipeline and S3;

Allen Chen(a3linux AT GMail.com)
