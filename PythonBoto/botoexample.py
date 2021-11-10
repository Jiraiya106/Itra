#! python3

import boto3

ec2 = boto3.resource('ec2')
security_group = ec2.SecurityGroup('sg-014b7f08ca20ffa06')

print(security_group)