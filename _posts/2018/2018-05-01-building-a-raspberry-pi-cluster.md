---
layout: post
title: "Building a Raspberry Pi Cluster"
date: 2018-05-01 12:00:00 -0500
categories: blog
excerpt: "This post will be updated with my experiences on how to create and maintain a Raspberry Pi cluster, so I will add content over time."
tags: [raspberry pi, cluster, docker, kubernetes]
comments: true
---

I came across a presentation by Ray Tsang et al. that showcased a Raspberry Pi cluster with Docker and Kubernetes support [^1]. It is very useful to have a personal Raspberry Pi cluster to explore concepts of distributed systems and create proof of concept prototypes. This post will be updated with my experiences on how to create and maintain a Raspberry Pi cluster, so I will add content over time. 

### 1. Parts

My cluster is based on Raspberry Pi 3 Model B. I tried to follow the list of parts presented in [^1]. Below I list the parts and links to each part in amazon (USA).

| Part | URL |  
| :--  | :-- | 
| Raspberry Pi 3 Model B Motherboard | <a href="https://www.amazon.com/gp/product/B01CD5VC92/ref=oh_aui_detailpage_o07_s00?ie=UTF8&psc=1" target="_null">link</a> |
| Anker 60W 6-Port USB Wall Charger | <a href="https://www.amazon.com/gp/product/B00P936188/ref=oh_aui_detailpage_o07_s00?ie=UTF8&psc=1" target="_null">link</a> |
| Samsung 32GB 95MB/s (U1) MicroSD EVO Select Memory Card | <a href="https://www.amazon.com/gp/product/B06XWN9Q99/ref=oh_aui_detailpage_o06_s00?ie=UTF8&psc=1" target="_null">link</a> |
| Cat 6 Ethernet Cable 5 ft (5 PACK) Flat Internet Network Cable | <a href="https://www.amazon.com/gp/product/B017R12IJA/ref=oh_aui_detailpage_o03_s00?ie=UTF8&psc=1" target="_null">link</a> |
| NETGEAR N300 Wi-Fi Router with High Power 5dBi External Antennas (WNR2020v2)  | <a href="https://www.amazon.com/NETGEAR-Router-External-Antennas-WNR2020v2/dp/B00MRVJYEI/ref=sr_1_1?ie=UTF8&qid=1526432473&sr=8-1&keywords=netgear+wnr2020" target="_null">link</a> |
| Kingston Digital USB 3.0 Portable Card Reader for SD, microSD. | <a href="https://www.amazon.com/gp/product/B00KX4TORI/ref=oh_aui_detailpage_o08_s01?ie=UTF8&psc=1" target="_null">link</a> |

I 3D printed the cluster rack using the files <a href="https://www.thingiverse.com/thing:2371586" target="_blank">Raspberry Cluster Frame</a>.

![setup](/assets/img/c_pi_setup_small.jpg)

### 2. Operating System

