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