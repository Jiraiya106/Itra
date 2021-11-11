#! python3

import sys
import time
import boto3


def list_all_ec2_instances():
    client = boto3.client('ec2')
    response = client.describe_instances()
    reservations = response['Reservations']
    return list([instance for reservation in reservations for instance in reservation['Instances']])


def list_ec2_sec_group_ids(ec2_instances):
    return list([inst_sec_group.get('GroupId') for ec2_instance in ec2_instances for inst_sec_group in ec2_instance.get('SecurityGroups')])

def list_ec2_sec_group_ingress(ec2_instances):
    return list([inst_sec_group.get('IngressRules') for ec2_instance in ec2_instances for inst_sec_group in ec2_instance.get('SecurityGroups')])

def get_sec_groups(sec_group_ids):
    '''
    Return type : list(ec2.SecurityGroup)
    '''
    client = boto3.resource('ec2')
    return client.security_groups.filter(GroupIds=sec_group_ids)

ec2_instances = list_all_ec2_instances()
print(list_ec2_sec_group_ids(ec2_instances), list_ec2_sec_group_ingress(ec2_instances))