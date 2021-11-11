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
    
    #pprint(respec2)
    try:
        response = ec2.describe_security_groups()
        for i in response['SecurityGroups']:
            print("Security Group Name: "+i['GroupName'])
            print("the Egress rules are as follows: ")
            for j in i['IpPermissionsEgress']:
                print("IP Protocol: "+j['IpProtocol'])
                for k in j['IpRanges']:
                    print("IP Ranges: "+k['CidrIp'])
            for j in i['IpPermissions']:
                print("IP Protocol: "+j['IpProtocol'])
                try:
                    print("PORT: "+str(j['FromPort']))
                    for k in j['IpRanges']:
                        print("IP Ranges: "+k['CidrIp'])
                except Exception:
                    print("No value for ports and ip ranges available for this security group")
                    continue
        print(response)
    except ClientError as e:
        print(e)

    #print(ec2.describe_security_groups())
    #GroupIds=['SECURITY_GROUP_ID']



main()
