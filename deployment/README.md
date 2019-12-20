# kubernetes-deployment

## 准备应用镜像

```sh
# 编译镜像
cd app.v1
docker build -t hello-node:v1 .

# 登录harbor
docker login 192.168.1.180:8008

# 添加镜像标签
docker tag hello-node:v1 192.168.1.180:8008/testprj/hello-node:v1

# 推送镜像
docker push 192.168.1.180:8008/testprj/hello-node:v1
```

## 各节点 docker 配置 http 白名单

```sh
# 添加文件
sudo vi /etc/docker/daemon.json
# {
#   "insecure-registries": ["192.168.1.180:8008"]
# }

# 重启docker
sudo systemctl restart docker
```

## 部署应用

```sh

# 创建部署
kubectl run hello-node --image=192.168.1.180:8008/testprj/hello-node:v1 --port=8080

# 查看部署
kubectl get deployments
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   1/1     1            1           19m

# 检查pod
kubectl get pods
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   1/1     1            1           74s

# 暴露服务
kubectl expose deployment hello-node --type=LoadBalancer

# 查看服务及IP
kubectl get services
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
hello-node   LoadBalancer   10.96.210.93   <pending>     8080:32508/TCP   8s
kubernetes   ClusterIP      10.96.0.1      <none>        443/TCP          23h

# 访问地址
http://192.168.50.10:32508/

# 查看日志
kubectl logs hello-node-6f68f7d975-mb27n

# 查看群集events：
kubectl get events
```

## 更新镜像

```sh
# 编译镜像
cd app.v2
docker build -t hello-node:v2 .

# 添加镜像标签
docker tag hello-node:v2 192.168.1.180:8008/testprj/hello-node:v2

# 推送镜像
docker push 192.168.1.180:8008/testprj/hello-node:v2
```

## 更新部署

```sh
kubectl set image deployment/hello-node hello-node=192.168.1.180:8008/testprj/hello-node:v2
```

## 清除应用

```sh
# 删除服务
kubectl delete service hello-node
# 删除部署
kubectl delete deployment hello-node
```
