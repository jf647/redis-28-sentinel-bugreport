#!/bin/bash
#

set -e

servers="10.200.200.201 10.200.200.202 10.200.200.203"

# server info
echo "# INFO replication"
echo ""
for server in $servers
do
    echo "## $server"
    set +e
    timeout 5s /usr/local/bin/redis-cli --csv -h $server info replication
    set -e
    echo ""
done


# sentinel masters
echo "# SENTINEL MASTERS"
for server in $servers
do
    for port in 26379
    do
        echo "## $server:$port"
        set +e
        timeout 5s /usr/local/bin/redis-cli --csv -p $port -h $server sentinel masters
        set -e
        echo ""
    done
done
