import boto3
from botocore.exceptions import ClientError

ec2 = boto3.client('ec2')
SECURITY_GROUP_ID = 'sg-02dd99ab94bf9731e'
try:
    response = ec2.describe_security_groups(GroupIds=[SECURITY_GROUP_ID])
    print(response)
    # for i in response['SecurityGroups']:
    #     for j in i['IpPermissionsEgress']:
    #         print(j['ToPort'])
    #         for k in j['IpRanges']:
    #             m = k['CidrIp']
    #             print(m)
except ClientError as e:
    print(e)