#! python3

import boto3

client = boto3.client('ec2')
response = client.describe_instances()

for reservation in response['Reservations']:
    for instance in reservation['Instances']:
        print(instance['InstanceId'])
        print(instance['NetworkInterfaces'])
        for securityGroup in instance['SecurityGroups']:
            print(securityGroup['GroupId'])

#b = list(reservation for response['Reservations'] in )