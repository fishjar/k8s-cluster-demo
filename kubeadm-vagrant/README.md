# kubeadm-vagrant

## 准备环境

- 宿主机：ubuntu18.04
  - VirtualBox
  - vagrant
- 虚拟机：ubuntu16.04

### 安装`VirtualBox`及`vagrant`

（略）

```sh
# https://community.oracle.com/docs/DOC-1022800
# https://github.com/oracle/vagrant-boxes/tree/master/Kubernetes
```

### 创建`vagrant`文件

```Vagrantfile
# Vagrantfile
IMAGE_NAME = "ubuntu/xenial64"
N = 2
Vagrant.configure("2") do |config|
    config.ssh.insert_key = false
    config.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 2
    end
    config.vm.define "k8s-master" do |master|
        master.vm.box = IMAGE_NAME
        master.vm.network "private_network", ip: "192.168.50.10"
        master.vm.hostname = "k8s-master"
    end
    (1..N).each do |i|
        config.vm.define "node-#{i}" do |node|
            node.vm.box = IMAGE_NAME
            node.vm.network "private_network", ip: "192.168.50.#{i + 10}"
            node.vm.hostname = "node-#{i}"
        end
    end
end
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

## 所有节点

### 安装`docker`

```sh
# 参考：https://docs.docker.com/install/linux/docker-ce/ubuntu/
# 参考：https://kubernetes.io/docs/setup/production-environment/container-runtimes/

# 安装docker相关依赖
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# 设置国内源
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# sudo add-apt-repository \
#   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#   $(lsb_release -cs) \
#   stable"
curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
  "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

# 更新
sudo apt-get update

# 查看可用版本（可略）
apt-cache madison docker-ce
apt-cache madison docker-ce-cli

# 安装
# k8s 不支持最新docker版本，所以需指定一个支持的版本
# 经测试 docker-ce-cli 及 containerd.io 不需要安装
# sudo apt-get install docker-ce=18.06.2~ce~3-0~ubuntu
sudo apt-get install -y docker-ce=5:18.09.0~3-0~ubuntu-xenial docker-ce-cli=5:18.09.0~3-0~ubuntu-xenial containerd.io


####### 经测试，有时候以下两个步骤无需执行  #######
# 设置daemon
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# 重启docker
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo systemctl daemon-reload && sudo systemctl restart docker
```

### 关闭swap（可略）

经测试虚拟机默认没有swap，所以此步骤可略

```sh
# 临时关闭
sudo swapoff -a

# 永久关闭
sudo vim /etc/fstab
# 注释掉这一行
/swapfile none swap sw 0 0
```

### 安装`kubelet`、`kubeadm`、`kubectl`

```sh
# 参考：https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

# 设置国内源
# sudo apt-get update && sudo apt-get install -y apt-transport-https curl
# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
# cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
# deb https://apt.kubernetes.io/ kubernetes-xenial main
# EOF
curl -fsSL https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF

# 安装
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

### 配置节点 IP 地址（省略此步骤会有 bug）

```sh
# 参考：https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/#non-public-ip-used-for-containers
echo KUBELET_EXTRA_ARGS=\"--node-ip=`ip addr show enp0s8 | grep inet | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}/" | tr -d '/'`\" | sudo tee -a /etc/default/kubelet
sudo systemctl daemon-reload && sudo systemctl restart kubelet
```

### 提前下载所需镜像

```sh
# 查看镜像列表
kubeadm config images list
# k8s.gcr.io/kube-apiserver:v1.17.0
# k8s.gcr.io/kube-controller-manager:v1.17.0
# k8s.gcr.io/kube-scheduler:v1.17.0
# k8s.gcr.io/kube-proxy:v1.17.0
# k8s.gcr.io/pause:3.1
# k8s.gcr.io/etcd:3.4.3-0
# k8s.gcr.io/coredns:1.6.5

# 拉取镜像并修改tag
for i in `kubeadm config images list`; do
    imageName=${i#k8s.gcr.io/}
    sudo docker pull registry.aliyuncs.com/google_containers/$imageName
    sudo docker tag registry.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
    sudo docker rmi registry.aliyuncs.com/google_containers/$imageName
done;
```

## 主节点

### 建立集群

```sh
# 参考：https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
# kubeadm init --kubernetes-version="v1.17.0" --apiserver-advertise-address="192.168.50.10" --apiserver-cert-extra-sans="192.168.50.10"  --node-name k8s-master
sudo kubeadm init --apiserver-advertise-address="192.168.50.10" --apiserver-cert-extra-sans="192.168.50.10"  --node-name k8s-master

# root用户
export KUBECONFIG=/etc/kubernetes/admin.conf

# 非root用户的配置
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 安装网络插件

```sh
# Weave Net
sudo sysctl net.bridge.bridge-nf-call-iptables=1
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

### 其他操作

```sh
# 查看节点
kubectl get nodes

# 检查pods
kubectl get pods --all-namespaces

# 查看服务
kubectl get svc

# 清除节点
kubectl drain <node name> --delete-local-data --force --ignore-daemonsets
kubectl delete node <node name>
```

## 工作节点

### 配置一条路由，否则会有 bug

```sh
# 相关参考：
# https://github.com/weaveworks/weave/issues/3429
# https://github.com/weaveworks/weave/issues/3420#issuecomment-427354236
# https://github.com/kubernetes/kubeadm/issues/102#issuecomment-291532883
# https://stackoverflow.com/questions/39869583/how-to-get-kube-dns-working-in-vagrant-cluster-using-kubeadm-and-weave
# https://github.com/weaveworks/weave/issues/3363

# 临时添加
# 执行
sudo route add 10.96.0.1 gw 192.168.50.10
# # 或者
# sudo ip route add 10.96.0.0/16 via 192.168.50.10 dev enp0s8

# 永久添加
# cat <<EOF | sudo tee /etc/sysconfig/static-routes
# any net 10.96.0.1 gw 192.168.50.10
# EOF
echo "up route add -net 10.96.0.1 gw 192.168.50.10" | sudo tee -a /etc/network/interfaces
```

### 加入集群

```sh
# 加入集群
sudo kubeadm join 192.168.50.10:6443 --token <******************> \
    --discovery-token-ca-cert-hash <*********************>

# 退出集群
sudo kubeadm reset
```
