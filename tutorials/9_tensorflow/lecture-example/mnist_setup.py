import numpy as np
import tensorflow as tf


def mnist_dataset(batch_size):
    # use dataset provided by tensorflow, here only access the training split
    (x_train, y_train), _ = tf.keras.datasets.mnist.load_data()
    # The `x` arrays are in uint8 and have values in the [0, 255] range.
    # You need to convert them to float32 with values in the [0, 1] range.
    x_train = x_train / np.float32(255)
    # labels have to be integers from 0 to 9
    y_train = y_train.astype(np.int64)
    # compose dataset from tensors by slicing it
    # have buffer size of 60000 elements, meaning we sample from 60000 items
    # repeat dataset indefinitely, set batch size
    train_dataset = tf.data.Dataset.from_tensor_slices(
        (x_train, y_train)).shuffle(60000).repeat().batch(batch_size)
    return train_dataset


def build_and_compile_cnn_model():
    # We build our model by providing a sequence of layers
    model = tf.keras.Sequential([
        # First, define the input shape; we have images of size 28x28
        tf.keras.layers.InputLayer(input_shape=(28, 28)),
        # Reshape the input to have a single channel (grayscale)
        tf.keras.layers.Reshape(target_shape=(28, 28, 1)),
        # Apply a 2D convolutional layer with 32 filters and a kernel size of 3x3, using ReLU activation
        tf.keras.layers.Conv2D(32, 3, activation='relu'),
        # Flatten the output to prepare for the fully connected layers
        tf.keras.layers.Flatten(),
        # Add a fully connected layer with 128 (output) units and ReLU activation
        tf.keras.layers.Dense(128, activation='relu'),
        # Output layer with 10 units, representing the number of classes, return raw logits
        tf.keras.layers.Dense(10)
    ])

    # Compile the model with specified loss function, optimizer, and metrics
    model.compile(
        loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
        optimizer=tf.keras.optimizers.SGD(learning_rate=0.001),
        metrics=['accuracy']
    )

    # Return the compiled model
    return model
