package "git"

bash "cleanup" do
    code <<-eos
        rm -rf /tmp/redis
        rm -f /var/log/redis*.log
    eos
end

git "/tmp/redis" do
   repository "https://github.com/antirez/redis.git"
   reference node[:build][:ref]
   action :sync
end

bash "install_redis" do
   cwd "/tmp/redis"
   code <<-eos
      ./configure
      make
      make install
   eos
end

# redis configs
template "/etc/redis.conf" do
    source 'redis.conf.erb'
end

template "/etc/redis-sentinel.conf" do
    source 'redis-sentinel.conf.erb'
end

# service configs
template '/etc/init/redis.conf' do
    source 'redis.upstart.erb'
    owner 'root'
    group 'root'
    mode '0644'
    notifies :restart, 'service[redis]'
end
template '/etc/init/redis-sentinel.conf' do
    source 'redis-sentinel.upstart.erb'
    owner 'root'
    group 'root'
    mode '0644'
    notifies :restart, 'service[redis-sentinel]'
end

# services
service 'redis' do
    action [ :enable, :start ]
    provider Chef::Provider::Service::Upstart
end
service 'redis-sentinel' do
    action [ :enable, :start ]
    provider Chef::Provider::Service::Upstart
end
