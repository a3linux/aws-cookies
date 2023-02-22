#!/usr/bin/env python3
import argparse
import boto3
import json

parser = argparse.ArgumentParser(prog="ddb_export")
parser.add_argument("-r", "--region", required=True,
                    help="AWS Region")
parser.add_argument("-t", "--table", required=True,
                    help="DynamoDB table name")
args = parser.parse_args()

dynamoclient = boto3.client('dynamodb', region_name=args.region)

dynamopaginator = dynamoclient.get_paginator('scan')

dynamoresponse = dynamopaginator.paginate(
    TableName=args.table,
    Select='ALL_ATTRIBUTES',
    ReturnConsumedCapacity='NONE',
    ConsistentRead=True
)

results = []
for page in dynamoresponse:
    for item in page['Items']:
        results.append(item)

with open("results.json", "w+") as f:
    f.write(json.dumps(results, indent=2))
