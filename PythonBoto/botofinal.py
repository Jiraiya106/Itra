#! python3

import boto3
from botocore.exceptions import ClientError
from ipaddress import IPv4Interface, IPv4Network, IPv4Address


client = boto3.client('ec2')
vpc_id = 'vpc-0824773dc9094b10b'

#SG
def list_egreess(security):
    response = client.describe_security_groups(GroupIds=[security])
    for i in response['SecurityGroups']:
        for j in i['IpPermissionsEgress']:
            for k in j['IpRanges']:
                m = (k['CidrIp'])
    return m

def list_egreess_port(security):
    response = client.describe_security_groups(GroupIds=[security])
    for i in response['SecurityGroups']:
        m = 0
        for j in i['IpPermissionsEgress']:
            
            try:
                k = j['FromPort']
                if k >= m:
                   m = k
            except ClientError as e:
                m = 'False'
    return m

def list_ingress(security):
    response = client.describe_security_groups(GroupIds=[security])
    for i in response['SecurityGroups']:
        for j in i['IpPermissions']:
            try:
                print("PORT: "+str(j['FromPort']))
                for k in j['IpRanges']:
                    print("IP Ranges Ingress: "+k['CidrIp'])
            except Exception:
                print("No value for ports and ip ranges available for this security group")
                continue

def list_ingress_port(security):
    response = client.describe_security_groups(GroupIds=[security])
    for i in response['SecurityGroups']:
        for j in i['IpPermissions']:
                m = j['FromPort']
    return m

def list_ingress_cidr(security):
    response = client.describe_security_groups(GroupIds=[security])
    for i in response['SecurityGroups']:
        for j in i['IpPermissions']:
            try:
                for k in j['IpRanges']:
                    m = (k['CidrIp'])
            except Exception:
                print("No value for ports and ip ranges available for this security group")
                continue
    return m


def list_true_false_address(a, b):
    k = IPv4Network(a)
    m = IPv4Address(b) in k
    return m

def egress_check( a, b):
        if list_egreess(a) == '0.0.0.0/0' and str(list_egreess_port(a)) == '0':
                res = True
        else:
                if list_ingress_port( b )==list_egreess_port( a ):
                    res = True
                    if IPv4Network(list_egreess(a)).compare_networks(IPv4Network(list_ingress_cidr(b))) >= 0:
                        res = True
                    else:
                        res = False
                        print( 'Address error' )
                else:
                    res = False
                    print( 'Port error' )
        return res

def check_egress_group(a):
    response = client.describe_security_groups(GroupIds=[a])
    for k in response['SecurityGroups']:
        for j in k['IpPermissionsEgress']:
            try:
                if len( j['UserIdGroupPairs'] ) > 0:
                    for l in j['UserIdGroupPairs']:
                        print(l['GroupId'])
            except Exception:
                print('No SG in SG')
                continue

#EC2
def list_all_ec2_instances(client, vpc_id):
    response = client.describe_instances(Filters = [{'Name': 'vpc-id', 'Values': [vpc_id]}])
    reservations = response['Reservations']
    return list([ instance for reservation in reservations for instance in reservation['Instances'] ])


def list_ec2_sec_group_ids(ec2_instances):
    return list([inst_sec_group.get('GroupId') for ec2_instance in ec2_instances for inst_sec_group in ec2_instance.get('SecurityGroups')])
     

def list_ec2_id(ec2_instances):
    return list([ec2_instance.get('InstanceId') for ec2_instance in ec2_instances])

def list_private_address_ec2(ec2_instances):
    return list([ec2_instance.get('PrivateIpAddress') for ec2_instance in ec2_instances])

#RDS
def list_all_rds_instances(vpc_id):
    client = boto3.client('rds')
    response = client.describe_db_instances()
    return list( filter( lambda x: x["DBSubnetGroup"]["VpcId"] == vpc_id, response["DBInstances"] ) ) 

def list_rds_sec_group_ids(rds_instances):
    return list([rds_sec_group['VpcSecurityGroupId'] for rds_instance in rds_instances for rds_sec_group in rds_instance.get('VpcSecurityGroups')])

def list_rds_name(rds_instances):
    return list([rds_instance['DBInstanceIdentifier'] for rds_instance in rds_instances])


#Main
def main():
    for i in range(len(id_ec2)):
        print( 'EC2 Instances: ' +  id_ec2[i])
        print( 'Private address EC2: ' + ec2_address[i] + '\n')
        for k in range(len(rds)):
            print( 'RDS Instance: ' + rds[k] )
            print( list_ingress_cidr( rds_sg[k] ) )
            if egress_check( ec2_sg[i], rds_sg[k]) == True:
                print('Instance ' + id_ec2[i] + ' ' + 'in ingress ' + rds_sg[k] + ': ' + str( list_true_false_address( list_ingress_cidr( rds_sg[k] ), ec2_address[i]) ))
            else:
                print('Instance ' + id_ec2[i] + ' ' + 'in ingress ' + rds_sg[k] + ': False-2')
            print( " " )

rds_instances = list_all_rds_instances(vpc_id)
ec2_instances = list_all_ec2_instances(client, vpc_id)

rds = list_rds_name(rds_instances)
rds_sg = list_rds_sec_group_ids(rds_instances)

id_ec2 = list_ec2_id(ec2_instances)
ec2_sg = list_ec2_sec_group_ids(ec2_instances)
ec2_address = list_private_address_ec2(ec2_instances)

main()