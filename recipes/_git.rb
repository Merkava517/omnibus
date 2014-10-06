#
# Cookbook Name:: omnibus
# Recipe:: _git
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

if windows?
  windows_package 'Git version 1.9.0-preview20140217' do
    source 'https://github.com/msysgit/msysgit/releases/download/Git-1.9.0-preview20140217/Git-1.9.0-preview20140217.exe'
    checksum '22d2d3f43c8a3eb59820c50da81022e98d4df92c333dffaae1ae88aefbceedfc'
    installer_type :inno
    action :install
  end

  # Git is installed to Program Files (x86) on 64-bit machines and
  # 'Program Files' on 32-bit machines
  program_files = ENV['ProgramFiles(x86)'] || ENV['ProgramFiles']

  git_paths  = []
  git_paths << windows_safe_path_join(program_files, 'Git', 'Cmd')
  git_paths << windows_safe_path_join(program_files, 'Git', 'libexec', 'git-core')
  git_path   = git_paths.join(';')

  # COOK-3482 - windows_path resource doesn't change the current process
  # environment variables. Therefore, git won't actually be on the PATH
  # until the next chef-client run
  ruby_block 'add-git-to-current-path' do
    block do
      ENV['PATH'] << ";#{git_path}"
    end
    action :nothing
  end

  windows_path git_path do
    action :add
    notifies :create, 'ruby_block[add-git-to-current-path]', :immediately
  end

  omnibus_env['PATH'] << git_path
else
  include_recipe 'omnibus::_bash'
  include_recipe 'omnibus::_compile'
  include_recipe 'omnibus::_openssl'
  include_recipe 'omnibus::_user'

  make = 'make'

  case node['platform_family']
  when 'debian'
    package 'gettext'
    package 'libcurl4-gnutls-dev'
    package 'libexpat1-dev'
    package 'libz-dev'
    package 'perl-modules'
  when 'freebsd'
    package 'curl'
    # expat package name changed on FreeBSD 10
    if node['platform_version'] =~ /10/
      package 'expat'
    else
      package 'expat2'
    end
    package 'gettext'
    package 'libzip'
    package 'perl5' do
      source 'ports'
      not_if 'perl -v | grep "perl 5"'
    end
    # FreeBSD requires gmake instead of make
    make = 'gmake'
  when 'mac_os_x'
    package 'curl'
    package 'expat'
    package 'gettext'
  when 'rhel'
    package 'curl-devel'
    package 'expat-devel'
    package 'gettext-devel'
    package 'perl-ExtUtils-MakeMaker' if version(node['platform_version']).satisfies?('>= 6')
    package 'zlib-devel'
  when 'suse'
    package 'libcurl-devel'
    package 'libexpat-devel'
    package 'gettext-runtime'
    package 'zlib-devel'
  end

  remote_install 'git' do
    source          'https://git-core.googlecode.com/files/git-1.9.0.tar.gz'
    checksum        'de3097fdc36d624ea6cf4bb853402fde781acdb860f12152c5eb879777389882'
    version         '1.9.0'
    build_command   './configure --prefix=/usr/local --without-tcltk'
    compile_command "#{make} -j #{node.builders}"
    install_command "#{make} install"
    environment     'NO_GETTEXT' => '1'
    not_if { installed_at_version?('git', '1.9.0') }
  end

end

file File.join(build_user_home, '.gitconfig') do
  owner   node['omnibus']['build_user']
  group   node['omnibus']['build_user_group']
  mode    '0644'
  content <<-EOH.gsub(/^ {4}/, '')
    # This file is written by Chef for #{node['fqdn']}.
    # Do NOT modify this file by hand.

    [user]
      ; Set a sane user name and email. This makes git happy and prevents
      ; spammy output on each git command.
      name  = Omnibus
      email = omnibus@getchef.com
    [color]
      ; Since this is a build machine, we do not want colored output.
      ui = false
    [core]
      editor = $EDITOR
      whitespace = fix
    [apply]
      whitespace = fix
    [push]
      default = tracking
    [branch]
      autosetuprebase = always
    [pull]
      rebase = preserve
  EOH
end
