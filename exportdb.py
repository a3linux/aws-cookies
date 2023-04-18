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
        newItem = item
        for key, val in item.items():
            for key2, val2 in val.items():
              if isinstance(val2, bytes):
                  newItem[key][key2] = val2.decode('ISO-8859-1')
        results.append(newItem)

alias = boto3.client('iam').list_account_aliases()['AccountAliases'][0]
envs = ['dev', 'stg', 'prd']
env = next((x for x in envs if x in alias), False)
end_pos = alias.find(env) - 1
start_pos = alias[:end_pos].rfind('-') + 1
moniker = alias[start_pos:end_pos]

with open(f"{args.table}-{args.region}-{moniker}-{env}-export.json", "w+") as f:
    f.write(json.dumps(results, indent=2))
