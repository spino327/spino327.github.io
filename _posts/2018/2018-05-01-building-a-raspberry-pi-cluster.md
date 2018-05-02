---
layout: post
title: "Building a Raspberry Pi Cluster"
date: 2018-05-01 12:00:00 -0500
categories: blog
excerpt: "This post will be updated with my experiences on how to create and maintain a Raspberry Pi cluster, so I will add content over time."
tags: [raspberry pi, cluster, kubernetes, docker]
---

I came across a presentation by Ray Tsang et al. that showcased a Raspberry Pi cluster with Docker and Kubernetes support [^1]. It is very useful to have a personal Raspberry Pi cluster to explore concepts of distributed systems and create proof of concept prototypes. This post will be updated with my experiences on how to create and maintain a Raspberry Pi cluster, so I will add content over time. 

### 1. Parts

Add list of parts + links

### 2. Operating System

Installation of Hypriot OS.

#### Setting up passwordless

I followed the guide by Mathias Kettner [^2] to setup ssh login without password. Basically, this is a two part process. First, create the key in your local machine.

    $ # generating a key that has not the default filename
    $ ssh-keygen -t rsa
     Enter file in which to save the key (<user_path>/.ssh/id_rsa): <user_path>/.ssh/pic1_id_rsa
     Enter passphrase (empty for no passphrase):
     Enter same passphrase again:
     Your identification has been saved in <user_path>/.ssh/pic1_id_rsa.
     Your public key has been saved in <user_path>/.ssh/pic1_id_rsa.pub.
     The key fingerprint is:
     ...

Second, setup the public key on the remote host.

    $ # Create .ssh folder in remote machine
    $ ssh ruser@remote 'mkdir -p ~/.ssh'
     ruser@remote's password:
    $ # Send key.pub to remote machine
    $ cat ~/.ssh/pic1_id_rsa.pub | ssh ruser@remote 'cat >> ~/.ssh/authorized_keys'
     ruser@remote's password:
    $ # Changing permissions in the remote machine of both .ssh and .ssh/authorized_keys
    $ ssh ruser@remote 'chmod 700 ~/.ssh'
    $ ssh ruser@remote 'chmod 640 ~/.ssh/authorized_keys'

Now, you can ssh to `remote` without password. I'm using a Mac laptop so I had to add the key to the ssh agent by `$ ssh-add $HOME/.ssh/pic1_id_rsa`.

### 3. Machine learning packages

#### 3.1 Tensorflow




### References

[^1]: <a target="null" href="https://kubernetes.io/blog/2015/11/creating-a-raspberry-pi-cluster-running-kubernetes-the-shopping-list-part-1">R. Tsang et al. Creating a Raspberry Pi cluster running Kubernetes, the shopping list (Part 1). Kubernetes Blog. 2015</a>

[^2]: <a target="null" href="http://www.linuxproblem.org/art_9.html">M. Kettner. SSH login without password.</a>
