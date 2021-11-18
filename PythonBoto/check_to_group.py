import boto3
from botocore.exceptions import ClientError

ec2 = boto3.client('ec2')
SECURITY_GROUP_ID = ['sg-0b1d61a00f32348d3', 'sg-02dd99ab94bf9731e', 'sg-0abce2f73daeb4798']

for i in range(len(SECURITY_GROUP_ID)):
    response = ec2.describe_security_groups(GroupIds=[SECURITY_GROUP_ID[i]])
    for k in response['SecurityGroups']:
        for j in k['IpPermissionsEgress']:
            try:
                if len( j['UserIdGroupPairs'] ) > 0:
                    for l in j['UserIdGroupPairs']:
                        print(l['GroupId'])
            except Exception:
                print('No SG in SG')
                continue