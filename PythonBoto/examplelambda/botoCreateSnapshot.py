import boto3
import datetime

now = datetime.datetime.now()

def saveOldTags(a):
    res = []
    volume = ec2.Volume(a)
    for i in volume.tags:
        if i['Key'] == 'Backup':
            continue
        else:
            res.append(i)
    return res

ec2 = boto3.resource('ec2')
#volume = ec2.Volume( 'vol-0016e7ea6327b2338' ) 

def tagRetention(a):
    volume = ec2.Volume(a)
    for i in volume.tags:
        if i['Key'] == 'BackupRetention':
            res = i['Value']
    return res

def createSnaphot(volume_id):
    volume = ec2.Volume( volume_id )
    snapshot = volume.create_snapshot(
        Description='Example',
        TagSpecifications=[
            {
                'ResourceType': 'snapshot',
                'Tags': [
                    {
                        'Key': 'Name',
                        'Value': 'Example'
                    },
                    {
                        'Key': 'BackupDescription',
                        'Value': 'string'
                    },
                    {
                        'Key': 'BackupRetention',
                        'Value': tagRetention(volume.id)
                    },
                    {
                        'Key': 'BackupCreated',
                        'Value': str(now.strftime("%d-%m-%Y"))
                    },
                    saveOldTags(volume.id)[0]                                
                ]
            },
        ],
    )


