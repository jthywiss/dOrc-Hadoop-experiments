#!/bin/bash

export ORC_TEST_ROOT=/u/${LOGNAME}/orc-test-root
export HADOOP_CLASSPATH=${ORC_TEST_ROOT}/OrcScala/build/orc-2.1.1.jar:${ORC_TEST_ROOT}/OrcScala/lib/scala-library.jar:${ORC_TEST_ROOT}/OrcScala/lib/scala-parser-combinators_2.12-1.0.6.jar:${ORC_TEST_ROOT}/OrcScala/lib/scala-reflect.jar:${ORC_TEST_ROOT}/OrcScala/lib/scala-xml_2.12-1.0.6.jar:${ORC_TEST_ROOT}/PorcE/build/classes/:${ORC_TEST_ROOT}/OrcTests/build/
#FIXME: compute this file name prefix
export orc_executionlog_fileprefix=HolmesWordCountHadoop_120_6

# Hadoop requires that the class path entries are world readable
echo 'Making class path entries world readable'
chmod ugo+x ${ORC_TEST_ROOT}/
chmod ugo+x ${ORC_TEST_ROOT}/OrcScala/
chmod ugo+x ${ORC_TEST_ROOT}/OrcScala/build/
chmod ugo+r ${ORC_TEST_ROOT}/OrcScala/build/orc-2.1.1.jar
chmod ugo+x ${ORC_TEST_ROOT}/OrcScala/lib/
chmod ugo+r ${ORC_TEST_ROOT}/OrcScala/lib/scala-library.jar
chmod ugo+r ${ORC_TEST_ROOT}/OrcScala/lib/scala-parser-combinators_2.12-1.0.6.jar
chmod ugo+r ${ORC_TEST_ROOT}/OrcScala/lib/scala-reflect.jar
chmod ugo+r ${ORC_TEST_ROOT}/OrcScala/lib/scala-xml_2.12-1.0.6.jar
chmod ugo+x ${ORC_TEST_ROOT}/PorcE/
chmod ugo+x ${ORC_TEST_ROOT}/PorcE/build/
chmod ugo+rx -R ${ORC_TEST_ROOT}/PorcE/build/classes/
chmod ugo+x ${ORC_TEST_ROOT}/OrcTests/
chmod ugo+rx -R ${ORC_TEST_ROOT}/OrcTests/build/
echo
echo
echo 'mkdir -p raw-output'
mkdir -p raw-output
echo
echo
echo 'rm raw-output/*'
rm raw-output/*
echo
echo
echo 'hdfs dfs -rm -r output\*'
hdfs dfs -rm -r output\*
echo
echo
echo 'slaves.sh uptime'
slaves.sh uptime
echo
echo
echo 'hadoop jar dOrc-Hadoop-experiments.jar orc.test.item.distrib.HolmesWordCountHadoop -libjars ... input output'
{ { hadoop jar dOrc-Hadoop-experiments.jar orc.test.item.distrib.HolmesWordCountHadoop -libjars ${HADOOP_CLASSPATH//:/,} input output | tee raw-output/${orc_executionlog_fileprefix}.out; exit ${PIPESTATUS[0]}; } 2>&1 1>&3 | tee raw-output/${orc_executionlog_fileprefix}.err; exit ${PIPESTATUS[0]}; } 3>&1 1>&2
echo
echo
echo 'hdfs dfs -cat output\*/\*'
hdfs dfs -cat output\*/\*
