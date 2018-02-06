#!/bin/sh

set -u

progname=$(basename "$0")

if [ $# -ne 0 ] ; then
    echo "usage: ${progname}" 1>&2
    exit 64 # usage
fi

printf 'Clobber DFS? '
read response
if ! printf "%s\n" "$response" | grep -Eq -- "$(locale yesexpr)"
then
    exit 1
fi

echo
echo
echo 'stop-dfs.sh'
stop-dfs.sh
echo
echo
echo "rm -fr /tmp/hadoop /tmp/*${LOGNAME}* /tmp/Jetty_* /var/local/hadoop-${LOGNAME}"
rm -fr /tmp/hadoop /tmp/*${LOGNAME}* /tmp/Jetty_* /var/local/hadoop-${LOGNAME}
echo
echo "slaves.sh rm -fr /tmp/hadoop /tmp/\*${LOGNAME}\* /tmp/Jetty_\*  /var/local/hadoop-${LOGNAME}"
slaves.sh rm -fr /tmp/hadoop /tmp/\*${LOGNAME}\* /tmp/Jetty_\* /var/local/hadoop-${LOGNAME}
echo
