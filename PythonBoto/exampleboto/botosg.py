#! python3

import boto3
from botocore.exceptions import ClientError
SECURITY_GROUP_ID = ['sg-0cd275ab14229c79d', 'sg-014b7f08ca20ffa06', 'sg-0cd275ab14229c79d', 'sg-014b7f08ca20ffa06']
ec2 = boto3.client('ec2')
client = boto3.client('ec2')
try:
    def list_all_ec2_instances():
        client = boto3.client('ec2')
        response = client.describe_security_groups()
        reservations = response['Reservations']
        return list([instance for response['Reservations'] in reservations for instance in response['Reservations']['Instances']])
    def list_sg(security):
        client = boto3.client('ec2')
        response = client.describe_security_groups()
        return list([response for sg in range(len(security)) for range(len(security)) in response(GroupIds=[security[sg]]) ])
    print(list_sg(SECURITY_GROUP_ID))
    def example():
    # for i in range(len(SECURITY_GROUP_ID)):
    #     print(i)
    #     response = ec2.describe_security_groups(GroupIds=[SECURITY_GROUP_ID[i]])
    #     for k in response['SecurityGroups']:
    #         for l in k['IpPermissionsEgress']: 
    #             for m in l['IpRanges']:
                     print('CidrIp')
        #print(response)
except ClientError as e:
    print(e)

def all_sg_CIDR(security):
    try:
        response = client.describe_security_groups(GroupIds=[security])
            
        for i in response['SecurityGroups']:
            for j in i['IpPermissionsEgress']:
                for k in j['IpRanges']:
                    print("IP Ranges Egress: "+k['CidrIp'])
            for j in i['IpPermissions']:
                try:
                    print("PORT: "+str(j['FromPort']))
                    for k in j['IpRanges']:
                        print("IP Ranges Ingress: "+k['CidrIp'])
                            
                except Exception:
                    print("No value for ports and ip ranges available for this security group")
                    continue
    except ClientError as e:
        print(e)