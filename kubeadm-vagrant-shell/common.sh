#!/bin/bash

echo -e "\e[1;36m ***** 设置 ubuntu 国内源 ***** \e[0m"
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
cat <<EOF | sudo tee /etc/apt/sources.list
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-proposed main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ xenial-proposed main restricted universe multiverse
EOF

echo -e "\e[1;36m ***** 安装 docker 相关依赖 ***** \e[0m"
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

echo -e "\e[1;36m ***** 设置docker国内源 ***** \e[0m"
curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
    "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

echo -e "\e[1;36m ***** 安装docker ***** \e[0m"
sudo apt-get update
# sudo apt-get install -y docker-ce=18.06.2~ce~3-0~ubuntu
sudo apt-get install -y docker-ce=5:18.09.0~3-0~ubuntu-xenial docker-ce-cli=5:18.09.0~3-0~ubuntu-xenial containerd.io

echo -e "\e[1;36m ***** 设置daemon ***** \e[0m"
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "registry-mirrors": ["https://registry.docker-cn.com"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

echo -e "\e[1;36m ***** 重启docker ***** \e[0m"
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo systemctl daemon-reload && sudo systemctl restart docker

echo -e "\e[1;36m ***** 关闭swap ***** \e[0m"
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo -e "\e[1;36m ***** 设置 k8s 国内源 ***** \e[0m"
curl -fsSL https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF

echo -e "\e[1;36m ***** 安装 k8s ***** \e[0m"
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# echo -e "\e[1;36m ***** 配置节点IP ***** \e[0m"
# echo KUBELET_EXTRA_ARGS=\"--node-ip=`ip addr show enp0s8 | grep inet | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}/" | tr -d '/'`\" | sudo tee -a /etc/default/kubelet
# sudo systemctl daemon-reload && sudo systemctl restart kubelet
# # sleep 5

echo -e "\e[1;36m ***** 拉取 k8s 镜像 ***** \e[0m"
for i in `kubeadm config images list`; do
    imageName=${i#k8s.gcr.io/}
    sudo docker pull registry.aliyuncs.com/google_containers/$imageName
    sudo docker tag registry.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
    sudo docker rmi registry.aliyuncs.com/google_containers/$imageName
done;
