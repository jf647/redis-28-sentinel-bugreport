#!/bin/bash
#

set -e

servers="10.200.200.201 10.200.200.202 10.200.200.203"

# find master
master=$(/usr/local/bin/redis-cli -p 26379 sentinel get-master-addr-by-name redistest | head -1)
echo "# master from sentinel is $master"

# set
echo "## set foo bar"
/usr/local/bin/redis-cli -h $master set foo bar
sleep 1
echo ""

# get
echo "## get foo"
for server in $servers
do
    echo "### $server"
    /usr/local/bin/redis-cli -h $server get foo
    echo ""
done

# clear
echo "## del foo"
/usr/local/bin/redis-cli -h $master del foo
sleep 1
echo ""

# get
echo "## get foo"
for server in $servers
do
    echo "### $server"
    /usr/local/bin/redis-cli -h $server get foo
    echo ""
done
