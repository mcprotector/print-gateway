#!/bin/bash
set -e

if [ ! -d "/tasks" ]; then 
	echo "ERROR: /tasks must be mounted from outside" 
	exit 1 
fi
if [ ! -f "/whitelist.conf" ]; then
	echo "/whitelist.conf not mounted, blank created" 
	touch /whitelist.conf
fi	

mkdir -p /tasks/pending /tasks/printed /tasks/retry /tasks/failed

rm -f /var/run/fcgiwrap/fcgiwrap.socket

fcgiwrap -s unix:/var/run/fcgiwrap/fcgiwrap.socket &
sleep 1
chown nginx:nginx /var/run/fcgiwrap/fcgiwrap.socket
chmod 666 /var/run/fcgiwrap/fcgiwrap.socket
ls -la /var/run/fcgiwrap/fcgiwrap.socket || echo "NO SOCKET"

crond -b -l 0

bash /scripts/watcher.sh &
nginx -g 'daemon off;'
