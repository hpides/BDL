# Task 6: Distributed Training of a Neural Network

## Scenario

Imagine you are a set of images and are asked to label them (i.e. describe in one word what you see on the picture).
Of course, you could go through them manually. But, since you are computer scientists you want to automate this problem
so that you can use your solution for this time you have to label images but also for the future.

Because you just learned about how to train neural networks (NN) in a distributed way on your PI Cluster and also have
access to a labeled training dataset you decide to solve the problem using a NN. To solve the problem you are given the
following datasets and tasks.

## Datasets

- you can download the data for this task form our groups nextcloud
    - the link and password will be made available by the teaching team
- after unpacking the data you will find two directories: `train` and `test`
- as the names suggest you are supposed to use the `train` data exclusively in the training process (mainly task 2.1 -
  2.3) and the `test` data in the test phase (task 2.4)
- the data holds images associated to ten different classes
- both `train` and `test` are structured in the same way having one sub-folder per class holding the images of that
  class

## Work Distribution

Even though most of the following tasks build on top of each other most of them can be clearly separated form each other
allowing you to distribute the work in your team. The work can, for example, be divided as follows:

- Task 1
- Task 2.1 & 2.2
- Task 2.3 & 2.4
- Task 2.5
- Bonus

## Task 1: Fully Distributed Training & Monitoring

In the lecture we only trained on two nodes (node1 and node2). As a first step you want to extend your MNIST training
setup so that you use all your resources for training and have a dashboard to monitor your training progress.

- **Task 1.1**: Adapt the example from the lecture/setup tutorial to not only train on node1 and node2 but on all five
  of your nodes.
    - for this you need to adjust the config files discussed in the lecture and also add new ones for the additional
      nodes
    - while the contents presented in the lecture should be sufficient, you can find an additional example tutorial
      here: https://www.tensorflow.org/tutorials/distribute/multi_worker_with_keras

- **Task 1.2**: Setup tensor board and use it to log the metrics loss and accuracy.
    - next to the contents in the lecture, see the tutorial on tensorboard
        - https://www.tensorflow.org/tensorboard/get_started
        - for your task look into the section *Using TensorBoard with Keras Model.fit()*
        - also to view tensorboard on your local machine a command similar to the following might be
          helpful: `ssh -L 6006:localhost:6006 pi@node01`

## Task 2: Train Model on Target Data

Now that you can train fully distributed and also monitor your training progress using tensorboard you want to focus on
solving the actual task of classifying images using the labeled dataset.

- **Task 2.1**: Adjust the pipeline so that you use the new training dataset by performing the following steps:
    - **this step is preparation for training, in this step only try if your training works but do not train your model
      to convergence** (verifying if your pipeline works should take max 1-2 min)
    - if not done yet, make yourself familiar with the given dataset by looking into the description above and by
      looking into the folder structure
    - have a look into the following tutorial and focus on the section "Load data using a Keras utility - Create a
      dataset" https://www.tensorflow.org/tutorials/load_data/images
    - adjust the data loader to load the new data
        - use image width and height of 32
        - split your data into train and validation data (use a 80/20 split)
    - adjust the model to be compatible with the new data by
        - adjust Input layer to new input size
        - remove the Reshape layer
        - add a new layer as the very first layer rescaling the inputs from the range [0,255] to [0,1]
        - adjust the last layer of your model to match the number of classes if necessary
        - **hint**: to test if the training works you can limit the dataset to only use a certain number of
          items/batches using something like `train_ds.take(5)`
    - adjust the training process
        - use a training and a validation dataset (not just a training dataset as in the lecture example)
        - change the learning rate of the optimizer to 0.01 and add a momentum of 0.9
        - adjust the parameter `steps_per_epoch` in a way that one epoch sees the entire training dataset
        - adjust the number of epochs to 30-40

- **Task 2.2** Prepare for saving, loading, and analyzing model
    - look into how to save and load models
        - https://www.tensorflow.org/tutorials/keras/save_and_load
    - add the functionality to save and load model snapshots to your pipeline
        - save the model after every epoch
    - **hint (1)**: to test if the training and snapshotting works you can limit the dataset to only use a certain
      number of items/batches using something like `train_ds.take(5)`
    - **hint (2)** feel free to use your distributed file system to have files available on all nodes, but make sure to
      save model snapshots locally.
    - create a new python script that given a snapshot path, loads the model and evaluates its performance (loss and
      accuracy) on the test dataset

- **Task 2.3** Train model
    - in case you reduced the number of nodes and/or data for test purposes, now switch back to using the full data and
      all nodes
    - train the model on the train dataset for 30 epochs on all nodes and
        - follow the training progress live in tensorboard
        - make sure that the model snapshot is written every epoch
    - **hint (1):** this step will take approx 30-40 min, once the training is started and running for some epochs (to
      make sure it doesn't crash) it is a good opportunity to grab coffe/tea
    - **hint (2):** if the training takes significantly longer than expected, make sure you have not adjusted the batch
      size (use a per_worker_batch_size of 64)
    - **hint (3):** make sure your ssh connection does not crash during training by, for example, using `tmux`
      or `screen`

- **Task 2.4** Evaluate Performance and look at results
    - write a short readme answering the following questions:
        - how did the train and validation accuracy change over time?
        - what do you think at what epoch was the most promising snapshot saved and why?
    - use your script from task 2.2 to evaluate the model on the test set to report the model performance (loss and acc)
      after epoch 1, the epoch you think is most promising, and the last epoch you have trained to verify your
      assumptions form earlier

- **Task 2.5** Improve model performance
    - most likely you will see that the current model is not performing very well, the reason is that our current model
      is not complex enough
    - try to improve your models performance, by adding more convolutional layers
    - try at least one new model variant (add at least one additional layer) and repeat steps 2.3 and 2.4 for the new
      architecture

## Bonus Task: Analyse Scalability

For this, you can collect two bonus points:

- so far you always trained your model on all five nodes, but you have not analysed what is actually the best
  configuration for your given workloads, does it really make sense to use all five nodes?
- run the training for 3 epochs in 5 different configurations (training on one node, two nodes, three
  nodes, ...)  and log the end-to-end training time
- measure the times three times per configuration to have more reliable measurements
- plot the times: x-axis number workers, y-axis time, have one plot for median values, one for average values
- write a short analysis how the number of nodes influences the times you recorded, also write down a possible
  explanation for the trends you see

## Submission

Submit the following files as a single zip file:

- all the relevant code files (e.g. adjusted main.py and related code)
- a readme containing the analysis done in tasks 2.4, 2.5, (and the bonus task)
- the tensorboard log directory
- the most promising model snapshot(s) you selected
- (the plot from the bonus task)

## Presentation

One student representative demonstrates the start of a training run on all nodes in action for each group.
This includes:

- showing that logs can be monitored in tensorboard and that checkpoints are saved and can later be evaluated
  using the script form task 2.2.
- walking us through the plots generated as part of task 2.4 and 2.5, as well as the comments in the readme
- explaining how you adjusted the model in task 2.5
- (explain how you approached the bonus task and what your findings are)






























