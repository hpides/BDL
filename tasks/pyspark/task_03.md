## Task 3 - Distributed Machine Learning & Data Visualization with PySpark

The second task is to process a large data file and train a predictive model by using PySpark and MLlib. You will work on the familiar user content data set from Task 2. The goal of the task is to build on top of your current knowledge of dataframes and expand it for efficient data preprocessing and model training. In this task, you will need to predict the reputation of a user based on his interaction in the Stack Exchange. To this end, you will need to split the data, preprocess it, and finally train a Random Forest Regressor. Additionally, you are required to compare your multi-node PySpark implementation to a single node Spark execution.

### 0. Assumptions
The Users dataset from the previous task should still reside in your clusters. In case you have deleted it, please download it again by following the tutorial below. In case you still have the dataset in either a .csv or .parquet format, move on to the Data Preparation step.

#### Data Download
1. Download and unpack the stackoverflow.com-Users dataset. The dataset is about 725 MB, so this may take a while. Your ZIP tool of choice may vary.

```
wget https://archive.org/download/stackexchange/stackoverflow.com-Users.7z
[...]
7za x stackoverflow.com-Tags.7z
```

1. Check the presence of the resulting file and its size by running `ls -l -h`.

```
pi@node01:~ $ ls -l -h Users.xml
[...]
-rw-r--r--  1 Thomas.Bodner  staff   5.1G Sep  5 06:55 Users.xml
[...]
```


### 1. Data Preparation

0. Ingest the data. Feel free to use the file in CSV, or Parquet format. 
1. Separate the full Users dataset into training (80%) and test set (20%). To make sure the random split gives out consistent results across runs, fix the seed (e.g. seed = 10).
2. Remove free text features: About Me, WebsiteUrl, EmailHash, DisplayName and ProfileImageUrl.
3. Manage missing values by imputation where the feature values are Null, or NaN.

Report the difference in the data size of the original training set (all features), and the preprocessed data. You can report this number in the notebook output. 

### 2. Train Model

1. Train a Random Forest Regressor on the training set. Train models with different number of trees, i.e, train a model 10, 50, 100, 250, 500 trees. The model should be validated with cross validation. The metric of interest is Mean Squared Error (MSE). The target feature is the reputation.
2. Look into configuration parameters for the Spark runtime or the Random Forest Regressor that might lower the runtime of the training. One of the configuration parameters should be the number of nodes since you need to compare the single node execution to the distributed execution. 
3. Evaluate the model on the test set. Similarly to the training step, the metric of interest is the Mean Squared Error (MSE).

Record the results and the parameters from each run in a dataframe with the following format:

| RunId | NumberOfExecutorsPerNode |  NumberOfNodes   | Train Runtime | Test Runtime | Number of trees | Memory per exeutor | Train MSE | Test MSE |(feel free to add other parameters here)|  
| int   |        int               |     int (1-4)    |  float (s)    |  float (s)   |        int      |       int          |   float   |   float  |  

Store the dataframe as a .csv file: `results.csv`.

### 3. Visualize the results

1. Plot the train and test runtime of the different runs (y-axis) depending on the number of trees (x-axis).
2. Plot the train and test runtime of the all runs (y-axis) depending on the number of active nodes (x-axis).
3. Plot the train and test performance (MSE) (y-axis) depending on the number of trees (x-axis).

You can visualize the results using matplotlib.

Report three JPG files:  
\- `runtime_number_of_trees.jpg`  
\- `runtime_number_of_nodes.jpg`  
\- `mse_number_of_trees.jpg`  


#### Bonus

For this, you can collect two bonus points:  
\- Inspect other data preprocessing techniques that can enhance the performance of the trained model. Add the additional steps in the list of (other parameters) in the `results.csv`.  
\- In terms of train and test runtime, find the best set of parameters for your pipeline. Summarize the findings in a `config_set_bonus.txt` file.

### Task Setup & Submission

This task should be implemented in a Jupyter Notebook.   
Submit the following files packaged into a zip file named `group<groupID>-task03.zip`:  
\- `task03.ipynb`  
\- `results.csv`  
\- `runtime_number_of_trees.jpg`  
\- `runtime_number_of_nodes.jpg`  
\- `mse_number_of_trees.jpg`  
\- optional: `config_set_bonus.txt`  



### Presentation

For each group, one student describes their PySpark pipeline. The interpretation of the results may be supported with the required plots in 2., as well as logs and web UIs of Hadoop, Grafana, and Spark. Each lab session, we rotate and document the students representing the groups so every student gets her/his turn in the course of the semester.