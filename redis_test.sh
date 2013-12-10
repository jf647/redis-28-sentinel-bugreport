#!/bin/bash
#

set -e

servers="10.200.200.201 10.200.200.202 10.200.200.203"

# find master
master=$(/usr/local/bin/redis-cli -p 26379 sentinel get-master-addr-by-name redistest | head -1)
echo "master is $master"

# set
echo "set"
/usr/local/bin/redis-cli -h $master set foo bar
sleep 1

# get
echo "get after set"
for server in $servers
do
    echo $server
    /usr/local/bin/redis-cli -a $password -h $server get foo
done

# clear
echo "clear"
/usr/local/bin/redis-cli -a $password -h $master del foo
sleep 1

# get
echo "get after del"
for server in $servers
do
    echo $server
    /usr/local/bin/redis-cli -a $password -h $server get foo
done
