import boto3
from botocore.exceptions import ClientError

ec2 = boto3.client('ec2')
SECURITY_GROUP_ID = 'sg-0abce2f73daeb4798'
try:
    response = ec2.describe_security_groups(GroupIds=[SECURITY_GROUP_ID])
    #print(response)
    for i in response['SecurityGroups']:
        #print(i['IpPermissionsEgress'])
        m = 0
        l = []
        for j in i['IpPermissionsEgress']:
            #print(j['UserIdGroupPairs'])
            for k in j['UserIdGroupPairs']:
                l.append( k['GroupId'] )
                
            try:
                
                k = j['FromPort']
                if k >= m:
                    m = k
                #print(m)
            except ClientError as e:
                m = 'False'
        print( l )
except ClientError as e:
    print(e)