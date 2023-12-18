## Flink

### Setting Up an Flink Cluster

To set up a Flink cluster we need to modify Flinks config file `/opt/flink/conf/flink-conf.yaml`.
You can use the following command to modify the config file.

```bash
sudo nano /opt/flink/conf/flink-conf.yaml
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


On `node01` only, change the `/opt/flink/conf/masters` and `/opt/flink/conf/masters`: 

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


Start the Flink cluster with the following command

```bash
/opt/flink/bin/start-cluster.sh 
```

After some start up time you can access the Flink Web UI via [http://node01:8081](http://node01:8081). The [Task Managers Page](http://node01:8081/#/taskmanagers) should display the four task managers at this point. If this is not the case, check the logs on each node (`/opt/flink/log/*`) or have a look at the [Flink documentation page](https://nightlies.apache.org/flink/flink-docs-release-1.8/ops/deployment/yarn_setup.html#submit-job-to-flink).
