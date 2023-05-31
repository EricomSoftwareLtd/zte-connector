#!/bin/bash
arg1=${1}
arg2=${2}
arg3=${3}
# Run the script in a connector mode. No systemd
/usr/local/bin/ztedge-client new $arg1 $arg2 --connector --password $arg3 --listen-port 51220
tail -f /dev/null