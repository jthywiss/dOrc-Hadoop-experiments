//
// GetFactorString.java -- Java class GetFactorString
// Project dOrc-Hadoop-experiments
//
// Copyright (c) 2018 The University of Texas at Austin. All rights reserved.
//
// Use and redistribution of this file is governed by the license terms in
// the LICENSE file found in the project's top-level directory and also found at
// URL: http://orc.csres.utexas.edu/license.shtml .
//

package orc.test.item.distrib;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.util.GenericOptionsParser;

public class GetFactorString {

    private GetFactorString() {
    }

    public static void main(final String[] args) throws Exception {
        final Configuration conf = new Configuration();
        final String[] otherArgs = new GenericOptionsParser(conf, args).getRemainingArgs();
        if (otherArgs.length < 1) {
            System.err.println("Usage: GetFactorString [generic_options] in_file...");
            GenericOptionsParser.printGenericCommandUsage(System.err);
            System.exit(64);
        }

        final FileSystem fs = FileSystem.get(conf);
        int numInputFiles = 0;
        for (int i = 0; i < otherArgs.length; ++i) {
            numInputFiles += WordCountHadoop.countFilesRecursively(fs, new Path(otherArgs[i]));
        }
        final int clusterSize = fs.getDefaultReplication(new Path(otherArgs[0]));

        System.out.println(numInputFiles + "_" + clusterSize);
    }

}
