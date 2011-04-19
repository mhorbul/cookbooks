#
# Cookbook Name:: rvm
# Recipe:: default
#
# Copyright 2011, Papercavalier
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "apt" if [ 'debian', 'ubuntu' ].member? node[:platform]

# Make sure we have all we need to compile ruby implementations:
include_recipe "git"
package "curl"
include_recipe "build-essential"

# Ensure packages required by MRI are installed
if platform?("debian", "ubuntu")
  %w{bison openssl libreadline5 libreadline5-dev zlib1g zlib1g-dev libssl-dev
     libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev}
elsif platform?("centos", "redhat", "fedora", "suse")
  %w{patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel}
else
  []
end.each { |name| package name }

bash "installing system-wide RVM stable" do
  user "root"
  code "bash < <( curl -s https://rvm.beginrescueend.com/install/rvm )"
  not_if "which rvm"
end

bash "upgrading to RVM head" do
  user "root"
  code "rvm update --head ; rvm reload"
  only_if { node[:rvm][:track_updates] && node[:rvm][:version] == :head }
end

bash "upgrading RVM stable" do
  user "root"
  code "rvm update ; rvm reload"
  only_if { node[:rvm][:track_updates] }
end

template "/etc/profile.d/rvm.sh" do
  source "rvm.sh.erb"
  owner "root"
  group "root"
  mode 0755
end

restart "login_shell" unless system("test -e /usr/local/bin/rvm")

unless node[:rvm][:usernames].empty?

  node[:rvm][:usernames] << "root" unless node[:rvm][:usernames].include?("root")

  group "rvm" do
    members(node[:rvm][:usernames] || ["root"])
  end

end

# Add default ruby to the list of rubies for install if it's not there yet
unless node[:rvm][:ruby][:versions].include?(node[:rvm][:ruby][:default])
  node[:rvm][:ruby][:versions] << node[:rvm][:ruby][:default]
end

# Install all rubies
node[:rvm][:ruby][:versions].each do |version|

  bash "Installing Ruby #{version}" do
    user "root"
    code "rvm install #{version}"
    not_if "rvm list | grep #{version}"
  end

end

bash "Make Ruby #{node[:rvm][:ruby][:default]} the default" do
  user "root"
  code "rvm --default #{node[:rvm][:ruby][:default]}"
  not_if "rvm list | grep '=> #{node[:rvm][:ruby][:default]}'"
  only_if { node[:rvm][:ruby][:default] }
end

gem_exec_cmd = "rvm #{node[:rvm][:ruby][:default]}@global gem"

node[:rvm][:ruby][:gems].each do |gem|
  gem_package "#{gem}" do
    gem_binary "#{gem_exec_cmd}"
  end
end
