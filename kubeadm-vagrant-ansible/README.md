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
vagrant ssh k8s-master
vagrant ssh node-1
vagrant ssh node-2

# 切换root用户
sudo -Es
sudo su -
```

## 主节点

```sh
# 启动
vagrant up
Bringing machine 'k8s-master' up with 'virtualbox' provider...
Bringing machine 'node-1' up with 'virtualbox' provider...
Bringing machine 'node-2' up with 'virtualbox' provider...
==> k8s-master: Importing base box 'ubuntu/xenial64'...
==> k8s-master: Matching MAC address for NAT networking...
==> k8s-master: Setting the name of the VM: kubeadm-vagrant-ansible_k8s-master_1576121057172_75797
==> k8s-master: Clearing any previously set network interfaces...
==> k8s-master: Preparing network interfaces based on configuration...
    k8s-master: Adapter 1: nat
    k8s-master: Adapter 2: hostonly
==> k8s-master: Forwarding ports...
    k8s-master: 22 (guest) => 2222 (host) (adapter 1)
==> k8s-master: Running 'pre-boot' VM customizations...
==> k8s-master: Booting VM...
==> k8s-master: Waiting for machine to boot. This may take a few minutes...
    k8s-master: SSH address: 127.0.0.1:2222
    k8s-master: SSH username: vagrant
    k8s-master: SSH auth method: private key
    k8s-master: Warning: Connection reset. Retrying...
    k8s-master: Warning: Remote connection disconnect. Retrying...
==> k8s-master: Machine booted and ready!
==> k8s-master: Checking for guest additions in VM...
    k8s-master: The guest additions on this VM do not match the installed version of
    k8s-master: VirtualBox! In most cases this is fine, but in rare cases it can
    k8s-master: prevent things such as shared folders from working properly. If you see
    k8s-master: shared folder errors, please make sure the guest additions within the
    k8s-master: virtual machine match the version of VirtualBox you have installed on
    k8s-master: your host and reload your VM.
    k8s-master: 
    k8s-master: Guest Additions Version: 5.1.38
    k8s-master: VirtualBox Version: 5.2
==> k8s-master: Setting hostname...
==> k8s-master: Configuring and enabling network interfaces...
==> k8s-master: Mounting shared folders...
    k8s-master: /vagrant => /home/gabe/code/fishjar/k8s-cluster-demo/kubeadm-vagrant-ansible
==> k8s-master: Running provisioner: ansible...
Vagrant has automatically selected the compatibility mode '2.0'
according to the Ansible version installed (2.9.2).

Alternatively, the compatibility mode can be specified in your Vagrantfile:
https://www.vagrantup.com/docs/provisioning/ansible_common.html#compatibility_mode

    k8s-master: Running ansible-playbook...

PLAY [all] *********************************************************************

TASK [Gathering Facts] *********************************************************
ok: [k8s-master]

TASK [安装 docker 相关依赖] **********************************************************
changed: [k8s-master]

TASK [添加 docker key] ***********************************************************
changed: [k8s-master]

TASK [添加 docker 国内源] ***********************************************************
changed: [k8s-master]

TASK [安装 docker] ***************************************************************
changed: [k8s-master]

TASK [添加 vagrant 到 docker 用户组 （可略）] ********************************************
changed: [k8s-master]

TASK [移除 swapfile （可略）] ********************************************************
ok: [k8s-master] => (item=swap)
ok: [k8s-master] => (item=none)

TASK [关闭 swap （可略）] ************************************************************
skipping: [k8s-master]

TASK [添加 kubernetes key] *******************************************************
changed: [k8s-master]

TASK [添加 kubernetes 国内源] *******************************************************
changed: [k8s-master]

TASK [安装 Kubernetes] ***********************************************************
changed: [k8s-master]

TASK [设置节点IP] ******************************************************************
changed: [k8s-master]

TASK [重启 kubelet] **************************************************************
changed: [k8s-master]

TASK [拉取 k8s 所需镜像] *************************************************************
changed: [k8s-master]

TASK [创建集群] ********************************************************************
changed: [k8s-master]

TASK [非root用户的配置] **************************************************************
changed: [k8s-master] => (item=mkdir -p /home/vagrant/.kube)
changed: [k8s-master] => (item=cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config)
changed: [k8s-master] => (item=chown vagrant:vagrant /home/vagrant/.kube/config)
[WARNING]: Consider using the file module with state=directory rather than
running 'mkdir'.  If you need to use command because file is insufficient you
can add 'warn: false' to this command task or set 'command_warnings=False' in
ansible.cfg to get rid of this message.

[WARNING]: Consider using the file module with owner rather than running
'chown'.  If you need to use command because file is insufficient you can add
'warn: false' to this command task or set 'command_warnings=False' in
ansible.cfg to get rid of this message.


