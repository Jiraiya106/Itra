#! python3

import boto3
import pprint
from logging import Filter
from botocore.exceptions import ClientError

def main():
    ec2 = boto3.client('ec2')
    respec2 = ec2.describe_instances(
        Filters=[
            {
                'Name': 'vpc-id',
                'Values': [
                        'vpc-dc6768a4',
                ]
            },
        ]
    )

    try:
        response = ec2.describe_security_groups()
        print(response)
    except ClientError as e:
        print(e)

    #pprint(respec2)GroupIds=['SECURITY_GROUP_ID']



main()
