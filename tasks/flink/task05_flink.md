## Task 5 - Flink

The fifth task is to process a large real-world dataset with Flink. You will work on the sensor data from several wireless sensors embedded in the shoes used during a soccer match and the dataset spans the whole duration of this game.  The goal of the tasks is to get familiar with Flink and use Grafana to monitor Flink. In this task, you will setup Flink and Grafana in your cluster and then build windows to process queries.

### Data Preparation

1. There are thirteen elements in each event, e.g, **sid, ts, x, y, z, |v|, |a|, vx, vy, vz, ax, ay, az**. The **sid** is the player-id and the **ts** is the time. The timestamp is calculated as **ts / (1000 * 1000 * 1000)**. Let the center point of the field be (0,0,0) and **(x,y,z)** is the position of the player in mm. When **x** is negative, the player is at the left half of the field otherwise at the right. The **|v|** is the instant speed of the player and **|v|** is the acceleration. The speed is calculated as **|v| / (1000 * 1000)**. Also, *vx, vy, vz* and *ax, ay, az* describe the direction of speed and acceleration, respectively. Furthermore, all events in dataset are in order.
2. Download and unpack the full-game and full-game-by-player datasets. The dataset is about 4 GB, so this may take a while. Both datasets have the same data, and splitting the first dataset(full-game) by id gives the second dataset(full-game-by-player). Your ZIP tool of choice may vary.

```
[...]
7za x full-game.zip
7za x full-game-by-player.zip
```

1. Check the presence of the resulting file and its size by running `ls -l -h`.

```
pi@node01:~ $ ls -l -h
[...]
-rw-r--r--  1 Thomas.Bodner  staff   3.96G Sep  5 06:55 full-game
-rw-r--r--  1 Thomas.Bodner  staff   61.3M Sep  5 06:55 66
-rw-r--r--  1 Thomas.Bodner  staff   43.0M Sep  5 06:55 106
[...]
```

1. Import the file into Flink.

### Process Stream Data

1. Write and run a query to filter out events where the player-id is equal to "65" and count how many events are left.
2. Write and run a query to count how many soccer players.

Report the results and runtime of each query in `task05_query_exercise_1.csv` as below:

| Query # | results | runtime (ms) |
|---------|---------|--------------|
| 1 |  |  |
| 2 |  |  |

### Process Stream Data with Window

1. Write and run a query to calculate average speed of players 10. Output the results for every 10 min. (Tumbling Window)
2. Write and run a query to calculate average speed of player 100 and 58. Output the results for every 10 min and window size is 15 min. (Sliding Window)
3. Write and run a query to list the average speed of player 16 for each run and the window gap is 30 sec. We think when the speed is larger than or equal to 1, the player is running. (Session Window)
4. Write and run a query to calculate average speed of player 66 when he has the same timestamp as player 106. Output results for every 10 min and window size is 15 min. (Sliding Window and Window Joining)

Report the results and runtimes of your queries in `task05_query_exercise_2.csv` as below:

| Window # | results |
|----------|---------|
| 1 |  |
| 2 |  |
| 3 |  |
| ... |  |

| Query # | runtime (ms) |
|---------|--------------|
| 1 |  |
| 2 |  |
| ... |  |

Report the query plans in a text file `task05_query_exercise_2_plans.txt`.

#### Bonus

For the fifth task, you can collect two bonus points:  
\- Efficiently process 3 concurrent queries: output the average speed of soccer player 23 for every 5 min, 10 min, and 20 min. Report your results and artifacts in the files `task05_bonus01.*`. (Sliding Window)  
\- Setup influxdb and Grafana to monitor Flink results. Report the screenshot of the dashboard page in the file `task05_bonus02.*`. Refer to https://github.com/apache/bahir-flink/tree/master/flink-connector-influxdb2.

Oscon Demo

#### Submission

Submit the following files packaged into a zip file named `task05.zip`:  
\- `task05_query_exercise_1.csv`  
\- `task05_query_exercise_2.csv`  
\- `task05_query_exercise_2_plans.txt`  
\- optional: `task05_bonus01.*`  
\- optional: `task05_bonus02.*`

#### Presentation

For each gion, we rotate and document the students representing the groups so every student gets her/his turn in the course of the semester.