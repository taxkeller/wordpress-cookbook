#
# Cookbook:: logs
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
package 'awslogs' do
  action :install
end

template '/etc/awslogs/awslogs.conf' do
  source 'awslogs.conf.erb'
  owner 'root'
  group 'root'
  mode 0600
end

template '/etc/awslogs/awscli.conf' do
  source 'awscli.conf.erb'
  owner 'root'
  group 'root'
  mode 0600
end

service 'awslogs' do
  action :restart
end
