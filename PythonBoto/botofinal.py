#! python3

import boto3
from botocore.exceptions import ClientError

client = boto3.client('ec2')
vpc_id = 'vpc-0824773dc9094b10b'

#SG
def all_sg_CIDR(security):
    try:
            response = client.describe_security_groups(GroupIds=[security])
            for i in response['SecurityGroups']:
                print("Security Group Name: "+i['GroupName'])
                print("the Egress rules are as follows: ")
                for j in i['IpPermissionsEgress']:
                    print("IP Protocol: "+j['IpProtocol'])
                    for k in j['IpRanges']:
                        print("IP Ranges Egress: "+k['CidrIp'])
                for j in i['IpPermissions']:
                    print("IP Protocol: "+j['IpProtocol'])
                    try:
                        print("PORT: "+str(j['FromPort']))
                        for k in j['IpRanges']:
                            print("IP Ranges Ingress: "+k['CidrIp'])
                    except Exception:
                        print("No value for ports and ip ranges available for this security group")
                        continue
    except ClientError as e:
        print(e)

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
        print( all_sg_CIDR( ec2_sg[i]) )
        print( 'Private address EC2: ' + ec2_address[i] + '\n')
    for i in range(len(rds)):
        print( 'RDS Instance: ' + rds[i] )
        print( all_sg_CIDR( rds_sg[i] ) )
        print( " " )

rds_instances = list_all_rds_instances(vpc_id)
ec2_instances = list_all_ec2_instances(client, vpc_id)

rds = list_rds_name(rds_instances)
rds_sg = list_rds_sec_group_ids(rds_instances)

id_ec2 = list_ec2_id(ec2_instances)
ec2_sg = list_ec2_sec_group_ids(ec2_instances)
ec2_address = list_private_address_ec2(ec2_instances)

#print( ec2_address )
main()