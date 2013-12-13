I have been trying to resolve a problem that started with 2.8.0 and
continues through the latest commit on the 2.8 branch (33f6f35f as I write
this).

The problem is that the sentinel reports slaves as masters.  I have a
Vagrant setup with 3 boxes.  The first box is the master, the other two are
slaves.  On the master, the sentinel works fine, it reports node 1 with
"flags" equal to "master" and "role-reported" equal to "master".

On the other 2 nodes, the sentinel reports the node as "master" (eventually
"master,s_down"), even though it also reports "role-reported" as "slave". 
So even though 'info replication' on node 2 shows this:

```
# Replication
role:slave
master_host:10.200.200.201
master_port:6379
master_link_status:up
master_last_io_seconds_ago:1
master_sync_in_progress:0
slave_repl_offset:13984
slave_priority:100
slave_read_only:1
connected_slaves:0
master_repl_offset:0
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0
```

sentinel masters from the sentinel on that node reports this:

```
"name","redistest","ip","10.200.200.202","port","6379","runid","2782294d04739f5cc76cbc399c742dac592064e7","flags","s_down,master","pending-commands","0","last-ok-ping-reply","711","last-ping-reply","711","s-down-time","157454","info-refresh","6639","role-reported","slave","role-reported-time","207467","config-epoch","0","num-slaves","0","num-other-sentinels","1","quorum","2"
```

The net takeaway is that processes on node 2 and 3 can't ask their local
sentinel who the master is (we're using the redis-sentinel gem, hacked for
the new 4-arg form of is-master-down-by-addr).

The slaves are replicating properly from the master:

```
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

```

But the sentinels never reach quorum, so failover is impossible.

There is gossip on the sentinel channel from node 1 indicating that it thinks nodes 2 and 3 are slaves:

[6147] 13 Dec 21:35:15.278 * +slave slave 10.200.200.202:6379 10.200.200.202 6379 @ redistest 10.200.200.201 6379
[6147] 13 Dec 21:42:48.836 * +slave slave 10.200.200.203:6379 10.200.200.203 6379 @ redistest 10.200.200.201 6379

And node 1 knows about the other two sentinels:

[6147] 13 Dec 21:35:15.384 * +sentinel sentinel 10.200.200.202:26379 10.200.200.202 26379 @ redistest 10.200.200.201 6379
[6147] 13 Dec 21:42:50.486 * +sentinel sentinel 10.200.200.203:26379 10.200.200.203 26379 @ redistest 10.200.200.201 6379

## 10.200.200.201:26379
"name","redistest","ip","10.200.200.201","port","6379","runid","e2a2c80066830dc5010016a9ed836a05c1c40a7e","flags","master","pending-commands","0","last-ok-ping-reply","1063","last-ping-reply","1063","info-refresh","5619","role-reported","master","role-reported-time","1825961","config-epoch","0","num-slaves","2","num-other-sentinels","2","quorum","2"

But the sentinels on nodes 2 and 3 only know about the node 1 sentinel. 
Because they think they're the master redis, they never connect to the real
master redis to get the slave list, so they only know about the sentinel on
node 1 via gossip:

The problem occurs both on Ubuntu 12.04 and CentOS 6.4.

I've extracted all of this out of my application and put a Vagrant
configuration that demonstrates the problem here:

You can do a 'vagrant up' on centos-{1,2,3} or ubuntu-{1,2,3} (or a
combination I suppose - just not two distros for the same node number at the
same time)

I've been trying to get to the bottom of this for a week now, hoping it was
something strange I was doing.  For a while it looked like the role
reporting fixes committed to 2.8 might be the problem, but even as of an
hour ago I'm still seeing the failure.
