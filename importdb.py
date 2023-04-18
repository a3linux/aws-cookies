#!/usr/bin/env python3
import argparse
import ast
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

entries = []
with open(args.inputfile, "r") as f:
    dataset = json.load(f)
    entries = dataset
    for idx, data_entry in enumerate(dataset):
        entry = ast.literal_eval(str(data_entry))
        for key, val in entry.items():
            for key2, val2 in val.items():
                if key2 == 'B':
                    entries[idx][key][key2] = val2.encode('ISO-8859-1')

dynamotargetclient = boto3.client('dynamodb', region_name=args.region)

for item in entries:
    dynamotargetclient.put_item(
        TableName=args.table,
        Item=item
    )
