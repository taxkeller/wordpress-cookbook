#
# Cookbook:: environment
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
template '/etc/environment' do
  source 'environment.erb'
  owner 'root'
  group 'root'
  mode 0644
end

link '/etc/localtime' do
  to "/usr/share/zoneinfo/#{node['timezone']}"
end
