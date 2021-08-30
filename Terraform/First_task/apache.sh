#!/bin/bash
sudo apt -y update
sudo apt -y install apache2
myip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4) > /var/www/html/index.html
echo "<h2>WebServer with IP: $myip</h2> Build by Terraform" >> /var/www/html/index.html
sudo service apache2 start
chkconfig apache2 on