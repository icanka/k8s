#!/bin/bash

IP_NW=$1
NEW_GATEWAY="$IP_NW".1


# remove mngmt network default gateway
if ip route del default ; then
	echo "default gateway deleted"
else
	echo "default gateway deletion failed"
	exit 1
fi

# and add it as the new default gateway
if ip route add default via "$NEW_GATEWAY"; then
	echo "new default gateway added"
else
	echo "new default gateway addition failed"
	exit 1
fi