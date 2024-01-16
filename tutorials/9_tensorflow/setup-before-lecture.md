# TensorFlow Setup

You have already done the previous tutorials and have a cluster of five nodes running. If not otherwise noted, all
commands have to be run on all nodes.

## TensorFlow Installation

First we create a new python virtual environment named `TensorFlow`.
Navigate to your home directory and execute the following command:

```bash
python3 -m venv .venv/TensorFlow
```

Activate the created virtual environment.

```bash
source .venv/TensorFlow/bin/activate
```

**Important: from now on every time you start a python script OR you install packages make sure you have activated the
Python environment**. If an environment is currently activated this is usually indicated by having it written as the
first string in your cmd line. For example:
```
(TensorFlow) pi@node01:~ $
```
Alternatively you can also use the command `which python` to check the currently activated environment:
```
(TensorFlow) pi@node01:~ $ which python
/home/pi/.venv/TensorFlow/bin/python
```

Next we install TensorFlow with `pip`.

```
pip install tensorflow
```

You can check if it worked by looking into the list of installed pip dependencies using 
```
pip list
```

## Example

In the following we describe a simple two node setup that we will use throughout the lecture. Please make sure you have
it up and running by the start of the lecture.

Create a directory called mnist-example with the following structure on all the nodes (you can find the file contents
below):

```
mnist_example
├── mnist_setup.py
├── main.py
├── config_files
│   ├── config_w0.json
│   └── config_w1.json
```

mnist_setup.py:

```python

import tensorflow as tf
import numpy as np


def mnist_dataset(batch_size):
    (x_train, y_train), _ = tf.keras.datasets.mnist.load_data()
    # The `x` arrays are in uint8 and have values in the [0, 255] range.
    # You need to convert them to float32 with values in the [0, 1] range.
    x_train = x_train / np.float32(255)
    y_train = y_train.astype(np.int64)
    train_dataset = tf.data.Dataset.from_tensor_slices(
        (x_train, y_train)).shuffle(60000).repeat().batch(batch_size)
    return train_dataset


def build_and_compile_cnn_model():
    model = tf.keras.Sequential([
        tf.keras.layers.InputLayer(input_shape=(28, 28)),
        tf.keras.layers.Reshape(target_shape=(28, 28, 1)),
        tf.keras.layers.Conv2D(32, 3, activation='relu'),
        tf.keras.layers.Flatten(),
        tf.keras.layers.Dense(128, activation='relu'),
        tf.keras.layers.Dense(10)
    ])
    model.compile(
        loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
        optimizer=tf.keras.optimizers.SGD(learning_rate=0.001),
        metrics=['accuracy'])
    return model
```

main.py:

```python
import argparse
import json
import os

import mnist_setup
import tensorflow as tf


def get_configuration(config_path):
    with open(config_path, 'r') as file:
        config = json.load(file)
        return config


def get_num_workers(config):
    return len(config['cluster']['worker'])


def run_worker(args):
    per_worker_batch_size = 64
    tf_config = get_configuration(args.config_path)
    num_workers = get_num_workers(tf_config)
    os.environ['TF_CONFIG'] = json.dumps(tf_config)
    strategy = tf.distribute.MultiWorkerMirroredStrategy()

    global_batch_size = per_worker_batch_size * num_workers
    multi_worker_dataset = mnist_setup.mnist_dataset(global_batch_size)

    with strategy.scope():
        # Model building/compiling need to be within `strategy.scope()`.
        multi_worker_model = mnist_setup.build_and_compile_cnn_model()

    multi_worker_model.fit(multi_worker_dataset, epochs=3, steps_per_epoch=70)


if __name__ == '__main__':
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument("--config_path", type=str, required=True,
                            help="The absolut path to the configuration file.")
    args = arg_parser.parse_args()

    run_worker(args)
```

config_w0.json

```json
{
  "cluster": {
    "worker": [
      "node01:12345",
      "node02:23456"
    ]
  },
  "task": {
    "type": "worker",
    "index": 0
  }
}
```

config_w1.json

```json
{
  "cluster": {
    "worker": [
      "node01:12345",
      "node02:23456"
    ]
  },
  "task": {
    "type": "worker",
    "index": 1
  }
}
```

To test if everything works login to `node01` and `node02`.

On `node01` execute (replace the paths before according to your setup):

```bash
source .venv/TensorFlow/bin/activate
export PYTHONPATH="$PYTHONPATH:<ABSOLUT PATH to mnist_example (probably sth like /home/pi/mnist_example)>"
python3 main.py --config_path <ABSOLOUT path to config_w0.json>
```

On `node02` execute (replace the paths before according to your setup):

```bash
source .venv/TensorFlow/bin/activate
export PYTHONPATH="$PYTHONPATH:<ABSOLUT PATH to mnist_example (probably sth like /home/pi/mnist_example)>"
python3 main.py --config_path <ABSOLOUT path to config_w1.json>
```

After waiting a couple of seconds you should see that the nodes connect to each other and start training.
We will discuss the details of the code in the lecture. For now it is just important that you can run the example.

If something goes wrong this comand might be helpful to end the python processes: 
```
kill -9 $(pgrep -f "python3 main.py")
```