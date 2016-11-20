#!/usr/bin/env bash
# Shell script to install apache/mysql/php/wordpress into an EC2 instance of Amazon AMI Linux.
# Step 1: Create an AWS EC2 instance
# Step 2: ssh in like: ssh -v -i wordpress.pem ec2-user@ec2-54-185-74-0.us-west-2.compute.amazonaws.com
# Step 3: Run this as root/superuser, do sudo su
echo "Shell script to install apache/mysql/php/wordpress into an EC2 instance of Amazon AMI Linux."
echo "Please run as root, if you're not, choose N now and enter 'sudo su' before running the script."
echo "Run script? (y/n)"
read -e run
if [ "$run" == n ] ; then
echo “chicken...”
exit
else
# we'll install 'expect' to input keystrokes/y/n/passwords
yum -y install expect
# Install Apache
yum -y install httpd
# Start Apache
service httpd start
# Install PHP
yum -y install php php-mysql
# Restart Apache
service httpd restart
# Install MySQL
yum -y install mysql-server
# Start MySQL
service mysqld start
# Create a database named blog
mysqladmin -uroot create blog
# Secure database
# non interactive mysql_secure_installation with a little help from expect.
SECURE_MYSQL=$(expect -c "

set timeout 10
spawn mysql_secure_installation

expect \"Enter current password for root (enter for none):\"
send \"\r\"

expect \"Change the root password?\"
send \"y\r\"
expect \"New password:\"
send \"password\r\"
expect \"Re-enter new password:\"
send \"password\r\"
expect \"Remove anonymous users?\"
send \"y\r\"

expect \"Disallow root login remotely?\"
send \"y\r\"

expect \"Remove test database and access to it?\"
send \"y\r\"

expect \"Reload privilege tables now?\"
send \"y\r\"

expect eof
")

echo "$SECURE_MYSQL"
# Change directory to web root
cd /var/www/html
# Download Wordpress
wget http://wordpress.org/latest.tar.gz
# Extract Wordpress
tar -xzvf latest.tar.gz
# Rename wordpress directory to blog
mv wordpress blog
# Change directory to blog
cd /var/www/html/blog/
# Create a WordPress config file
mv wp-config-sample.php wp-config.php
#set database details with perl find and replace
sed -i "s/database_name_here/blog/g" /var/www/html/blog/wp-config.php
sed -i "s/username_here/root/g" /var/www/html/blog/wp-config.php
sed -i "s/password_here/password/g" /var/www/html/blog/wp-config.php
#create uploads folder and set permissions
mkdir wp-content/uploads
chmod 777 wp-content/uploads
#remove wp file
rm /var/www/html/latest.tar.gz
echo "Ready, go to http://'your ec2 url'/blog and enter the blog info to finish the installation."
fi