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
            res = i['Value']
    return res

def saveOldTags(a):
    res = []
    volume = ec2.Volume(a)
    for i in volume.tags:
        if i['Key'] == 'Backup':
            continue
        else:
            res.append(i)
    return res 

print(saveOldTags( 'vol-0016e7ea6327b2338' ))
#print(tagRetention('vol-0016e7ea6327b2338'))
#print(volume_id())
