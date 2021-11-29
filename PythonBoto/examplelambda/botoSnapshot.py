import boto3

ec2 = boto3.resource('ec2')
volume = ec2.Volume( 'vol-021187df3aaadec5c' ) 
# snapshot1 = ec2.Snapshot('vol-0016e7ea6327b2338')

def tagRetention(a):
    volume = ec2.Volume(a)
    for i in volume.tags:
        if i['Key'] == 'BackupRetention':
            res = i['Value']
    return res


snapshot = volume.create_snapshot(
    Description='Example',
    #OutpostArn='string',
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
                    'Value': str(volume.create_time)
                },                                
            ]
        },
    ],
    #DryRun=True|False
)

# response = snapshot1.copy(
#     Description='Example',
#     #DestinationOutpostArn='string',
#     #Encrypted=True|False,
#     #KmsKeyId='string',
#     SourceRegion='us-west-2',
#     TagSpecifications=[
#         {
#             #'ResourceType': 'capacity-reservation'|'client-vpn-endpoint'|'customer-gateway'|'carrier-gateway'|'dedicated-host'|'dhcp-options'|'egress-only-internet-gateway'|'elastic-ip'|'elastic-gpu'|'export-image-task'|'export-instance-task'|'fleet'|'fpga-image'|'host-reservation'|'image'|'import-image-task'|'import-snapshot-task'|'instance'|'instance-event-window'|'internet-gateway'|'ipv4pool-ec2'|'ipv6pool-ec2'|'key-pair'|'launch-template'|'local-gateway'|'local-gateway-route-table'|'local-gateway-virtual-interface'|'local-gateway-virtual-interface-group'|'local-gateway-route-table-vpc-association'|'local-gateway-route-table-virtual-interface-group-association'|'natgateway'|'network-acl'|'network-interface'|'network-insights-analysis'|'network-insights-path'|'placement-group'|'prefix-list'|'replace-root-volume-task'|'reserved-instances'|'route-table'|'security-group'|'security-group-rule'|'snapshot'|'spot-fleet-request'|'spot-instances-request'|'subnet'|'traffic-mirror-filter'|'traffic-mirror-session'|'traffic-mirror-target'|'transit-gateway'|'transit-gateway-attachment'|'transit-gateway-connect-peer'|'transit-gateway-multicast-domain'|'transit-gateway-route-table'|'volume'|'vpc'|'vpc-endpoint'|'vpc-endpoint-service'|'vpc-peering-connection'|'vpn-connection'|'vpn-gateway'|'vpc-flow-log',
#             'Tags': [
#                 {
#                     'Key': 'BackupDescription',
#                     'Value': 'string'
#                 },
#                 {
#                     'Key': 'BackupRetention',
#                     'Value': 'string'
#                 },
#                 {
#                     'Key': 'BackupCreated',
#                     'Value': 'string'
#                 },                                
#             ]
#         },
#     ],
#     #DryRun=True|False
# )
