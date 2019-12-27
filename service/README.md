# service

## 访问一个服务

### `hostNet` 方式

```sh
# 部署
# 重点设置：hostNetwork: true
kubectl apply -f nginx-hostnet.yaml

# 查看IP
kubectl get po -o wide
NAME                     READY   STATUS              RESTARTS   AGE   IP              NODE   NOMINATED NODE   READINESS GATES
nginx-8487556bdc-4fkdc   0/1     ContainerCreating   0          27s   192.168.50.12   k8s2   <none>           <none>
nginx-8487556bdc-cphr5   1/1     Running             0          27s   192.168.50.11   k8s1   <none>           <none>

# 访问
curl 192.168.50.11
```

### `nodeport` 方式

```sh
# 部署
# 重点设置：type: NodePort
kubectl apply -f nginx-nodeport.yaml

# 查看端口
kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP        86m
nginx        NodePort    10.96.193.112   <none>        80:32532/TCP   26s

# 访问
curl 192.168.50.10:32532
curl 192.168.50.11:32532
curl 192.168.50.12:32532

# 如果已添加 externalTrafficPolicy、externalIPs 参数
kubectl get svc
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP                                 PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1      <none>                                      443/TCP        17h
nginx        NodePort    10.96.196.21   192.168.50.10,192.168.50.11,192.168.50.12   80:31150/TCP   3m27s
# 访问
curl 192.168.50.10
curl 192.168.50.11
curl 192.168.50.12
```

### `metallb` 方式

```sh
# 部署
# 重点设置：type: LoadBalancer
kubectl apply -f metallb.yaml
kubectl apply -f nginx-metallb.yaml

# 查看IP
kubectl get svc
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)        AGE
kubernetes   ClusterIP      10.96.0.1      <none>           443/TCP        25m
nginx        LoadBalancer   10.96.32.144   192.168.50.200   80:31689/TCP   26s

# 访问
curl 192.168.50.200
```

### `ingress` + `nodeport` 方式

```sh
# 部署
# 重点设置：
# namespace: ingress-nginx
# type: NodePort
kubectl apply -f mandatory.yaml
kubectl apply -f nginx-ingress-nodeport.yaml

# 查看端口
kubectl get svc -n ingress-nginx
NAME            TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
ingress-nginx   NodePort   10.96.131.176   <none>        80:30739/TCP   2m48s
# 访问
curl -D- http://192.168.50.10:30739 -H 'Host: nginx.foo.org'
curl -D- http://192.168.50.11:30739 -H 'Host: nginx.foo.org'
curl -D- http://192.168.50.12:30739 -H 'Host: nginx.foo.org'

# 或者查看ingress的IP
kubectl get ingress
NAME            HOSTS           ADDRESS         PORTS   AGE
ingress-nginx   nginx.foo.org   10.96.131.176   80      3m35s
# 访问
curl -D- http://10.96.131.176 -H 'Host: nginx.foo.org'

# 如果已添加 externalTrafficPolicy、externalIPs 参数
kubectl get svc -n ingress-nginx
NAME            TYPE       CLUSTER-IP      EXTERNAL-IP                                 PORT(S)        AGE
ingress-nginx   NodePort   10.96.131.176   192.168.50.10,192.168.50.11,192.168.50.12   80:30739/TCP   6m5s
# 访问
curl -D- http://192.168.50.10 -H 'Host: nginx.foo.org'
curl -D- http://192.168.50.11 -H 'Host: nginx.foo.org'
curl -D- http://192.168.50.12 -H 'Host: nginx.foo.org'
```

### `ingress` + `metallb` 方式

```sh
# 部署
# 重要设置：nginx-ingress-controller
# type: LoadBalancer
kubectl apply -f mandatory.yaml
kubectl apply -f metallb.yaml
kubectl apply -f nginx-ingress-metallb.yaml

# 查看服务
kubectl get svc -A
NAMESPACE       NAME            TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                  AGE
default         kubernetes      ClusterIP      10.96.0.1       <none>           443/TCP                  25h
default         nginx           ClusterIP      10.96.28.147    <none>           80/TCP                   117s
ingress-nginx   ingress-nginx   LoadBalancer   10.96.252.168   192.168.50.200   80:31569/TCP             117s
kube-system     kube-dns        ClusterIP      10.96.0.10      <none>           53/UDP,53/TCP,9153/TCP   25h

# 查看ingress
kubectl get ingress
NAME    HOSTS           ADDRESS          PORTS   AGE
nginx   nginx.foo.org   192.168.50.200   80      86s

# 访问
curl -D- http://192.168.50.200 -H 'Host: nginx.foo.org'
```

### `ingress` + `metallb` + `cert` 方式

```sh
# 创建命名空间
kubectl create namespace cert-manager

# 部署
kubectl apply -f mandatory.yaml
kubectl apply -f metallb.yaml
kubectl apply -f cert-manager.yaml
kubectl apply -f nginx-ingress-metallb-cert.yaml

# 查看ingress
kubectl get ingress
NAME    HOSTS           ADDRESS          PORTS     AGE
nginx   nginx.foo.org   192.168.50.200   80, 443   6m50s

# 访问
curl https://nginx.foo.org/
```
