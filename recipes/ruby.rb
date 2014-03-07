#
# Cookbook Name:: omnibus
# Recipe:: ruby
#
# Copyright 2013, Chef Software, Inc.
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

case node['platform_family']
when 'windows'
  include_recipe 'omnibus::ruby_windows'
else
  include_recipe 'omnibus::_chruby'
  include_recipe 'omnibus::_ruby_install'

  ruby_version = node['omnibus']['ruby_version']

  ruby_install ruby_version do
    default true
  end

  ruby_gem 'bundler' do
    ruby ruby_version
  end
end
