#
# Cookbook Name:: passenger
# Recipe:: production

include_recipe "passenger::default"

package "curl"
if ['ubuntu', 'debian'].member? node[:platform]
  ['libcurl4-openssl-dev','libpcre3-dev'].each do |pkg|
    package pkg
  end
end

rvm_exec_prefix = system("test -e /usr/local/rvm") ? "/usr/local/bin/rvm default exec" : ""
nginx_prefix = node[:passenger][:nginx][:prefix]
nginx_version = node[:passenger][:nginx][:version]

configure_flags = ["--auto", "--prefix=#{nginx_prefix}",
         "--extra-configure-flags='#{node[:passenger][:nginx][:configure_flags]}'"]

unless nginx_version
  configure_flags << "--auto-download"
else
  configure_flags << "--nginx-source-dir=#{Chef::Config[:file_cache_path]}/nginx-#{nginx_version}"

  remote_file "#{Chef::Config[:file_cache_path]}/nginx-#{nginx_version}.tar.gz" do
    source "http://sysoev.ru/nginx/nginx-#{nginx_version}.tar.gz"
    action :create_if_missing
  end

  bash "unpack nginx-#{nginx_version}.tar.gz" do
    cwd Chef::Config[:file_cache_path]
    code "tar zxf nginx-#{nginx_version}.tar.gz"
  end

end

bash "install passenger/#{rvm_exec_prefix.empty? ? "system" : "rvm"}" do
  user "root"
  code "#{rvm_exec_prefix} passenger-install-nginx-module #{configure_flags.join(' ')}"
end

=begin
directory "#{nginx_prefix}/conf/conf.d" do
  mode 0755
  action :create
  recursive true
  notifies :reload, 'service[passenger]'
end
=end

=begin
template "#{nginx_prefix}/conf/nginx.conf" do
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
            :passenger_root => node[:passenger][:root_path],
            :ruby_path => `#{rvm_exec_prefix} which ruby`.chomp,
            :nginx_options => node[:passenger][:nginx],
            :pidfile => "#{nginx_prefix}/logs/nginx.pid"
            )
end
=end
