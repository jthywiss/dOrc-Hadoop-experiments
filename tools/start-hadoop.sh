#!/bin/sh

set -u

progname=$(basename "$0")

if [ $# -ne 0 ] ; then
    echo "usage: ${progname}" 1>&2
    exit 64 # usage
fi

export ORC_TEST_ROOT="${HOME}/orc-test-root"

echo
echo
echo 'start-dfs.sh'
start-dfs.sh
echo
echo
echo 'start-yarn.sh'
start-yarn.sh
echo
echo
echo 'mr-jobhistory-daemon.sh start historyserver'
mr-jobhistory-daemon.sh start historyserver
echo
