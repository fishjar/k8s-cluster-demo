# ingress nginx

```sh
# https://kubernetes.github.io/ingress-nginx/deploy/baremetal/
# https://github.com/kubernetes/ingress-nginx/blob/master/docs/deploy/index.md
# https://github.com/kubernetes/ingress-nginx/blob/master/docs/deploy/baremetal.md
# https://stackoverflow.com/questions/49845021/getting-an-kubernetes-ingress-endpoint-ip-address
# https://qhh.me/2019/08/12/%E4%BD%BF%E7%94%A8-Kubernetes-Ingress-%E5%AF%B9%E5%A4%96%E6%9A%B4%E9%9C%B2%E6%9C%8D%E5%8A%A1/

# 安装
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
# Bare-metal
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/service-nodeport.yaml

# kubectl -n ingress-nginx patch deploy nginx-ingress-controller -p '{"spec":{"template":{"spec":{"dnsPolicy":"ClusterFirstWithHostNet","hostNetwork":true}}}}'
# kubectl -n ingress-nginx patch deploy nginx-ingress-controller -p '{"spec":{"template":{"spec":{"containers":[{"name":"nginx-ingress-controller","image":"registry.aliyuncs.com/google_containers/nginx-ingress-controller:0.26.1"}]}}}}'

# 部署测试应用
kubectl apply -f nginx.yaml

# 暴露服务
kubectl apply -f service-nginx.yaml

# 部署一个应用入口
kubectl apply -f ingress-nginx.yaml

# 测试
curl -D- http://192.168.50.10 -H 'Host: nginx.foo.org'
curl -D- http://192.168.50.11 -H 'Host: nginx.foo.org'
curl -D- http://192.168.50.12 -H 'Host: nginx.foo.org'

# 查看节点
kubectl get node
kubectl -n ingress-nginx get pod -o wide

# 查看入口
kubectl get ingress -o wide
kubectl describe ingress ingress-nginx
```
