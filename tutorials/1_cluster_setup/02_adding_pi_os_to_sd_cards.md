## Build a HPC-Cluster with Raspberry Pis

Now we install an operating system for the Pi cluster nodes.

### Prepare Micro SD Cards

We already inserted the SD-Cards into the Pi cluster. You need to remove them one by one and follow the instructions. After that, we set up our SD-Cards and install the OS for our Raspberry Pis. Download the Raspberry Pi Imager [here](https://www.raspberrypi.com/software/) and plug in your SD-Card. Select **Raspberry Pi OS (Legacy, 64-bit) Lite** as the operating system of the Pi nodes.

![img01.png](../../pictures/2026/img01.png)

![img02.png](../../pictures/2026/img02.png)

Insert the SD card into your laptop and select the SD card in the imager.

![img03.png](../../pictures/2026/img03.png)

![img04.png](../../pictures/2026/img04.png)

Additionally, go to settings and set the hostname in the advanced options (`node01`, `node02`, ..., `node05`), enable ssh and set `raspberry` as the password.

![img05.png](../../pictures/2026/img05.png)

![img06.png](../../pictures/2026/img06.png)

![img07.png](../../pictures/2026/img07.png)

![img08.png](../../pictures/2026/img08.png)

And finally write the image to the SD card.

![img09.png](../../pictures/2026/img09.png)


Depending on the Raspberry Imager, you may need to manually adjust the user settings in the OS. After flashing the SD card with the RaspbianOS, set the hostname to enable SSH access by modifying ```/BOOT/user-data``` file. Replace node0X with the one of X=1,2,3,4,5. The username for all nodes is ```pi```. Create a hash of the password. Replace ```yourpassword``` with ```raspberry```.

```
HASH=$(openssl passwd -6 'yourpassword')
echo $HASH
```

Copy the hash value to the ```user-data``` file.

```
#cloud-config
hostname: node0X
manage_etc_hosts: true
enable_ssh: true
ssh_pwauth: true
timezone: Europe/Berlin

users:
  - name: pi
    groups: users,adm,dialout,audio,netdev,video,plugdev,cdrom,games,input,gpio,spi,i2c,render,sudo
    shell: /bin/bash
    lock_passwd: false
    passwd: "$HASH"
    sudo: ALL=(ALL) NOPASSWD:ALL
```

After preparing all SD-cards the tutorial splits and explains for mac, Windows and Ubuntu users how to connect to the Pi cluster via network with ssh. Make sure to open the appropriate `tutorial_01_[..].md`. The `tutorial_01_clustersetup_and_ssh_with_[mac|ubuntu|windows]_workstation.md` name gives you a hint on which operating system is targeted.
