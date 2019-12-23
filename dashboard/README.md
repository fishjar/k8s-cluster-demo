# kubernetes-dashboard

## 准备

```sh
# 手工下载文件
https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
# 找到
image: k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1
# 修改为
image: registry.aliyuncs.com/google_containers/kubernetes-dashboard-amd64:v1.10.1
# 保存至master节点
```

## 部署

```sh
# 快速部署
# https://github.com/kubernetes/dashboard
kubectl apply -f kubernetes-dashboard.yaml
# 获取token
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep kubernetes-dashboard | awk '{print $1}')
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep kubernetes-dashboard | awk '{print $1}')

# 推荐方式（需要证书）
# https://github.com/kubernetes/dashboard/blob/master/docs/user/installation.md
kubectl apply -f recommended.yaml

# 替代方式
# 只能通过 Authorization Header 方式访问
kubectl apply -f alternative.yaml
```

## 本机访问

```sh
# 本机访问
# 适用快速部署方式
# 参考：https://github.com/kubernetes/dashboard/blob/master/docs/user/accessing-dashboard/1.7.x-and-above.md
# NOTE: Dashboard should not be exposed publicly using kubectl proxy command as it only allows HTTP connection.
# For domains other than localhost and 127.0.0.1 it will not be possible to sign in.
# Nothing will happen after clicking Sign in button on login page.
# 使用 --address 和 --accept-hosts 参数来允许外部访问
kubectl proxy --address='0.0.0.0'  --accept-hosts='^*$'
# 访问地址
http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```

## 外部访问

### NodePort 方式

```sh
kubectl -n kubernetes-dashboard edit service kubernetes-dashboard
# 找到
type: ClusterIP
# 修改为
type: NodePort
# 查看端口
kubectl -n kubernetes-dashboard get service kubernetes-dashboard
NAME                   TYPE       CLUSTER-IP   EXTERNAL-IP   PORT(S)         AGE
kubernetes-dashboard   NodePort   10.96.24.4   <none>        443:30393/TCP   3m8s
# 访问地址
https://192.168.50.10:30393/
```

### API Server

### ingress

```sh
# 安装
kubectl apply -f recommended.yaml

# 修改service,使用metallb
kubectl apply -f service-dashboard.yaml

# 创建issuer 及 cert
kubectl apply -f cert-dashboard.yaml

# 创建ingress
kubectl apply -f ingress-dashboard.yaml
```

## 创建用户

```sh
# 添加用户
kubectl apply -f dashboard-adminuser.yaml

# 获取token
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
```

## 删除

```sh
kubectl -n kubernetes-dashboard delete $(kubectl -n kubernetes-dashboard get pod -o name | grep dashboard)
```
