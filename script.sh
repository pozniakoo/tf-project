#! /bin/bash
dnf install wget php-mysqlnd httpd php-fpm php-mysqli mariadb105-server php-json php php-devel -y
cd home/ec2-user/
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
systemctl start mariadb httpd

