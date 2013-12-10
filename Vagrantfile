proxy = 'http://10.138.15.10:8080'

Vagrant.configure("2") do |config|

    config.ssh.forward_agent = true
    config.proxy.https    = proxy
    config.proxy.ftp      = proxy
    config.proxy.no_proxy = "localhost,10.138.1.252,127.0.0.1,.oam.cepl"
    config.env_proxy.https    = proxy
    config.env_proxy.ftp      = proxy
    config.env_proxy.no_proxy = "localhost,10.138.1.252,127.0.0.1,.oam.cepl"

    # test box 1
    1.upto(3).each do |i|
        config.vm.define "test#{i}" do |v|
            v.vm.box = 'centos-6.4-base'
            v.vm.box_url = 'http://10.138.1.252:41003/centos/centos-6.4-base.box'
            v.vm.hostname = 'redistest-1.vagrant'
            v.vm.provider :virtualbox do |vb|
                vb.customize ["modifyvm", :id, "--memory", "3072"]
                vb.customize ["modifyvm", :id, "--nic2", "intnet"]
                vb.customize ["modifyvm", :id, "--nictype2", "82545EM"]
            end
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
                                :level => 'verbose',
                            },
                            :redis_sentinel => {
                                :file => '/var/log/redis-sentinel.log',
                                :level => 'verbose',
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
