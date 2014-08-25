#
# Cookbook Name:: omnibus
# Recipe:: _packaging
#
# Copyright 2014, Chef Software, Inc.
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

# Include the common recipe
include_recipe 'omnibus::_common'

#
# This recipe is used to install the "packaging" compontents.
#

case node['platform_family']
when 'debian'
  package 'devscripts'
  package 'dpkg-dev'
  package 'fakeroot'
  package 'ncurses-dev'
  package 'zlib1g-dev'
when 'freebsd'
  package 'ncurses'
when 'mac_os_x'
when 'rhel'
  package 'fakeroot'
  package 'ncurses-devel'
  package 'rpm-build'
  package 'zlib-devel'
when 'windows'
  include_recipe '7-zip::default'
  include_recipe 'wix::default'

  omnibus_env['PATH'] << node['wix']['home']
  omnibus_env['PATH'] << node['7-zip']['home']
end
