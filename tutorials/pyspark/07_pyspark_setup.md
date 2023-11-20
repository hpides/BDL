## PySpark Setup

### Prerequisites

You have already done the *Spark Setup* tutorial.

### Installation

First we add Spark to the Python path. Add the following line to the `~/.environment_variables` file and `source ~/.environment_variables` the changes.

~/.environment_variables:

```bash
export PYTHONPATH=$(ZIPS=("$SPARK_HOME"/python/lib/*.zip); IFS=:; echo "${ZIPS[*]}"):$PYTHONPATH
```

```bash
source ~/.environment_variables
```

Next we install Python, Pip and Venv with the following commands.

```bash
sudo apt update
sudo apt --yes upgrade
sudo apt --yes install python3-pip python3-venv
```

Now we create a new Venv, install PySpark and Jupiter and start a Jupyter Notebook.

```bash
python3 -m venv .venv/word_count
.venv/word_count/bin/pip install pyspark jupyter
.venv/word_count/bin/jupyter notebook --no-browser --port=8888 --ip=node01
```

Follow the instructions to access the Jupyter Notebook Web UI.

### Word Count Example

After opening the Jupyter web UI, create a new notebook and add the following lines.

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
