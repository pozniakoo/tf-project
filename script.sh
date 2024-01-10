#! /bin/bash
yum -y update
yum -y install ruby
yum -y install wget
cd /home/ec2-user
wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
chmod +x ./install
./install auto
yum install -y python-pip
pip install awscli
update -y
dnf install -y nginx
systemctl start nginx.service
systemctl enable nginx.service
