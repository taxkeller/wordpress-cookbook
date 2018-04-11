#
# Cookbook:: mariadb
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
template '/etc/yum.repos.d/maria.repo' do
  backup false
  source 'maria.repo.erb'
  owner 'root'
  group 'root'
  mode 0644
end

package 'MariaDB-client' do
  action :install
end
