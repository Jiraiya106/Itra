#! python3

import boto3


def list_all_rds_instances():
    client = boto3.client('rds')
    response = client.describe_db_instances()
    return response.get('DBInstances')


def list_rds_sec_group_ids(rds_instances):
    return list([rds_sec_group['VpcSecurityGroupId'] for rds_instance in rds_instances for rds_sec_group in rds_instance.get('VpcSecurityGroups')])

rds_instances = list_all_rds_instances()
print(list_rds_sec_group_ids(rds_instances))

client = boto3.client('rds')
response = client.describe_db_security_groups()
print(response)
# for i in response['SecurityGroups']:
#     print("Security Group Name: "+i['GroupName'])
#     print("the Egress rules are as follows: ")
#     for j in i['IpPermissionsEgress']:
#         print("IP Protocol: "+j['IpProtocol'])
#         for k in j['IpRanges']:
#             print("IP Ranges: "+k['CidrIp'])
#     for j in i['IpPermissions']:
#         print("IP Protocol: "+j['IpProtocol'])
#         try:
#             print("PORT: "+str(j['FromPort']))
#             for k in j['IpRanges']:
#                 print("IP Ranges: "+k['CidrIp'])
#         except Exception:
#             print("No value for ports and ip ranges available for this security group")
#             continue