#!/bin/bash

echo -e "\e[1;36m ********** 主节点 ********** \e[0m"
echo -e "\e[1;36m ***** 建立集群 ***** \e[0m"
sudo kubeadm init --apiserver-advertise-address="192.168.50.10" --apiserver-cert-extra-sans="192.168.50.10"  --node-name k8s-master

echo -e "\e[1;36m ***** 配置非root用户 ***** \e[0m"
mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown $(id -u):$(id -g) /home/vagrant/.kube/config

echo -e "\e[1;36m ***** 安装网络插件 ***** \e[0m"
sudo sysctl net.bridge.bridge-nf-call-iptables=1
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

echo -e "\e[1;36m ***** 创建token及保存 ***** \e[0m"
sudo kubeadm token create --print-join-command >> ./kubeadm_join_cmd.sh
chmod +x ./kubeadm_join_cmd.sh

echo -e "\e[1;36m ***** 配置sshd ***** \e[0m"
sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
sudo service sshd restart
