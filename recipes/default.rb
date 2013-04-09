#
# Cookbook Name:: omnibus
# Recipe:: default
#
# Copyright 2013, Opscode, Inc.
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

# make certain our chef-solo cache dir exists
directory Chef::Config[:file_cache_path] do
  recursive true
  action :create
end

user node['omnibus']['build_user']

[
  node['omnibus']['install_dir'],
  node['omnibus']['cache_dir']
].each do |dir|
  directory dir do
    mode 0755
    owner node["omnibus"]["build_user"]
    recursive true
  end
end

# apply any platform-specific tweaks
begin
  include_recipe "omnibus::#{node['platform_family']}"
rescue Chef::Exceptions::RecipeNotFound
  Chef::Log.warn "An Omnibus platform recipe does not exist for the platform_family: #{node['platform_family']}"
end

include_recipe "build-essential"
include_recipe "git"

# install ruby and symlink the binaries to /usr/local
# TODO - use a proper Ruby cookbook for this
include_recipe "omnibus::ruby"

# Turn off strict host key checking for github
ruby_block "disable strict host key checking for github.com" do
  block do
    f = Chef::Util::FileEdit.new("/etc/ssh/ssh_config")
    f.insert_line_if_no_match(/github\.com/, <<-EOH

Host github.com
  StrictHostKeyChecking no
EOH
    )
    f.write_file
  end
end

# Ensure SSH_AUTH_SOCK is honored under sudo
ruby_block "make sudo honor ssh_auth_sock" do
  block do
    f = Chef::Util::FileEdit.new("/etc/sudoers")
    f.insert_line_if_no_match(/SSH_AUTH_SOCK/, <<-EOH

Defaults env_keep+=SSH_AUTH_SOCK
EOH
    )
    f.write_file
  end
end
