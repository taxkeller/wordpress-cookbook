#
# Cookbook:: wordpress
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
bash 'install_wordpress' do
  not_if { File.exists? File.expand_path('/var/www/html/wordpress') }
  user 'root'
  group 'root'
  code <<-EOH
    wget https://ja.wordpress.org/wordpress-4.9-ja.zip -P /tmp
    unzip /tmp/wordpress-4.9-ja.zip -d /var/www/html/
    chown -R apache:users /var/www/html/wordpress
  EOH
end

template '/etc/nginx/nginx.conf' do
  backup false
  source 'nginx.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
end

template '/etc/nginx/conf.d/virtual.conf' do
  backup false
  source 'virtual.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
end

template '/etc/php-fpm.d/www.conf' do
  backup false
  source 'www.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
end

service 'php-fpm' do
  action :restart
end

service 'nginx' do
  action :restart
end
