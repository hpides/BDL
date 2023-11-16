## Task 2 - Data Analytics with Spark & Spark SQL

The second task is to analyze a large real-world dataset with Spark and Spark SQL. For this, you will work on an anonymized dump of user content from the StackOverflow Q&A website. This is an opportunity to: (1) get familiar with Spark's core concepts of RDDs, DataFrames,  
and temporary tables. (2)You will also learn how to transform, filter, aggregate, and join  collections of data within a large data set efficiently.

### Data Preparation

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

1. Import the file as a Spark DataFrame `users_df` and a temporary table `users_t` .

### Employ the DataFrame API

1. Create a version of the users data frame that filters out all rows where the value for the column location is Null or equal to "0".
2. Create a data frame containing the location and number of users per location.
3. Create a data frame containing the top 10 valid locations (excluding nulls and "0") ranked by their number of registered users.

Report the results of the dataframe in 3 as below:

| Location | Count |
|----------|-------|
| Berlin | 100 |
| Potsdam | 99 |
| ... |  |

### Employ SQL to Analyze the StackOverflow Datasets

1. Write and run a query to list all users in a specific location.
2. Write and run a query to list the 100 users with the highest reputation.
3. Write and run a query to list the 100 users that upvote the least relative to their downvotes.
4. Import the stackoverflow.com-Posts dataset. Write and run a query to list the 100 users with the highest average answer score, excluding community wiki and closed posts. Note that the posts dataset is ~20 GB packed and ~100GB unpacked, and make sure your machine has enough disk space to store it locally before you move it to HDFS.
5. Reformat the datasets in Parquet and rerun the last join query.

Report the runtimes of your queries in `task02_query_runtimes.csv` as below:

| Query # | Runtime (s) |
|---------|-------------|
| 1 |  |
| 2 |  |
| ... |  |

Report the query plans in a text file `task02_query_plans.txt`.

#### Bonus

For the second task, you can collect two bonus points:  
\- Come up with another interesting query on the StackOverflow datasets, involving at least  
a selection, a join, and an aggregation. Report your artifacts in the files `task02_bonus01.*`.  
\- Tune your Spark configuration to accelerate the query runtime of above join query between Users and Posts. Refer to <https://spark.apache.org/docs/latest/sql-performance-tuning.html#caching-data-in-memory> for details. Report your findings `task02_bonus02.*` .

#### Submission

Submit the following files packaged into a zip file named `task02.zip`:  
\- `task02_query_runtimes.csv`  
\- `task02_query_plans.txt`  
\- optional: `task02_bonus01.*`  
\- optional: `task02_bonus02.*`

#### Presentation

For each group, one student representative demonstrates their Spark jobs/queries in action. This includes running selected jobs/queries and presenting their results. The interpretation of the results may be supported with the logs and web UIs of Hadoop, Grafana, and Spark.  
Each lab session, we rotate and document the students representing the groups so every student gets her/his turn in the course of the semester.