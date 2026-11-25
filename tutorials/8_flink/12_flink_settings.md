## Flink

### Setting Up an Flink Cluster

To set up a Flink cluster we need to modify Flinks config file `/opt/flink/conf/config.yaml`.
You can use the following command to modify the config file.

```bash
sudo nano /opt/flink/conf/config.yaml
```

Set the following parameters on all nodes. 

flink-conf.yaml:
```bash
[...]

jobmanager.rpc.address: node01
jobmanager.bind-host: node01
taskmanager.bind-host: <node[02-05]>
taskmanager.host: <node[02-05]>
taskmanager.numberOfTaskSlots: 30
rest.port: 8081
rest.address: node01
rest.bind-address: node01

[...]
```
Don't forget to comment out the corresponding lines in already existing settings.

**Important: The config-file on node02 will look like this:**
```
flink-conf.yaml:
```
```bash
[...]
jobmanager.rpc.address: node01
jobmanager.bind-host: node01
taskmanager.bind-host: node02
taskmanager.host: node02
taskmanager.numberOfTaskSlots: 30
rest.port: 8081
rest.address: node01
rest.bind-address: node01
[...]
```


On `node01` only, change the `/opt/flink/conf/masters` and `/opt/flink/conf/slaves`: 

```
/opt/flink/conf/masters
```
```
node01:8081
```
```
/opt/flink/conf/slaves
```
```
node02
node03
node04
node05
```
You might also need to adapt `/opt/flink/conf/workers` to: 
```
/opt/flink/conf/workers
```
```
node02
node03
node04
node05
```

Start the Flink cluster with the following command

```bash
/opt/flink/bin/start-cluster.sh 
```

After some start up time you can 
  - run `curl -fsS http://node01:8081/overview` which should output `"taskmanagers":4,"slots-total":4,"slots-available":4` among others, and
  - access the Flink Web UI via [http://node01:8081](http://node01:8081). The [Task Managers Page](http://node01:8081/#/taskmanagers) should display the four task managers at this point.

If this is not the case, check the logs on each node (`/opt/flink/log/*`) or have a look at the [Flink documentation page](https://nightlies.apache.org/flink/flink-docs-release-1.8/ops/deployment/yarn_setup.html#submit-job-to-flink).
