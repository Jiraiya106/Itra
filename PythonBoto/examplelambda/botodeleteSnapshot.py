import boto3
import datetime


EC2_RESOURCE = boto3.resource('ec2')
STS_CLIENT = boto3.client('sts')
CURRENT_ACCOUNT_ID = STS_CLIENT.get_caller_identity()['Account']
NOW = datetime.datetime.now()

snapshots = EC2_RESOURCE.snapshots.filter(
    OwnerIds=[
        CURRENT_ACCOUNT_ID
    ]
)

def tagRetentionSnapshot(snapshot_id):
    for snapshot in snapshots:
        if snapshot.id == snapshot_id:
            try:
                for tags in snapshot.tags:
                    if tags['Key'] == 'BackupRetention':
                        res = tags['Value']
            except:
                print('False')
    return res

def listSnapshotOnDelete():
    for snapshot in snapshots:
        try:
            for tags in snapshot.tags:
                if tags['Key'] == 'BackupCreated':
                    if datetime.datetime.strptime(tags['Value'],"%d-%m-%Y" ) + datetime.timedelta(days=tagRetentionSnapshot( snapshot.id )) <= datetime.datetime.now():
                        EC2_RESOURCE.Snapshot( snapshot.id ).delete()
                        print('True')
                    else: 
                        print('False')
        except:
            print( 'Snapshot ' + snapshot.id + 'has not Tags' )

tagRetentionSnapshot( 'snap-00dba793660c82d1d' )

