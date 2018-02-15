#!/bin/sh

set -u

progname=$(basename "$0")

if [ $# -ne 0 ] ; then
    echo "usage: ${progname}" 1>&2
    exit 64 # usage
fi

echo
echo
echo 'stop-dfs.sh'
stop-dfs.sh
echo
echo
echo 'stop-yarn.sh'
stop-yarn.sh
echo
echo
echo 'mr-jobhistory-daemon.sh stop historyserver'
mr-jobhistory-daemon.sh stop historyserver
echo
