#! /bin/bash
wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm
yum install mysql80-community-release-el9-1.noarch.rpm -y
dnf install mysql-community-server -y

yum update -y
yum install httpd -y
yum install php php-mysqli -y
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xvf latest.tar.gz
rm latest.tar.gz
mv wordpress/* .
rm -rf wordpress/
cd /var/www/html
mv wp-config-sample.php wp-config.php
sudo systemctl start httpd
### TO CONFIGURE
#mysql -h <database_endpoint> -u <database_username> -p
#CREATE USER 'wordpress' IDENTIFIED BY 'wordpress-pass';
#GRANT ALL PRIVILEGES ON wordpress.* TO wordpress;
#FLUSH PRIVILEGES;
#Exit
#sudo vim wp-config.php
