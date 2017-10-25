//
// HolmesWordCountHadoop.java -- Java class HolmesWordCountHadoop
// Project dOrc-Hadoop-experiments
//
// Copyright (c) 2017 The University of Texas at Austin. All rights reserved.
//
// Use and redistribution of this file is governed by the license terms in
// the LICENSE file found in the project's top-level directory and also found at
// URL: http://orc.csres.utexas.edu/license.shtml .
//

// Derived from:
// MapReduce Tutorial. In: Apache Software Foundation. Apache Hadoop 2.8.0 [Web site]. 2017 [updated 2017 Mar 17].
// https://hadoop.apache.org/docs/r2.8.0/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html#Example:_WordCount_v1.0

package orc.test.item.distrib;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.text.BreakIterator;
import java.util.ArrayList;
import java.util.Arrays;

import scala.collection.JavaConverters;
import scala.collection.TraversableOnce;

import orc.test.util.FactorValue;
import orc.test.util.TestEnvironmentDescription;
import orc.util.CsvWriter;
import orc.util.ExecutionLogOutputStream;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;

public class HolmesWordCountHadoop {

    public HolmesWordCountHadoop() {
    }

    public static class TokenizerMapper extends Mapper<Object, Text, Text, IntWritable> {

        private final static IntWritable one = new IntWritable(1);
        private final Text word = new Text("word");

        private static boolean containsAlphabetic(final String s, final int startPos, final int endPos) {
            for (int currPos = startPos; currPos < endPos; currPos++) {
                if (Character.isAlphabetic(s.codePointAt(currPos))) {
                    return true;
                }
            }
            return false;
        }

        @Override
        public void map(final Object key, final Text value, final Context context) throws IOException, InterruptedException {
            final String line = value.toString();
            final BreakIterator wb = BreakIterator.getWordInstance();
            wb.setText(line);
            int startPos = 0;
            int endPos = wb.next();
            while (endPos >= 0) {
                if (containsAlphabetic(line, startPos, endPos)) {
                    context.write(word, one);
                }
                startPos = endPos;
                endPos = wb.next();
            }
        }
    }

    public static class IntSumReducer extends Reducer<Text, IntWritable, Text, IntWritable> {
        private final IntWritable result = new IntWritable();

        @Override
        public void reduce(final Text key, final Iterable<IntWritable> values, final Context context) throws IOException, InterruptedException {
            int sum = 0;
            for (final IntWritable val : values) {
                sum += val.get();
            }
            result.set(sum);
            context.write(key, result);
        }
    }

    protected static boolean testPayload(final Configuration conf, final String[] otherArgs, final int thisRepetitionNum) throws IOException, IllegalStateException, IllegalArgumentException, InterruptedException, ClassNotFoundException {
        final Job job = Job.getInstance(conf, "Holmes word count");
        job.setJarByClass(HolmesWordCountHadoop.class);
        job.setMapperClass(TokenizerMapper.class);
        job.setCombinerClass(IntSumReducer.class);
        job.setReducerClass(IntSumReducer.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);
        FileInputFormat.setInputDirRecursive(job, true);
        for (int i = 0; i < otherArgs.length - 1; ++i) {
            FileInputFormat.addInputPath(job, new Path(otherArgs[i]));
        }
        FileOutputFormat.setOutputPath(job, new Path(otherArgs[otherArgs.length - 1] + thisRepetitionNum));
        return job.waitForCompletion(false);
    }

    ////////
    // Test Driver
    ////////

    public static Long[][] timeRepetitions(final Configuration conf, final String[] args, final int numRepetitions) throws IOException, IllegalStateException, IllegalArgumentException, ClassNotFoundException, InterruptedException {
        final Long[][] testElapsedTimes = new Long[numRepetitions][2];
        for (int thisRepetitionNum = 1; thisRepetitionNum <= numRepetitions; thisRepetitionNum++) {
            System.out.println("Repetition " + thisRepetitionNum + ": start.");
            final long startNanos = System.nanoTime();
            final boolean succeeded = testPayload(conf, args, thisRepetitionNum);
            System.out.println("Repetition " + thisRepetitionNum + ": Job successful? " + succeeded);
            final long finishNanos = System.nanoTime();
            System.out.println("Repetition " + thisRepetitionNum + ": finish.  Elapsed time " + (finishNanos - startNanos) / 1000 + " µs");
            testElapsedTimes[thisRepetitionNum - 1][0] = Long.valueOf(thisRepetitionNum);
            testElapsedTimes[thisRepetitionNum - 1][1] = Long.valueOf((finishNanos - startNanos) / 1000);
        }
        return testElapsedTimes;
    }

