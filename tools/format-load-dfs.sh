#!/bin/sh

set -u

if [ $# -ne 1 ] ; then
    echo "usage: $0 input_filename" 1>&2
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

# echo 'hdfs dfs -put '${ORC_TEST_ROOT}'/OrcTests/test_data/performance/distrib/holmes_test_data input'
# hdfs dfs -put ${ORC_TEST_ROOT}/OrcTests/test_data/performance/distrib/holmes_test_data input

src="${HOME}/big_log_test_data-208M.txt"
i=1
end=120
while [ $i -le $end ]; do
  echo 'hdfs dfs -put "'${src}'" input/input-copy-'${i}'.txt'
  hdfs dfs -put "${src}" input/input-copy-${i}.txt
  i=$(($i+1))
done
