#! python3

import boto3
from botocore.exceptions import ClientError
SECURITY_GROUP_ID = 'sg-014b7f08ca20ffa06'
ec2 = boto3.client('ec2')
try:
    response = ec2.describe_security_groups(GroupIds=[SECURITY_GROUP_ID])
    print(response)
except ClientError as e:
    print(e)