#!/usr/bin/env python3

import json
from datetime import date, datetime
import boto3

AWS_REGION = "us-west-2"
EC2_CLIENT = boto3.client('ec2', region_name=AWS_REGION)
VPC_ID = 'vpc-dc6768a4'


# Helper method to serialize datetime fields
def json_datetime_serializer(obj):
    if isinstance(obj, (datetime, date)):
        return obj.isoformat()
    raise TypeError ("Type %s not serializable" % type(obj))


response = EC2_CLIENT.describe_instances(
        Filters=[
            {
                'Name': 'vpc-id',
                'Values': [
                        VPC_ID,
                ]
            },
        ]
)

print(f'Instance {VPC_ID} attributes:')

for reservation in response['Reservations']:
    print(json.dumps(
            reservation,
            indent=4,
            default=json_datetime_serializer
        )
    )