    public static void setupOutput() throws IOException {
        if (System.getProperty("orc.executionlog.dir", "").isEmpty()) {
            throw new IllegalArgumentException("java system property orc.executionlog.dir must be set");
        }
        final File outDir = new File(System.getProperty("orc.executionlog.dir"));
        if (!outDir.exists()) {
            throw new IOException("Directory must exist: " + outDir.getAbsolutePath());
        }
        TestEnvironmentDescription.dumpAtShutdown();
    }

    public static void writeCsvFile(final String basename, final String description, final String[] tableColumnTitles, final Object[][] rows) throws IOException {
        try (final OutputStream csvOut = ExecutionLogOutputStream.apply(basename, "csv", description).get(); final OutputStreamWriter csvOsw = new OutputStreamWriter(csvOut, "UTF-8");) {

            final ArrayList<TraversableOnce<?>> newRows = new ArrayList<>(rows.length);
            for (final Object[] row : rows) {
                newRows.add(JavaConverters.collectionAsScalaIterable(Arrays.asList(row)));
            }

            final CsvWriter csvWriter = new CsvWriter(csvOsw);
            csvWriter.writeHeader(JavaConverters.collectionAsScalaIterable(Arrays.asList(tableColumnTitles)));
            csvWriter.writeRowsOfTraversables(JavaConverters.collectionAsScalaIterable(newRows));
        }
        System.out.println(description + " written to " + basename + ".csv");
    }

    public static int countFilesRecursively(final FileSystem fs, final Path startPath) throws FileNotFoundException, IOException {
        final FileStatus stat = fs.getFileStatus(startPath);
        if (stat.isFile()) {
            return 1;
        } else if (stat.isDirectory()) {
            int count = 0;
            for (final FileStatus curFile : fs.listStatus(startPath)) {
                count += countFilesRecursively(fs, curFile.getPath());
            }
            return count;
        } else {
            return 0;
        }
    }

    public static void main(final String[] args) throws Exception {
        final Configuration conf = new Configuration();
        final String[] otherArgs = new GenericOptionsParser(conf, args).getRemainingArgs();
        if (otherArgs.length < 2) {
            System.err.println("Usage: HolmesWordCountHadoop [generic_options] in_file... out_file");
            GenericOptionsParser.printGenericCommandUsage(System.err);
            System.exit(64);
        }

        final FileSystem fs = FileSystem.get(conf);
        int numInputFiles = 0;
        for (int i = 0; i < otherArgs.length - 1; ++i) {
            numInputFiles += countFilesRecursively(fs, new Path(otherArgs[i]));
        }
        final int clusterSize = fs.getDefaultReplication(new Path(otherArgs[0]));

        System.setProperty("orc.executionlog.dir", "raw-output");
        System.setProperty("orc.executionlog.fileprefix", "HolmesWordCountHadoop_" + numInputFiles + "_" + clusterSize + "_");

        final int numRepetitions = Integer.parseInt(System.getProperty("orc.test.numRepetitions", "20"));

        setupOutput();

        final Object[][] factorValues = {
                { "Program", "HolmesWordCountHadoop.java", "", "", "" },
                { "Number of files read", Integer.valueOf(numInputFiles), "", "numInputFiles", "Words counted in this number of input text files" },
                { "Cluster size", Integer.valueOf(clusterSize), "", "dOrcNumRuntimes", "Number of replicas" }
        };
        FactorValue.writeFactorValuesTable(factorValues);

        final Long[][] repetitionTimes = timeRepetitions(conf, otherArgs, numRepetitions);

        final String[] repetitionTitles = { "Repetition number", "Elapsed time (µs)" };
        writeCsvFile("repetition-times", "Repetitions' elapsed times output file", repetitionTitles, repetitionTimes);
    }

}
