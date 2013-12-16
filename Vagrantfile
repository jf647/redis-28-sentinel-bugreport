proxy = nil
# Uncomment and modify this line if you need a proxy.  You will also need
# vagrant-proxyconf plugin installed first
#proxy = 'http://10.138.15.10:8080'

distro_to_image = {
    'centos' => %w(CentOS-6.4-x86_64 https://github.com/2creatives/vagrant-centos/releases/download/v0.1.0/centos64-x86_64-20131030.box),
    'ubuntu' => %w(Ubuntu-12.04-x86_64 http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box)
}

distro_to_pkgcmd = {
    'centos' => 'yum',
    'ubuntu' => 'apt-get',
}


Vagrant.configure("2") do |config|

    config.ssh.forward_agent = true
    if ! proxy.nil?
        config.proxy.https    = proxy
        config.proxy.http     = proxy
        config.proxy.ftp      = proxy
        config.proxy.no_proxy = "localhost,10.138.1.252,127.0.0.1,.oam.cepl"
        config.env_proxy.https    = proxy
        config.env_proxy.http     = proxy
        config.env_proxy.ftp      = proxy
        config.env_proxy.no_proxy = "localhost,10.138.1.252,127.0.0.1,.oam.cepl"
    end

    %w(centos ubuntu).each do |distro|
        1.upto(3).each do |i|
            config.vm.define "#{distro}-#{i}" do |v|
                v.vm.box = distro_to_image[distro][0]
                v.vm.box_url = distro_to_image[distro][1]
                v.vm.hostname = "#{distro}-#{i}.vagrant"
                v.vm.provider :virtualbox do |vb|
                    vb.customize ["modifyvm", :id, "--memory", "1024"]
                    vb.customize ["modifyvm", :id, "--nic2", "intnet"]
                    vb.customize ["modifyvm", :id, "--nictype2", "82545EM"]
                end
                shellcmds = [
                    "#{distro_to_pkgcmd[distro]} install -y curl wget",
                    'curl -L https://www.opscode.com/chef/install.sh > /tmp/install.sh',
                    'chmod +x /tmp/install.sh',
                    'sudo bash -lc /tmp/install.sh',
                ]
                if ! proxy.nil?
                    shellcmds.unshift 'source /etc/profile.d/proxy.sh'
                end
                v.vm.provision :shell, inline: shellcmds.join('; ')
                v.vm.provision :chef_solo do |chef|
                    chef.json = {
                        :intnet_addr => "10.200.200.20#{i}",
                        :cfg => {
                            :directories => {
                                :state => '/var/run',
                                :log => '/var/log',
                            },
                            :logging => {
                                :redis => {
                                    :file => '/var/log/redis.log',
                                    :level => 'debug',
                                },
                                :redis_sentinel => {
                                    :file => '/var/log/redis-sentinel.log',
                                    :level => 'debug',
                                },
                            },
                            :redis => {
                                :master_name => 'redistest',
                                :port => 6379,
                                :sentinel_port => 26379,
                            },
                        },
                    }
                    chef.add_recipe 'redistest::test-intnet'
                    chef.add_recipe 'redistest::redis-2.8-stable'
                end
            end
        end
    end

end
