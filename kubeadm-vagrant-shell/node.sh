#!/bin/bash

echo -e "\e[1;36m ********** 工作节点 ********** \e[0m"
echo -e "\e[1;36m ***** 添加路由 ***** \e[0m"
sudo ip route add 10.96.0.0/16 via 192.168.50.10 dev enp0s8

echo -e "\e[1;36m ***** 安装sshpass ***** \e[0m"
sudo apt-get update
sudo apt-get install -y sshpass

echo -e "\e[1;36m ***** 复制kubeadm_join_cmd.sh到本机 ***** \e[0m"
sshpass -p "vagrant" scp -o StrictHostKeyChecking=no vagrant@192.168.50.10:/home/vagrant/kubeadm_join_cmd.sh .

echo -e "\e[1;36m ***** 加入集群 ***** \e[0m"
sudo sh ./kubeadm_join_cmd.sh
