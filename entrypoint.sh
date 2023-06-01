#!/bin/bash
arg1=${1}
arg2=${2}
arg3=${3}
arg4=${4}
arg5=${5}
# Run the script in a connector mode if arg4='--connector'. Enable debug if arg5='--debug'
/usr/local/bin/ztedge-client new $arg1 $arg2 $arg4 --password $arg3 $arg5
tail -f /dev/null
