---
layout: post
title: "Snap Distribution of Kubectl and KUBECONFIG"
date: 2020-04-12T15:37:31-05:00
categories: 
excerpt: "Making snap's kubectl recognize KUBECONFIG"
tags: [kubernetes, snap, kubectl, ubuntu]
crosspost_to_medium: true
comments: true
---

I installed the `kubectl` distribution using `snap` in ubuntu 18.04. Everything was working fine during my testing using the local
kubernetes cluster that I installed with `microk8s`. But, when I tried to use the `$HOME/.kube/config` and adding information to
manage multiple clusters, then I found that `kubectl` didn't recognize the default config path at `$HOME/.kube/config` nor the env variable `KUBECONFIG` [^1].

I solved this by adding the line `--kubeconfig=${KUBECONFIG}` to `/var/snap/microk8s/current/args/kubectl`. And, adding the line
`export KUBECONFIG=$HOME/.kube/config` to `/var/snap/microk8s/current/args/kubectl-env`.

#### References

[^1]: <a target="null" href="https://github.com/ubuntu/microk8s/issues/259">Issue 259: microk8s.kubectl does not respect `$KUBECONFIG` var</a>