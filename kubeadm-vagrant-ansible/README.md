# kubeadm-vagrant-ansible

参考：https://kubernetes.io/blog/2019/03/15/kubernetes-setup-using-ansible-and-vagrant/

## 准备环境

- 宿主机：ubuntu18.04
  - VirtualBox
  - vagrant
  - ansible
- 虚拟机：ubuntu16.04

### 安装`VirtualBox`及`vagrant`

（略）

### 安装`ansible`

```sh
sudo apt-get install software-properties-common
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible
```

### 创建`vagrant`及`playbook`文件

```sh
# 目录结构
├── kubernetes-setup
│   ├── master-playbook.yml
│   └── node-playbook.yml
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
vagrant ssh k8s0
vagrant ssh k8s1
vagrant ssh k8s2

# 切换root用户
sudo -Es
sudo su -
```

## 启动

```sh
vagrant up
```