TASK [添加网络插件： Weave Net] *******************************************************
changed: [k8s-master]

TASK [创建token及加入集群的命令] *********************************************************
changed: [k8s-master]

TASK [保存加入集群的命令到本地（宿主机）] *******************************************************
changed: [k8s-master -> localhost]

RUNNING HANDLER [docker status] ************************************************
ok: [k8s-master]

PLAY RECAP *********************************************************************
k8s-master                 : ok=19   changed=16   unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   

==> node-1: Importing base box 'ubuntu/xenial64'...
==> node-1: Matching MAC address for NAT networking...
==> node-1: Setting the name of the VM: kubeadm-vagrant-ansible_node-1_1576121280593_28787
==> node-1: Fixed port collision for 22 => 2222. Now on port 2200.
==> node-1: Clearing any previously set network interfaces...
==> node-1: Preparing network interfaces based on configuration...
    node-1: Adapter 1: nat
    node-1: Adapter 2: hostonly
==> node-1: Forwarding ports...
    node-1: 22 (guest) => 2200 (host) (adapter 1)
==> node-1: Running 'pre-boot' VM customizations...
==> node-1: Booting VM...
==> node-1: Waiting for machine to boot. This may take a few minutes...
    node-1: SSH address: 127.0.0.1:2200
    node-1: SSH username: vagrant
    node-1: SSH auth method: private key
    node-1: Warning: Connection reset. Retrying...
    node-1: Warning: Remote connection disconnect. Retrying...
==> node-1: Machine booted and ready!
==> node-1: Checking for guest additions in VM...
    node-1: The guest additions on this VM do not match the installed version of
    node-1: VirtualBox! In most cases this is fine, but in rare cases it can
    node-1: prevent things such as shared folders from working properly. If you see
    node-1: shared folder errors, please make sure the guest additions within the
    node-1: virtual machine match the version of VirtualBox you have installed on
    node-1: your host and reload your VM.
    node-1: 
    node-1: Guest Additions Version: 5.1.38
    node-1: VirtualBox Version: 5.2
==> node-1: Setting hostname...
==> node-1: Configuring and enabling network interfaces...
==> node-1: Mounting shared folders...
    node-1: /vagrant => /home/gabe/code/fishjar/k8s-cluster-demo/kubeadm-vagrant-ansible
==> node-1: Running provisioner: ansible...
Vagrant has automatically selected the compatibility mode '2.0'
according to the Ansible version installed (2.9.2).

Alternatively, the compatibility mode can be specified in your Vagrantfile:
https://www.vagrantup.com/docs/provisioning/ansible_common.html#compatibility_mode

    node-1: Running ansible-playbook...

PLAY [all] *********************************************************************

TASK [Gathering Facts] *********************************************************
ok: [node-1]

TASK [安装 docker 相关依赖] **********************************************************
changed: [node-1]

TASK [添加 docker key] ***********************************************************
changed: [node-1]

TASK [添加 docker 国内源] ***********************************************************
changed: [node-1]

TASK [安装 docker] ***************************************************************
changed: [node-1]

TASK [添加 vagrant 到 docker 用户组 （可略）] ********************************************
changed: [node-1]

TASK [移除 swapfile （可略）] ********************************************************
ok: [node-1] => (item=swap)
ok: [node-1] => (item=none)

TASK [关闭 swap （可略）] ************************************************************
skipping: [node-1]

TASK [添加 kubernetes key] *******************************************************
changed: [node-1]

TASK [添加 kubernetes 国内源] *******************************************************
changed: [node-1]

TASK [安装 kubelet、kubeadm、kubectl] **********************************************
changed: [node-1]

TASK [设置节点IP] ******************************************************************
changed: [node-1]

TASK [重启 kubelet] **************************************************************
changed: [node-1]

TASK [拉取 k8s 所需镜像] *************************************************************
changed: [node-1]

TASK [添加路由（避免网络插件1/2错误）] *******************************************************
changed: [node-1]

TASK [复制加入集群命令到节点] *************************************************************
changed: [node-1]

TASK [加入集群] ********************************************************************
changed: [node-1]

RUNNING HANDLER [docker status] ************************************************
ok: [node-1]

PLAY RECAP *********************************************************************
node-1                     : ok=17   changed=14   unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   

==> node-2: Importing base box 'ubuntu/xenial64'...
==> node-2: Matching MAC address for NAT networking...
==> node-2: Setting the name of the VM: kubeadm-vagrant-ansible_node-2_1576121503315_59338
==> node-2: Fixed port collision for 22 => 2222. Now on port 2201.
==> node-2: Clearing any previously set network interfaces...
==> node-2: Preparing network interfaces based on configuration...
    node-2: Adapter 1: nat
    node-2: Adapter 2: hostonly
