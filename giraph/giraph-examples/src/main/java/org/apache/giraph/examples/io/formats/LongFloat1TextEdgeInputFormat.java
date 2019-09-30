/*
 *
 */

package org.apache.giraph.examples.io.formats;

import org.apache.giraph.io.formats.TextEdgeInputFormat;
import org.apache.giraph.io.EdgeReader;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.FloatWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.TaskAttemptContext;

import java.io.IOException;
import java.util.regex.Pattern;

/**
 * Simple text-based {@link org.apache.giraph.io.EdgeInputFormat} for
 * fixed-weight-edge (1.0) graphs with long ids.
 *
 * Each line consists of: source_vertex, target_vertex
 */
public class LongFloat1TextEdgeInputFormat extends
    TextEdgeInputFormat<LongWritable, FloatWritable> {
        // public abstract class TextEdgeInputFormat<I extends WritableComparable, E extends Writable> extends EdgeInputFormat<I, E>

  /** Splitter for endpoints */
  private static final Pattern SEPARATOR = Pattern.compile("[\t ]");

  @Override
  public EdgeReader<LongWritable, FloatWritable> createEdgeReader(
      //   protected abstract class TextEdgeReader extends EdgeReader<I, E> 
      InputSplit split, TaskAttemptContext context) throws IOException {
    return new LongFloat1EdgeReader();
  }

  /**
   * {@link org.apache.giraph.io.EdgeReader} associated with
   * {@link LongFloat1EdgeEdgeInputFormat}.
   */
  public class LongFloat1EdgeReader extends
      TextEdgeInputFormat<LongWritable, FloatWritable>.TextEdgeReaderFromEachLineProcessed<LongPair> {
          // protected abstract class TextEdgeReader extends EdgeReader<I, E>
    @Override
    protected LongPair preprocessLine(Text line) throws IOException {
      String[] tokens = SEPARATOR.split(line.toString());
      return new LongPair(Long.parseLong(tokens[0]),
          Long.parseLong(tokens[1]));
    }

    @Override
    protected LongWritable getSourceVertexId(LongPair endpoints)
      throws IOException {
      return new LongWritable(endpoints.getFirst());
    }

    @Override
    protected LongWritable getTargetVertexId(LongPair endpoints)
      throws IOException {
      return new LongWritable(endpoints.getSecond());
    }

    @Override
    protected FloatWritable getValue(LongPair endpoints) throws IOException {
      return new FloatWritable(1.0f);
    }
  }
}
