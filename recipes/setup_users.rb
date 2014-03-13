#
# Cookbook Name:: rs-jenkins
# Recipe:: setup_users
#
# Copyright (C) 2013 RightScale, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

marker "recipe_start_rightscale" do
  template "rightscale_audit_entry.erb"
end

service "jenkins" do
  action :stop
end

# Create the Jenkins user directory
directory "#{node[:'rs-jenkins'][:server][:home]}/users/" +
  "#{node[:'rs-jenkins'][:server][:user_name]}" do
  recursive true
  mode 0755
  owner node[:'rs-jenkins'][:server][:system_user]
  group node[:'rs-jenkins'][:server][:system_group]
end

# Create the Jenkins configuration file to include matrix based security
template "#{node[:'rs-jenkins'][:server][:home]}/config.xml" do
  source "jenkins_config.xml.erb"
  mode 0644
  owner node[:'rs-jenkins'][:server][:system_user]
  group node[:'rs-jenkins'][:server][:system_group]
  variables(
    :user => node[:'rs-jenkins'][:server][:user_name]
  )
end


# Obtain the hash of the password.
chef_gem "bcrypt-ruby"

require "bcrypt"
node[:'rs-jenkins'][:server][:password_encrypted] = ::BCrypt::Password.create(
  node[:'rs-jenkins'][:server][:password]
)

# Create Jenkins user configuration file.
template "#{node[:'rs-jenkins'][:server][:home]}/users/" +
  "#{node[:'rs-jenkins'][:server][:user_name]}/config.xml" do
  source "jenkins_user_config.xml.erb"
  mode 0644
  owner node[:'rs-jenkins'][:server][:system_user]
  group node[:'rs-jenkins'][:server][:system_group]
  variables(
    :user_full_name => node[:'rs-jenkins'][:server][:user_full_name],
    :password_encrypted => node[:'rs-jenkins'][:server][:password_encrypted],
    :email => node[:'rs-jenkins'][:server][:user_email]
  )
end

service "jenkins" do
  action :start
end

