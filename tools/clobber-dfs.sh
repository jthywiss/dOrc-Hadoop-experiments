#!/bin/sh

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
echo "rm -fr /tmp/hadoop /tmp/*${LOGNAME}* /tmp/Jetty_*"
rm -fr /tmp/hadoop /tmp/*${LOGNAME}* /tmp/Jetty_*
echo
echo "slaves.sh rm -fr /tmp/hadoop /tmp/\*${LOGNAME}\* /tmp/Jetty_\*"
slaves.sh rm -fr /tmp/hadoop /tmp/\*${LOGNAME}\* /tmp/Jetty_\*
echo
