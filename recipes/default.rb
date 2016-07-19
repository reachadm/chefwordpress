#
# Cookbook Name:: mywp
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
execute 'disable selinux' do
  command 'setenforce 0'
end

package 'httpd' do
  action :install
end

service 'httpd' do
  action [:enable, :start]
end

#cookbook_file '/etc/httpd/conf/httpd.conf' do
#  source 'httpd.conf'
#end

package 'mariadb-server' do
  action :install
end

package 'mariadb' do
  action :install
end

service 'mariadb' do
  action [:enable, :start]
end

execute 'setrootpass' do
  command 'mysqladmin -u root password rootpassword && touch /tmp/done'
  not_if {File.exists?("/tmp/done")}
end

#execute 'installphp' do
#  command 'yum -y install php php-mysql php-gd php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap curl'
#end
%w[ php php-mysql php-gd php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap curl ].each do |pkg|
  package pkg do
    action :install
  end
end

cookbook_file '/tmp/mysqlcommands' do
  source 'mysqlcommands'
end

#execute 'createdb' do
#  command 'mysql -uroot -prootpassword 'create database wordpress && touch /tmp/dbdone'
#  not_if {File.exists?("/tmp/dbdone")}
#end

execute 'database' do
  command 'mysql -uroot -prootpassword < /tmp/mysqlcommands && touch /tmp/dbdone'
  not_if {File.exists?("/tmp/dbdone")}
end

remote_file '/tmp/latest.zip' do
  source 'https://wordpress.org/latest.zip'
  not_if {File.exists?("/tmp/latest.zip")}
end

package 'unzip' do
  action :install
end

execute 'unziplatest' do
  command 'unzip /tmp/latest.zip -d /var/www/html'
  not_if {File.exists?("/var/www/html/wordpress/index.php")}
end

#directory '/var/www/html/wordpress' do
#  owner 'apache'
#  group 'apache'
#  mode '0755' 
#end

execute 'htmldirpermissions' do
  command 'chmod -R 775 /var/www/html/wordpress'
end

execute 'htmldirowner' do
  command 'chown -R apache:apache /var/www/html/wordpress'
end

cookbook_file '/var/www/html/wordpress/wp-config.php' do
  source 'wp-config-sample.php'
  action :create
end
