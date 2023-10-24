## Hadoop Setup

Now we run the typical word count example on Hadoop.

### Word Count Example

First we have to start the Hadoop. Start the `HDFS` using the script `/opt/Hadoop/sbin/start-dfs.sh`. If you did the setup correctly, you should be able to print the DFS report with `hdfs dfsadmin -report`. Please verify, that you have 4 Live Datanodes. Then start the resource manager `/opt/Hadoop/sbin/start-yarn.sh`.

```
/opt/Hadoop/sbin/start-dfs.sh
hdfs dfsadmin -report
/opt/Hadoop/sbin/start-yarn.sh
```

Create input and output directories in `hdfs`.

```
hdfs dfs -mkdir -p /WordCount
hdfs dfs -mkdir -p /WordCount/input
hdfs dfs -mkdir -p /WordCount/output
```

Now we create an example input file `file01` and load it to the input folder of the cluster.

```
echo "The cat is red The dog is blue A mouse is running A human is going to sleep The cat is sleeping The dog is going to sleep
A mouse is running A human is running The cat is blue A dog is blue A mouse is sleeping A human is red A cat is going to sleep The dog is red A mouse is blue A human is going to sleep
A cat is running The dog is sleeping A mouse is blue A human is running The cat is blue A dog is blue A mouse is going to sleep A human is red A cat is going to sleep The dog is running A mouse is red A human is sleeping The cat is red The dog is blue
A mouse is running A human is going to sleep The cat is sleeping The dog is going to sleep A mouse is running
A human is running The cat is blue A dog is blue A mouse is sleeping A human is red
A cat is going to sleep The dog is red A mouse is blue A human is going to sleep A cat is running The dog is sleeping A mouse is blue A human is running The cat is blue
A dog is blue A mouse is going to sleep A human is red A cat is going to sleep The dog is running
A mouse is red
A human is sleeping The cat is red The dog is blue A mouse is running A human is going to sleep The cat is sleeping The dog is going to sleep A mouse is running
A human is running The cat is blue A dog is blue A mouse is sleeping A human is red
A cat is going to sleep The dog is red A mouse is blue A human is going to sleep
A cat is running The dog is sleeping A mouse is blue A human is running The cat is blue" > file01

hdfs dfs -copyFromLocal -f file* /WordCount/input
```

Now we need to write the map reduce program that reads `file01` and counts the words. We save the program in a `WordCount.java` file. We need a Tokenizer that maps the text to separate words and a Reducer that sums the count of each word.

WordCount.java:

```shellscript
import java.io.IOException;
import java.util.StringTokenizer;

import org.apache.Hadoop.conf.Configuration;
import org.apache.Hadoop.fs.Path;
import org.apache.Hadoop.io.IntWritable;
import org.apache.Hadoop.io.Text;
import org.apache.Hadoop.mapreduce.Job;
import org.apache.Hadoop.mapreduce.Mapper;
import org.apache.Hadoop.mapreduce.Reducer;
import org.apache.Hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.Hadoop.mapreduce.lib.output.FileOutputFormat;

public class WordCount {

  public static class TokenizerMapper
       extends Mapper<Object, Text, Text, IntWritable>{

    private final static IntWritable one = new IntWritable(1);
    private Text word = new Text();

    public void map(Object key, Text value, Context context
                    ) throws IOException, InterruptedException {
      StringTokenizer itr = new StringTokenizer(value.toString());
      while (itr.hasMoreTokens()) {
        word.set(itr.nextToken());
        context.write(word, one);
      }
    }
  }

  public static class IntSumReducer
       extends Reducer<Text,IntWritable,Text,IntWritable> {
    private IntWritable result = new IntWritable();

    public void reduce(Text key, Iterable<IntWritable> values,
                       Context context
                       ) throws IOException, InterruptedException {
      int sum = 0;
      for (IntWritable val : values) {
        sum += val.get();
      }
      result.set(sum);
      context.write(key, result);
    }
  }

  public static void main(String[] args) throws Exception {
    Configuration conf = new Configuration();
    Job job = Job.getInstance(conf, "word count");
    job.setJarByClass(WordCount.class);
    job.setMapperClass(TokenizerMapper.class);
    job.setCombinerClass(IntSumReducer.class);
    job.setReducerClass(IntSumReducer.class);
    job.setOutputKeyClass(Text.class);
    job.setOutputValueClass(IntWritable.class);
    FileInputFormat.addInputPath(job, new Path(args[0]));
    FileOutputFormat.setOutputPath(job, new Path(args[1]));
    System.exit(job.waitForCompletion(true) ? 0 : 1);
  }
}
```

Next we compile our program, run it with Hadoop and print the output. When everything went well you should see the counts for each word. When you rerun the program you need to remove the output directory.

```shellscript
Hadoop com.sun.tools.javac.Main WordCount.java
jar cf WordCount.jar WordCount*.class
rm 'WordCount\$IntSumReducer.class' 'WordCount\$TokenizerMapper.class' WordCount.class

hdfs dfs -rm -r /WordCount/output
Hadoop jar WordCount.jar WordCount /WordCount/input /WordCount/output

hdfs dfs -cat /WordCount/output/part-r-00000
```

To stop Hadoop first stop the resource manager and then stop the `hdfs`.

```
/opt/Hadoop/sbin/stop-yarn.sh
/opt/Hadoop/sbin/stop-yarn.sh
```
