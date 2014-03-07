#
# Cookbook Name:: omnibus
# Recipe:: _bash
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

include_recipe 'chef-sugar::default'
include_recipe 'build-essential::default'

remote_install 'bash' do
  source 'http://ftp.gnu.org/gnu/bash/bash-4.0.tar.gz'
  version '4.0'
  checksum '9793d394f640a95030c77d5ac989724afe196921956db741bcaf141801c50518'
  build_command './configure'
  compile_command 'make'
  install_command 'make install'
  not_if { installed_at_version?('bash', '4.0') }
end
