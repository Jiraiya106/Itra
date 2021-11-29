import boto3

#AWS_REGION = "us-east-2"

ec2 = boto3.resource('ec2')

def volume_id():
    res = []
    for volume in ec2.volumes.all():
        if type(volume.tags) == list:
            for i in volume.tags:
                if i['Key'] == 'Backup':
                    if i['Value'] == 'True':
                        res.append(volume.id)
    return res

def tagRetention(a):
    volume = ec2.Volume(a)
    for i in volume.tags:
        if i['Key'] == 'BackupRetention':
            print( i['Value'] )

tagRetention('vol-0016e7ea6327b2338')
#print(volume_id())
