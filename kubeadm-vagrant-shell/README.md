# kubeadm-vagrant

## 准备环境

- 宿主机：ubuntu18.04
  - VirtualBox
  - vagrant
- 虚拟机：ubuntu16.04

### 安装`VirtualBox`及`vagrant`

（略）

### 创建`vagrant`及脚本文件

```sh
├── all.sh
├── master.sh
├── node.sh
└── Vagrantfile
```

### 提前下载虚拟机镜像文件

```sh
vagrant box add ubuntu/xenial64 \
    https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-vagrant.box
```

### 一些有用的命令

```sh
# 启动虚拟机
vagrant up

# 挂起虚拟机
vagrant suspend

# 恢复虚拟机
vagrant resume

# 登录各个虚拟机
vagrant ssh k8s-master
vagrant ssh node-1
vagrant ssh node-2

# 切换root用户
sudo -Es
sudo su -
```

## 启动

```sh
vagrant up
```