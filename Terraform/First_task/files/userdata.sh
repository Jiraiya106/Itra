#!/bin/bash
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install mysql-client -y
sudo apt-get install apache2 apache2-utils -y
sudo apt-get install php7.4 -y
sudo apt-get install php7.4 libapache2-mod-php7.4 php7.4-curl php7.4-gd php7.4-xmlrp -y
sudo apt-get install php7.4-mysql -y
sudo systemctl restart apache2 
sudo wget -c https://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sleep 20
sudo mkdir -p /var/www/html/
sudo rsync -av wordpress/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo mkdir -p /var/www/html/wp-content/mu-plugins/
sudo rm /var/www/html/index.html
sudo systemctl restart apache2
sleep 20