#!/bin/bash
dnf update -y
dnf install -y nginx
systemctl start nginx.service
systemctl enable nginx.service
echo “Hello World from $(hostname -f)” > /usr/share/nginx/html/index.html