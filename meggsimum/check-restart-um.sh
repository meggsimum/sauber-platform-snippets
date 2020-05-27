#!/bin/bash
REMOTEHOST= # set IP / host here
REMOTEPORT= # set UM port here
TIMEOUT=1

# pings the UM server docker service and restarts it if not available

if nc -w $TIMEOUT -z $REMOTEHOST $REMOTEPORT; then
    echo "Connection to ${REMOTEHOST}:${REMOTEPORT} successful."
else
    echo "Connection to ${REMOTEHOST}:${REMOTEPORT} failed. Exit code from Netcat was ($?)."
    #TODO detect service ID dynamically
    docker service update --force nesxiesn5hp4
fi