==> node-2: Forwarding ports...
    node-2: 22 (guest) => 2201 (host) (adapter 1)
==> node-2: Running 'pre-boot' VM customizations...
==> node-2: Booting VM...
==> node-2: Waiting for machine to boot. This may take a few minutes...
    node-2: SSH address: 127.0.0.1:2201
    node-2: SSH username: vagrant
    node-2: SSH auth method: private key
==> node-2: Machine booted and ready!
==> node-2: Checking for guest additions in VM...
    node-2: The guest additions on this VM do not match the installed version of
    node-2: VirtualBox! In most cases this is fine, but in rare cases it can
    node-2: prevent things such as shared folders from working properly. If you see
    node-2: shared folder errors, please make sure the guest additions within the
    node-2: virtual machine match the version of VirtualBox you have installed on
    node-2: your host and reload your VM.
    node-2: 
    node-2: Guest Additions Version: 5.1.38
    node-2: VirtualBox Version: 5.2
==> node-2: Setting hostname...
==> node-2: Configuring and enabling network interfaces...
==> node-2: Mounting shared folders...
    node-2: /vagrant => /home/gabe/code/fishjar/k8s-cluster-demo/kubeadm-vagrant-ansible
==> node-2: Running provisioner: ansible...
Vagrant has automatically selected the compatibility mode '2.0'
according to the Ansible version installed (2.9.2).

Alternatively, the compatibility mode can be specified in your Vagrantfile:
https://www.vagrantup.com/docs/provisioning/ansible_common.html#compatibility_mode

    node-2: Running ansible-playbook...

PLAY [all] *********************************************************************

TASK [Gathering Facts] *********************************************************
ok: [node-2]

TASK [安装 docker 相关依赖] **********************************************************
changed: [node-2]

TASK [添加 docker key] ***********************************************************
changed: [node-2]

TASK [添加 docker 国内源] ***********************************************************
changed: [node-2]

TASK [安装 docker] ***************************************************************
changed: [node-2]

TASK [添加 vagrant 到 docker 用户组 （可略）] ********************************************
changed: [node-2]

TASK [移除 swapfile （可略）] ********************************************************
ok: [node-2] => (item=swap)
ok: [node-2] => (item=none)

TASK [关闭 swap （可略）] ************************************************************
skipping: [node-2]

TASK [添加 kubernetes key] *******************************************************
changed: [node-2]

TASK [添加 kubernetes 国内源] *******************************************************
changed: [node-2]

TASK [安装 kubelet、kubeadm、kubectl] **********************************************
changed: [node-2]

TASK [设置节点IP] ******************************************************************
changed: [node-2]

TASK [重启 kubelet] **************************************************************
changed: [node-2]

TASK [拉取 k8s 所需镜像] *************************************************************
changed: [node-2]

TASK [添加路由（避免网络插件1/2错误）] *******************************************************
changed: [node-2]

TASK [复制加入集群命令到节点] *************************************************************
changed: [node-2]

TASK [加入集群] ********************************************************************
changed: [node-2]

RUNNING HANDLER [docker status] ************************************************
ok: [node-2]

PLAY RECAP *********************************************************************
node-2                     : ok=17   changed=14   unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

# 登录主节点
vagrant ssh k8s-master
sudo -Es

# 查看所有节点
kubectl get nodes
NAME         STATUS   ROLES    AGE     VERSION
k8s-master   Ready    master   13m     v1.17.0
node-1       Ready    <none>   9m45s   v1.17.0
node-2       Ready    <none>   3m39s   v1.17.0

# 查看所有pod
kubectl get pods --all-namespaces
NAMESPACE     NAME                                 READY   STATUS    RESTARTS   AGE
kube-system   coredns-6955765f44-d2vn6             1/1     Running   0          15m
kube-system   coredns-6955765f44-szmrf             1/1     Running   0          15m
kube-system   etcd-k8s-master                      1/1     Running   0          15m
kube-system   kube-apiserver-k8s-master            1/1     Running   0          15m
kube-system   kube-controller-manager-k8s-master   1/1     Running   0          15m
kube-system   kube-proxy-425jk                     1/1     Running   0          15m
kube-system   kube-proxy-h5v7s                     1/1     Running   0          5m36s
kube-system   kube-proxy-kjsdb                     1/1     Running   0          11m
kube-system   kube-scheduler-k8s-master            1/1     Running   0          15m
kube-system   weave-net-9rnps                      2/2     Running   0          15m
kube-system   weave-net-v6hdl                      2/2     Running   0          11m
kube-system   weave-net-x5bdl                      2/2     Running   0          5m36s
```
