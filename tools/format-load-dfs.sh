#!/bin/sh

export ORC_TEST_ROOT=/u/${LOGNAME}/orc-test-root

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
echo 'hdfs dfs -mkdir /user'
hdfs dfs -mkdir /user
echo
echo
echo 'hdfs dfs -mkdir /user/'${LOGNAME}
hdfs dfs -mkdir /user/${LOGNAME}
echo
echo
echo 'hdfs dfs -put '${ORC_TEST_ROOT}'/OrcTests/test_data/performance/distrib/holmes_test_data input'
hdfs dfs -put ${ORC_TEST_ROOT}/OrcTests/test_data/performance/distrib/holmes_test_data input
