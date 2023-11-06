## Spark Setup

### Prerequisites

You have already done the *Setup Hadoop* tutorial and have a cluster of five nodes with HDFS running. If not otherwise noted all commands have to be run on all nodes.

### PySpark Installation

First we add Spark to the Python path. Add the following line to the `.environment_variables` file and `source .` the changes.

.environment_variables:

```bash
export PYTHONPATH=$(ZIPS=("$SPARK_HOME"/python/lib/*.zip); IFS=:; echo "${ZIPS[*]}"):$PYTHONPATH
```

```bash
source .
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
