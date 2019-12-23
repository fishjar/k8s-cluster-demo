# metellb

```sh
# 安装
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.3/manifests/metallb.yaml

# 配置
kubectl apply -f config-layer.yaml

# 部署测试应用
kubectl apply -f nginx.yaml

# 暴露服务
kubectl apply -f service-nginx.yaml

# 查看分配的IP
kubectl get service
NAMESPACE       NAME            TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE
default         nginx           LoadBalancer   10.96.183.36   192.168.50.200   80:30855/TCP                 23h

# 访问测试
curl 192.168.50.200
```
