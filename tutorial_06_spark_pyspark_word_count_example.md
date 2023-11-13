## Spark Setup

### Prerequisites

You have already done the *Setup Hadoop* tutorial and have a cluster of five nodes with HDFS running. If not otherwise noted all commands have to be run on all nodes.

### PySpark Word Count Example

After opening the Jupyter Ui create a new Notebook and add the following lines.

```bash
# Import SparkSession
from pyspark.sql import SparkSession

# Create SparkSession
spark = SparkSession.builder \
    .master("spark://node01:7077") \
    .appName("WordCount") \
    .getOrCreate()

sc = spark.sparkContext

# Read the input file and Calculating words count
text_file = sc.textFile("/WordCount/input/file01")
counts = text_file.flatMap(lambda line: line.split(" ")) \
    .map(lambda word: (word, 1)) \
    .reduceByKey(lambda x, y: x + y)

# Collect and print the word count output
counts.collect()
```
