# Install

* Get Vagrant from http://www.vagrantup.com
* Get Virtualbox from http://www.virtualbox.org
* Install both
* clone the repo and cd into it
* run "for i in 1 2 3 ; do vagrant up centos-$i ; done" (or ubuntu if you prefer)

# Demonstration

* ssh into a box (e.g. "vagrant ssh centos-1")
* cd /vagrant
* run ./redis_sentinel_test.sh to see the output of "info replication" from each of the database instances and "sentinel masters" from each of the sentinels:

```
vagrant@ubuntu-1:/vagrant$ ./redis_sentinel_test.sh
# INFO replication

## 10.200.200.201
# Replication
role:master
connected_slaves:2
slave0:ip=10.200.200.202,port=6379,state=online,offset=149368,lag=1
slave1:ip=10.200.200.203,port=6379,state=online,offset=149512,lag=1
master_repl_offset:149512
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:2
repl_backlog_histlen:149511

## 10.200.200.202
# Replication
role:slave
master_host:10.200.200.201
master_port:6379
master_link_status:up
master_last_io_seconds_ago:1
master_sync_in_progress:0
slave_repl_offset:149512
slave_priority:100
slave_read_only:1
connected_slaves:0
master_repl_offset:0
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0

## 10.200.200.203
# Replication
role:slave
master_host:10.200.200.201
master_port:6379
master_link_status:up
master_last_io_seconds_ago:0
master_sync_in_progress:0
slave_repl_offset:149512
slave_priority:100
slave_read_only:1
connected_slaves:0
master_repl_offset:0
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0

# SENTINEL MASTERS
## 10.200.200.201:26379
"name","redistest","ip","10.200.200.201","port","6379","runid","e2a2c80066830dc5010016a9ed836a05c1c40a7e","flags","master","pending-commands","0","last-ok-ping-reply","424","last-ping-reply","424","info-refresh","1519","role-reported","master","role-reported-time","41665","config-epoch","0","num-slaves","2","num-other-sentinels","2","quorum","2"

## 10.200.200.202:26379
"name","redistest","ip","10.200.200.202","port","6379","runid","2782294d04739f5cc76cbc399c742dac592064e7","flags","s_down,master","pending-commands","0","last-ok-ping-reply","463","last-ping-reply","463","s-down-time","32679","info-refresh","2454","role-reported","slave","role-reported-time","82705","config-epoch","0","num-slaves","0","num-other-sentinels","1","quorum","2"

## 10.200.200.203:26379
"name","redistest","ip","10.200.200.203","port","6379","runid","3db9cf3fd4873b9b856b05cee363eca01fee2495","flags","s_down,master","pending-commands","0","last-ok-ping-reply","126","last-ping-reply","126","s-down-time","58169","info-refresh","7923","role-reported","slave","role-reported-time","108244","config-epoch","0","num-slaves","0","num-other-sentinels","1","quorum","2"

vagrant@ubuntu-1:/vagrant$
```

* run ./redis_test.sh to see that replication does actually work

```
vagrant@ubuntu-1:/vagrant$ ./redis_test.sh
# master from sentinel is 10.200.200.201
## set foo bar
OK

## get foo
### 10.200.200.201
"bar"

### 10.200.200.202
"bar"

### 10.200.200.203
"bar"

## del foo
(integer) 1

## get foo
### 10.200.200.201
(nil)

### 10.200.200.202
(nil)

### 10.200.200.203
(nil)

vagrant@ubuntu-1:/vagrant$
```

# Settings

* you can edit a few Redis things in Vagrantfile before bringing up the box
  (log level & location, ports) in the chef.json hash
