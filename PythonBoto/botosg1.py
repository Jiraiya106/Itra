#! python3

import boto3

client = boto3.client('ec2')
response = client.describe_instances()
b = []
for reservation in response['Reservations']:
    for instance in reservation['Instances']:
        print("Instance: " + instance['InstanceId'])
        for securityGroup in instance['SecurityGroups']:
            print("SG ID: {}, Name: {}".format(securityGroup['GroupId'], securityGroup['GroupName']))
            b = securityGroup['GroupId']
            print(b)
