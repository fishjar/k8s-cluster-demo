# ingress nginx

- `Bare-metal considerations`
- `Role Based Access Control (RBAC)`
- `Validating webhook (admission controller)`

```sh
# https://kubernetes.github.io/ingress-nginx
# https://github.com/kubernetes/ingress-nginx/blob/master/docs/deploy/index.md
# https://github.com/kubernetes/ingress-nginx/blob/master/docs/deploy/baremetal.md
# https://stackoverflow.com/questions/49845021/getting-an-kubernetes-ingress-endpoint-ip-address
# https://qhh.me/2019/08/12/%E4%BD%BF%E7%94%A8-Kubernetes-Ingress-%E5%AF%B9%E5%A4%96%E6%9A%B4%E9%9C%B2%E6%9C%8D%E5%8A%A1/

# 安装 （注意修改Deployment配置，尤其host network方式）
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml

# 入口服务（注意修改配置，尤其NodePort方式）
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/service-nodeport.yaml

# 更新参数（host network方式）
# kubectl -n ingress-nginx patch deploy nginx-ingress-controller -p '{"spec":{"template":{"spec":{"dnsPolicy":"ClusterFirstWithHostNet","hostNetwork":true}}}}'

# 部署测试应用
kubectl apply -f nginx.yaml

# 暴露服务
kubectl apply -f service-nginx.yaml

# 部署一个应用入口（注意修改配置，尤其metalb方式）
kubectl apply -f ingress-nginx.yaml

# Bare-metal considerations 裸机访问入口的几种方式
# https://kubernetes.github.io/ingress-nginx/deploy/baremetal/
- MetalLB
- Over a NodePort Service
- Via the host network
- Using a self-provisioned edge

# 查看服务
kubectl -n ingress-nginx get svc
# metallb的情况
NAME            TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE
ingress-nginx   LoadBalancer   10.96.128.63   192.168.50.200   80:30804/TCP,443:31319/TCP   128m

# 查看节点
kubectl -n ingress-nginx get pod -o wide

# 查看入口
kubectl get ingress -o wide
kubectl describe ingress ingress-nginx

# 测试
# 使用metellb
curl -D- http://192.168.50.200 -H 'Host: nginx.foo.org'
# 使用NodePort
curl -D- http://192.168.50.10 -H 'Host: nginx.foo.org'
curl -D- http://192.168.50.11 -H 'Host: nginx.foo.org'
curl -D- http://192.168.50.12 -H 'Host: nginx.foo.org'
# host network方式(IP是某个工作节点的IP)
curl -D- http://192.168.50.12:30804 -H 'Host: nginx.foo.org'
```
