import boto3
import ipaddress
from ipaddress import IPv4Network, IPv4Address

a = [ '37.212.5.136/32', '172.31.0.0/16', '0.0.0.0/0' ]
b = [ '10.0.1.233',  '10.0.0.19',  '172.31.20.5', '0.0.0.0']

for i in range(len(a)):
    k = IPv4Network(a[i])
    for l in range(len(b)):
        m = IPv4Address(b[l]) in k
        print(m)
    
