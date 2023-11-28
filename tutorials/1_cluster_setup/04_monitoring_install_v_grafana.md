## Monitoring Setup

Now we install the dashboard on our cluster. These instructions should be executed only on the headnode.

### Grafana Installation

First we add a new Grafana source to our package manager.

```bash
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
```

After that we need to update the package manager.

```bash
sudo apt update
sudo apt --yes install grafana
```

Finally we enable the Grafana service, start it and check the status of the servcie. You should see an output that says `active (running)`.

```bash
sudo systemctl enable grafana-server
sudo systemctl restart grafana-server
sudo systemctl status --no-pager grafana-server

● grafana-server.service - Grafana instance
     Loaded: loaded (/lib/systemd/system/grafana-server.service; enabled; preset: enabled)
     Active: active (running) since Wed 2023-10-25 16:13:48 BST; 38min ago
       Docs: http://docs.grafana.org
   Main PID: 3553 (grafana)
      Tasks: 17 (limit: 8741)
        CPU: 23.383s
     CGroup: /system.slice/grafana-server.service
             └─3553 /usr/share/grafana/bin/grafana server --config=/etc/grafana/grafana.ini --pidfile=/run/grafana/grafana-server.pid --packaging=deb cfg:default.paths.logs=/var/log/grafana cfg:defau…

Oct 25 16:24:10 node01 grafana[3553]: logger=grafana.update.checker t=2023-10-25T16:24:10.964838059+01:00 level=info msg="Update check succeeded" duration=104.782212ms
Oct 25 16:24:11 node01 grafana[3553]: logger=plugins.update.checker t=2023-10-25T16:24:11.007787293+01:00 level=info msg="Update check succeeded" duration=135.489685ms
Oct 25 16:29:03 node01 grafana[3553]: logger=sqlstore.transactions t=2023-10-25T16:29:03.851033299+01:00 level=info msg="Database locked, sleeping then retrying" error="database is lo…abase is locked"
Oct 25 16:34:10 node01 grafana[3553]: logger=cleanup t=2023-10-25T16:34:10.597034822+01:00 level=info msg="Completed cleanup jobs" duration=42.298152ms
Oct 25 16:34:10 node01 grafana[3553]: logger=grafana.update.checker t=2023-10-25T16:34:10.956403431+01:00 level=info msg="Update check succeeded" duration=96.352942ms
Oct 25 16:34:10 node01 grafana[3553]: logger=plugins.update.checker t=2023-10-25T16:34:10.965993106+01:00 level=info msg="Update check succeeded" duration=94.10098ms
Oct 25 16:44:10 node01 grafana[3553]: logger=cleanup t=2023-10-25T16:44:10.601255367+01:00 level=info msg="Completed cleanup jobs" duration=46.1361ms
Oct 25 16:44:10 node01 grafana[3553]: logger=grafana.update.checker t=2023-10-25T16:44:10.985308878+01:00 level=info msg="Update check succeeded" duration=125.936688ms
Oct 25 16:44:10 node01 grafana[3553]: logger=plugins.update.checker t=2023-10-25T16:44:10.988460977+01:00 level=info msg="Update check succeeded" duration=116.474112ms
Oct 25 16:45:26 node01 grafana[3553]: logger=infra.usagestats t=2023-10-25T16:45:26.653063714+01:00 level=info msg="Usage stats are ready to report"
Hint: Some lines were ellipsized, use -l to show in full.
```

Now you should be able to access the Dashboard tool with `http://node01:3000`.

Continue with the visual dashboard setup.
