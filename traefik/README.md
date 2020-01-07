# traefik

## docker 环境

(略)

## k8s 环境

### 安装

```sh
# 安装 helm （略）

# 下载 helm chart
wget https://github.com/containous/traefik-helm-chart/archive/master.zip
unzip master.zip

# 安装 traefik
helm install ./traefik-helm-chart-master --generate-name
```

### 配置

k8s

```sh
# 部署
kubectl apply -f definitions.yaml
kubectl apply -f services.yaml
kubectl apply -f deployments.yaml

# 访问
# 端口转发
kubectl port-forward --address 0.0.0.0 service/traefik 8000:8000 8080:8080 443:4443 -n default

# 路由
kubectl apply -f ingressroutes.yaml
kubectl get IngressRoute

# 测试
curl [-k] https://your.domain.com/tls
curl [-k] http://your.domain.com:8000/notls
```