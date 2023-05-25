#!/bin/bash
arg1=${1}
arg2=${2}
arg3=${3}
# Run the script in a connector mode
/usr/local/bin/ztedge-client new $arg1 $arg2 --connector --password $arg3 --authenticate-only
/usr/local/bin/ztedge-client up $arg1 $arg2
while true ; do continue ; done