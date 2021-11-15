#! python3

import boto3
from botocore.exceptions import ClientError
SECURITY_GROUP_ID = ['sg-0cd275ab14229c79d', 'sg-014b7f08ca20ffa06', 'sg-0cd275ab14229c79d', 'sg-014b7f08ca20ffa06']
ec2 = boto3.client('ec2')
try:
    def list_all_ec2_instances():
        client = boto3.client('ec2')
        response = client.describe_security_groups()
        reservations = response['Reservations']
        return list([instance for response['Reservations'] in reservations for instance in response['Reservations']['Instances']])
    # def list_sg(security):
    #     client = boto3.client('ec2')
    #     response = client.describe_security_groups()
    #     return list([response for sg in range(len(security)) for range(len(security)) in response(GroupIds=[security[sg]]) ])
    
    def example():
        response = []
        for i in range(len(SECURITY_GROUP_ID)):
            response.append( ec2.describe_security_groups(GroupIds=[SECURITY_GROUP_ID[i]]) )
        return response
    print(example())
    #     for k in response['SecurityGroups']:
    #         for l in k['IpPermissionsEgress']: 
    #             for m in l['IpRanges']:
    #                 print(m['CidrIp'])
        #print(response)
except ClientError as e:
    print(e)