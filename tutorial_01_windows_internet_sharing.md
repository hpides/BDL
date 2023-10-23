## Build a HPC-Cluster with Raspberry Pis

Now we will setup the Windows workstation to be able to share internet with the cluster.

### Share the Internet Connection

Next we share the internet connection with the Pi cluster. In Windows go to the settings of network connections.

![goToNetworkConnections.png](.attachments.8189554/goToNetworkConnections.png)

Right click on the network interface that provides the internet and select properties.

![networkConnectionProperties.png](.attachments.8189554/networkConnectionProperties.png)

Under sharing check the checkbox and select the name of the network device connected to the pi cluster. Click on OK when you selected everything.

![networkSharing.png](.attachments.8189554/networkSharing.png)

Done! Now your Pi cluster should have a working internet connection.
