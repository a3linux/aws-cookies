#!/usr/bin/env python3
import argparse
import boto3
import json

parser = argparse.ArgumentParser(prog="ddb_import")
parser.add_argument("-r", "--region", required=True,
                    help="AWS Region")
parser.add_argument("-t", "--table", required=True,
                    help="DynamoDB table name")
parser.add_argument("-f", "--inputfile", required=True,
                    help="Input file, should be a json exported file from ddb_export_table.py")
args = parser.parse_args()

dataset = []
with open(args.inputfile, "r") as f:
    dataset = json.load(f)

dynamotargetclient = boto3.client('dynamodb', region_name=args.region)

for item in dataset:
    dynamotargetclient.put_item(
        TableName=args.table,
        Item=item
    )
