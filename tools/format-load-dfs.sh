#!/bin/sh

set -u

progname=$(basename "$0")

if [ $# -ne 1 ] ; then
    echo "usage: ${progname} input_filename" 1>&2
    exit 64 # usage
fi

export ORC_TEST_ROOT="${HOME}/orc-test-root"

echo
echo
echo 'hdfs namenode -format'
hdfs namenode -format
echo
echo
echo 'start-dfs.sh'
start-dfs.sh
echo
echo
echo 'hdfs dfs -mkdir /user /user/'${LOGNAME}' /user/'${LOGNAME}'/input'
hdfs dfs -mkdir /user /user/${LOGNAME} /user/${LOGNAME}/input
echo
echo

# echo 'hdfs dfs -put '${ORC_TEST_ROOT}'/OrcTests/test_data/performance/distrib/wordcount/wordcount-input-data input'
# hdfs dfs -put ${ORC_TEST_ROOT}/OrcTests/test_data/performance/distrib/wordcount/wordcount-input-data input

src="$1"
i=1
end=120
while [ $i -le $end ]; do
  echo 'hdfs dfs -put "'${src}'" input/input-copy-'${i}'.txt'
  hdfs dfs -put "${src}" input/input-copy-${i}.txt
  i=$(($i+1))
done

echo
