#
# Cookbook:: php
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
bash 'update_yum_version' do
  not_if { File.exists?('/tmp/latest.rpm') }
  user 'root'
  cwd '/tmp'
  code <<-EOH
    wget https://mirror.webtatic.com/yum/el6/latest.rpm -P /tmp
    sudo yum install /tmp/latest.rpm
    sudo yum clean all
    sudo yum update
  EOH
end

%(php71 php71-intl php71-cli php71-fpm php71-gd php71-json php71-readline php71-mbstring php71-dom php71-curl php71-mysqlnd php71-mcrypt).each_with index do |pack|
  log pack
  package pack do
    action :install
  end
end

bash 'install_composer' do
  not_if { File.exists?('/usr/local/bin/composer') }
  user 'root'
  cwd '/tmp'
  code <<-EOH
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/tmp
    mv /tmp/composer.phar /usr/local/bin/composer
  EOH
end
