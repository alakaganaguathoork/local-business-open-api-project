#!/bin/bash
kubeadm join 172.16.8.10:6443 --token aaro1p.vkrkhxvfte0m1us3 --discovery-token-ca-cert-hash sha256:7460e41c23cbc093bbe2a6be8e724786990d942d7d4196fc7ae25826a71c42e7  --cri-socket unix:///var/run/cri-dockerd.sock
