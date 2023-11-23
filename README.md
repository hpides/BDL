# Pi-Cluster

Several scripts for Ubuntu to create a Pi Cluster with Hadoop to run a count example

# Usage

Download and copy `hadoop-3.3.6.tar.gz` and `jdk-8u371-linux-aarch64.tar.gz` into the `./dependencies` folder.

Afterwards start with the `00_physical_cluster_setup.md` file.
The order how you suppose to read the READMEs is
 1. `00_physical_cluster_setup.md`
 2. `01_ubuntu_connection_to_pi_cluster.md`, `01_windows_connection_to_pi_cluster.md` or `01_mac_connection_to_pi_cluster.md`
 3. `01_ubuntu_internet_sharing.md`, `01_windows_internet_sharing.md` or `01_mac_internet_sharing.md`
 4. `02_adding_pi_os_to_sd_cards.md`
 5. `02_cluster_network.md`
 6. `02_cluster_passwordless_ssh_and_environment_variables.md`
 7. `03_hadoop_dependencies.md`
 8. `03_hadoop_installation.md`
 9. `03_hadoop_settings.md`
1.  `03_hadoop_word_count_example.md`
2.  `04_monitoring_install_node_exporter.md`
3.  `04_monitoring_install_prometheus.md`
4.  `04_monitoring_install_v_grafana.md`
5.  `04_monitoring_visual_dashboard_setup.md`
6.  `05_nfs_head_node.md`
7.  `05_nfs_worker_node.md`
8.  `06_spark_setup.md`
9.  `07_pyspark_setup.md`