I selected Hypriot OS since it already has support for docker. Also, with HypriotOS 1.7 and up, it is possible to use cloud-init to automatically change some settings on first boot. The version of `cloud-init` that it seems to support is [v0.7.9](https://cloudinit.readthedocs.io/en/0.7.9/index.html).

Since my cluster is based on Raspberry PI 3 model B which includes a *Quad Core 1.2GHz Broadcom BCM2837 64bit CPU* [^3], then I use the releases of Hypriot OS provided by the github repo `DieterReuter/image-builder-rpi64` (64 bit distribution) instead of the ones provided by the repo `hypriot/image-builder-rpi` (32-bit distribution) [^4].

#### 2.1. Flashing the OS

First, I decided to use the command line script developed by hypriot and hosted on github `hypriot/flash` [^5]. The advantage of this over a more simple method such as `sudo dd if=image.img of=/dev/rdisk2 bs=1m`. After installing the dependencies as described in the `hypriot/flash` repo, I installed the command line utility in `$HOME/bin`.  

    $ # get the release
    $ curl -O https://raw.githubusercontent.com/hypriot/flash/master/flash
    $ # add executable permissions
    $ chmod +x flash
    $ # move to ~/bin
    $ mv flash $HOME/bin/
    $ # export $HOME/bin to the path
    $ export PATH=$HOME/bin:$PATH

Second, I got the OS image from `DieterReuter/image-builder-rpi64`[^6]:

    $ wget https://github.com/DieterReuter/image-builder-rpi64/releases/download/v20180429-184538/hypriotos-rpi64-v20180429-184538.img.zip
    $ wget https://github.com/DieterReuter/image-builder-rpi64/releases/download/v20180429-184538/hypriotos-rpi64-v20180429-184538.img.zip.sha256
    $ # Verify the image with sha-256
    $ shasum -a 256 hypriotos-rpi64-v20180429-184538.img.zip


Flashing the sd-card:

    $ # Setting nodeX and with the user-data.yml
    $ flash --hostname nodeX --userdata ./user-data.yml hypriotos-rpi64-v20180429-184538.img

You can find an example of the <a href="https://gist.github.com/spino327/d514212f9f782d786cedf0487854c6f9" target="_blank">user-data.yml</a> 

#### 2.1. Network configuration (using a router)

I decided to configure the network interface using static IPs. The idea is to modify the file for `eth0` which is located at `sudo vim /etc/network/interfaces.d/eth0`. As an example this is the setup for *node1*.

    allow-hotplug eth0
    iface eth0 inet static
        address 192.168.2.11
        network 192.168.2.0
        netmask 255.255.255.0
        broadcast 192.168.2.255
        gateway 192.168.2.1

I have a small Netgear WNR2020 wireless router dedicated to the Pi cluster, which is connected to another router that provides internet to it. I found useful to modify the DNS routes by adding the google DNS servers. Thus, I modified the file `/etc/resolv.conf` to look like (you need `sudo` to write to it):

    $ cat /etc/resolv.conf
      nameserver 8.8.8.8
      nameserver 8.8.4.4
      nameserver 192.168.2.1

##### 2.1.1 Network configuration (using a switch and head node with NAT)

Recently, I updated the cluster by removing the router. Thus, now the configuration uses a switch to communicate internally with the cluster's nodes.
Also, I configured the head node to be a NAT. Basically, the head node connects to my wireless network using `wlan0` and serves as NAT through the ethernet interface `eth0`.

###### 2.1.1.1 Head node

First, tell the kernel to enabled IP forwarding by either `echo 1 > /proc/sys/net/ipv4/ip_forward` or by changing the line `net.ipv4.ip_forward=1` in the file `/etc/sysctl.conf`.

Second, make the head node to act as NAT:  

    $ sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
    $ sudo iptables -A FORWARD -i wlan0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    $ sudo iptables -A FORWARD -i eth0 -o wlan0 -j ACCEPT

We can save the iptable rules and restore them at boot by:

    $ sudo iptables-save > /etc/cluster_ip_rules.fw

Third, I added the configuration for the wireless interface as:

    $ cat /etc/network/interfaces.d/wlan0 
    auto wlan0
    iface wlan0 inet dhcp
        wpa-ssid "Your ssid"
        wpa-psk "your password"
        gateway 192.168.1.1
        post-up iptables-restore < /etc/cluster_ip_rules.fw

###### 2.1.1.2. Slave nodes

In the other nodes, I changed the `eth0` configuration by adding the head node IP as the gateway. So it looks like:  

    $ cat /etc/network/interfaces.d/eth0
    allow-hotplug eth0
    #iface eth0 inet dhcp
    iface eth0 inet static
        address 192.168.2.13
        network 192.168.2.0
        netmask 255.255.255.0
        broadcast 192.168.2.255
        gateway 192.168.2.11

make sure that the file `/etc/resolv.conf.head` has the line `nameserver 192.168.1.1` or pointing to your wifi router's IP address.

#### 2.2. Setting up passwordless

I followed the guide by Mathias Kettner [^2] to setup ssh login without password. Basically, this is a two part process. First, create the key in your local machine.

    $ # generating a key that has not the default filename
    $ ssh-keygen -t rsa
     Enter file in which to save the key (<user_path>/.ssh/id_rsa): <user_path>/.ssh/pic_id_rsa
     Enter passphrase (empty for no passphrase):
     Enter same passphrase again:
     Your identification has been saved in <user_path>/.ssh/pic_id_rsa.
     Your public key has been saved in <user_path>/.ssh/pic_id_rsa.pub.
     The key fingerprint is:
     ...

Second, setup the public key on the remote host.

    $ # Create .ssh folder in remote machine
    $ ssh ruser@remote 'mkdir -p ~/.ssh'
     ruser@remote's password:
    $ # Send key.pub to remote machine
    $ cat ~/.ssh/pic_id_rsa.pub | ssh ruser@remote 'cat >> ~/.ssh/authorized_keys'
     ruser@remote's password:
    $ # Changing permissions in the remote machine of both .ssh and .ssh/authorized_keys
    $ ssh ruser@remote 'chmod 700 ~/.ssh'
    $ ssh ruser@remote 'chmod 640 ~/.ssh/authorized_keys'

Now, you can ssh to `remote` without password. I'm using a Mac laptop so I had to add the key to the ssh agent by `$ ssh-add $HOME/.ssh/pic_id_rsa`.

<!-- #### 2.3. Adding a SWAP memory using a external USB drive -->

<!--     $ sudo mkswap /dev/sda1 -->
<!--     mkswap: /dev/sda1: warning: wiping old vfat signature. -->
<!--     Setting up swapspace version 1, size = 3.8 GiB (4009746432 bytes) -->
<!--     no label, UUID=27a3a61d-3ddf-4aa9-88a4-d4b3b8479470 -->
<!--     HypriotOS/arm64: pirate@node2 in ~ -->
<!--     $ sudo blkid -->
<!--     /dev/mmcblk0p1: SEC_TYPE="msdos" LABEL="HypriotOS" UUID="7075-EEF7" TYPE="vfat" -->
<!--     /dev/mmcblk0p2: LABEL="root" UUID="2a81f25a-2ca2-4520-a1a6-c9dd75527c3c" TYPE="ext4" -->
<!--     /dev/sda1: UUID="27a3a61d-3ddf-4aa9-88a4-d4b3b8479470" TYPE="swap" -->
<!--     /dev/mmcblk0: PTTYPE="dos" -->

### 3. Docker

There are several docker images for **arm64v8** in the [docker registry](https://hub.docker.com/u/arm64v8/).

### 4. Kubernetes

In the following section, I assume that you're logged as root. If not, then you will need to insert `sudo` in the commands. The end result should be the same.

First, add the encryption key for the packages  

    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -


Second, add repository  

    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" >> /etc/apt/sources.list.d/kubernetes.list

Third, in each node install kubernetes

    apt-get install -y kubelet kubeadm kubectl kubernetes-cni

#### 4.1. Configuring the master node

    $ kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address 192.168.2.11

To start using your cluster, you need to run the following as a regular user:  

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

#### 4.2. Configuring the network with Flannel

[Flannel](https://github.com/coreos/flannel) is a simple and easy way to configure a layer 3 network fabric designed for Kubernetes.\
You just need to apply it to your cluster using `kubectl`:

```sh
$ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

#### 4.3. Configuring the worker nodes

We just need to join our worker nodes using the `kubeadm join` command and passing the token and discovery-token-ca-cert-hash that
was provided by `kubeadm init`.

```sh
$ kubeadm join 192.168.2.11:6443 --token=<token> --discovery-token-ca-cert-hash <sha256:...>
```

#### 4.4. Accessing the cluster 

To access the cluster from a remote machine with `kubectl` you can use `kubectl proxy`. In my case, the master node in the raspberry pi
cluster has two network interfaces, and I wanted to connect from a machine that is in the external network (external network is `192.168.1.0/24` and the internal network is `192.168.2.0/24`). Thus, running `kubectl proxy` in the master node and passing parameters to use the
external ip of the master node (in my case `--address=192.168.1.32`) and passing a list of allowed hosts for the IPs in the external network (`--accept-hosts="^192.168.1"`):

```sh
$ kubectl proxy --port=8080 --address=192.168.1.32 --accept-hosts="^192.168.1"
```

Then, you can create or add into your desired KUBECONFIG file the following information:

```yaml
apiVersion: v1
clusters:
- cluster:
    server: http://192.168.1.32:8080
  name: rpi-cluster
contexts:
- context:
    cluster: rpi-cluster
  name: rpi
current-context: rpi
kind: Config
preferences: {}
```

### References

[^1]: <a target="null" href="https://kubernetes.io/blog/2015/11/creating-a-raspberry-pi-cluster-running-kubernetes-the-shopping-list-part-1">R. Tsang et al. Creating a Raspberry Pi cluster running Kubernetes, the shopping list (Part 1). Kubernetes Blog. 2015.</a>

[^2]: <a target="null" href="http://www.linuxproblem.org/art_9.html">M. Kettner. SSH login without password.</a>

[^3]: <a target="null" href="https://www.raspberrypi.org/products/raspberry-pi-3-model-b/">Raspberry PI 3 model B specs.</a>

[^4]: <a target="null" href="https://blog.hypriot.com/post/cloud-init-cloud-on-hypriot-x64/">Bootstrapping a Cloud with Cloud-Init and HypriotOS (64-bit).</a>

[^5]: <a target="null" href="https://github.com/hypriot/flash">flash: Command line script to flash SD card images of any kind.</a>

[^6]: <a target="null" href="https://github.com/DieterReuter/image-builder-rpi64/releases">Releases for image-builder-rpi64.</a>

<!-- [^]: <a target="null" href=""></a> -->
