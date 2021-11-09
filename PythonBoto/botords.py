#! python3

import boto3

def main():
    rds = boto3.client('rds')
    response = rds.describe_db_instances()
    rds_instances = list( filter( lambda x: x["DBSubnetGroup"]["VpcId"] == 'vpc-dc6768a4', response["DBInstances"] ) )
    if len(rds_instances) > 0:
        print("\nRDS Instances")
        for rds in rds_instances:
            print(rds["DBInstanceIdentifier"])
    else:
        print("There is no RDS instance in this VPC!")

main()

