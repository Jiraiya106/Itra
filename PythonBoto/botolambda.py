#! python3

import boto3
import datetime

EC2_RESOURCE = boto3.resource('ec2')
EC2_CLIENT = boto3.client('ec2')
STS_CLIENT = boto3.client('sts')
CURRENT_ACCOUNT_ID = STS_CLIENT.get_caller_identity()['Account']
NOW = datetime.datetime.now()
DEFAULTRETENTION = 3
DRYRUN = 'DryRun'

SNAPSHOTS = EC2_RESOURCE.snapshots.filter(
    OwnerIds=[
        CURRENT_ACCOUNT_ID
    ]
)

#Create snapshot
def volumeId():
    res = []
    for volume in EC2_RESOURCE.volumes.all():
        if type(volume.tags) == list:
            for i in volume.tags:
                if i['Key'] == 'Backup':
                    if i['Value'] == 'True':
                        res.append(volume.id)
    return res

def saveOldTags(volume_id):
    res = []
    volume = EC2_RESOURCE.Volume( volume_id )
    for i in volume.tags:
        if i['Key'] == 'Backup':
            continue
        else:
            res.append(i)
    return res

def intSaveOldTags(volume_id):
    if len(saveOldTags(volume_id)) != 0:
        saveOldTags(volume_id)
    else:
        res = {
            'Key': 'No',
            'Value': 'Value'
        }
    return res

def tagRetention(volume_id):
    volume = EC2_RESOURCE.Volume( volume_id )
    for i in volume.tags:
        if i['Key'] == 'BackupRetention':
            if int(i['Value']) > 0: 
                res = i['Value']
                break
            else:
                res = DEFAULTRETENTION
                break
        else:
            print( 'Volume ' + volume_id + ' has Tag: ' + i['Key'] )
            res = DEFAULTRETENTION
    print( res )
    return res

def createSnapshot(volume_id):
    volume = EC2_RESOURCE.Volume( volume_id )
    volume.create_snapshot(
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
                        'Value': tagRetention(volume_id)
                    },
                    {
                        'Key': 'BackupCreated',
                        'Value': '20-11-2021'#str(NOW.strftime("%d-%m-%Y"))
                    },
                    #saveOldTags(volume_id)
                ]
            },
        ],
    )

def createSnapshots():
    volume_list = volumeId()
    for volume in volume_list:
        print( volume )
        createSnapshot( volume )
    print( '\n It is all' )

#Delete Snapshot
def tagRetentionSnapshot(snapshot_id):
    for snapshot in SNAPSHOTS:
        if snapshot.id == snapshot_id:
            try:
                for tags in snapshot.tags:
                    if tags['Key'] == 'BackupRetention':
                        res = tags['Value']
            except:
                print('False')
    return res

def deleteSnapshot():
    for snapshot in SNAPSHOTS:
        try:
            for tags in snapshot.tags:
                if tags['Key'] == 'BackupCreated':
                    if datetime.datetime.strptime(tags['Value'],"%d-%m-%Y" ) + datetime.timedelta(days=int(tagRetentionSnapshot( snapshot.id ))) <= datetime.datetime.now():
                        if DRYRUN == 'DryRun':
                            EC2_RESOURCE.Snapshot( snapshot.id ).delete()
                        print('Snapshot deleted: ' + snapshot.id)
                    else: 
                        print('Snapshot does not deleted: ' + snapshot.id)
        except:
            print( 'Snapshot ' + snapshot.id + ' has not Tags' )

#DryRun

def deleteDryRun():
    for snapshot in SNAPSHOTS:
        try:
            for tags in snapshot.tags:
                if tags['Key'] == 'BackupCreated':
                    if datetime.datetime.strptime(tags['Value'],"%d-%m-%Y" ) + datetime.timedelta(days=int(tagRetentionSnapshot( snapshot.id ))) <= datetime.datetime.now():
                        print('Snapshot deleted: ' + snapshot.id)
                    else: 
                        print('Snapshot does not deleted: ' + snapshot.id)
        except:
             print( 'Snapshot ' + snapshot.id + ' has no Tags' )

def dryRun():
    volume_list = volumeId()
    for volume in volume_list:
        print('Volume created: ' + volume)
    deleteSnapshot()
    #deleteDryRun()

dryRun()

def main():
    print(' ')
    deleteSnapshot()
    createSnapshots()