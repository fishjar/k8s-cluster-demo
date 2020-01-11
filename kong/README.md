# kong

## 安装

```sh
# yaml 方式
kubectl apply -f all-in-one-dbless.yaml

# helm 方式
# 参考： https://github.com/helm/charts/tree/master/stable/kong
helm repo update # get the latest charts
helm install stable/kong
# 如果添加配置
echo "apiVersion: v1
kind: Namespace
metadata:
  name: kong
" | kubectl apply -f -
# helm install kong stable/kong --namespace kong --values kong-ingress-dbless.yaml
helm install kong stable/kong --namespace kong --values kong-values.yaml
```

### 一些操作

```sh
# 更新 ingress
kubectl patch ingress demo -p '{"metadata":{"annotations":{"configuration.konghq.com":"sample-customization"}}}'
ingress.extensions/demo patched

# 更新 service
kubectl patch service echo -p '{"metadata":{"annotations":{"configuration.konghq.com":"demo-customization"}}}'
service/echo patched
```

## 简单测试

```sh
kubectl apply -f nginx-test.yaml

kubectl get svc -n kong
NAME                      TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
kong-proxy                LoadBalancer   10.96.161.216   <pending>     80:30743/TCP,443:31201/TCP   33m
kong-validation-webhook   ClusterIP      10.96.149.254   <none>        443/TCP                      33m

curl http://10.96.161.216:80/foo
curl https://10.96.161.216:443/foo
```

## 插件

### ingress 插件

```sh
kubectl apply -f ingress-plugin-test.yaml

kubectl get svc -n kong
NAME                      TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
kong-proxy                LoadBalancer   10.96.161.216   <pending>     80:30743/TCP,443:31201/TCP   63m
kong-validation-webhook   ClusterIP      10.96.149.254   <none>        443/TCP                      63m

curl -i -H "Host: example.com" 10.96.161.216/bar
curl -i -H "Host: example.com" 10.96.161.216/bar/sample
```

### service 插件

```sh
kubectl apply -f service-plugin-test.yaml

kubectl get svc -n kong
NAME                      TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
kong-proxy                LoadBalancer   10.96.161.216   <pending>     80:30743/TCP,443:31201/TCP   63m
kong-validation-webhook   ClusterIP      10.96.149.254   <none>        443/TCP                      63m

curl -i -H "Host: example.com" 10.96.161.216/bar
curl -i -H "Host: example.com" 10.96.161.216/bar/sample
```

### global 插件

### specific consumer 插件

## 认证

```sh
# 部署一个测试服务
kubectl apply -f httpbin.yaml
```

### 简单访问

```sh
kubectl apply -f consumers-credentials-sample.yaml

curl -i 10.96.161.216/foo/status/200
HTTP/1.1 200 OK
```

### 添加 authentication 插件

```sh
kubectl apply -f consumers-credentials-authentication.yaml

curl -i 10.96.161.216/foo/status/200
HTTP/1.1 401 Unauthorized
{"message":"No API key found in request"}
```

### 使用 credential

```sh
kubectl apply -f consumers-credentials-authentication.yaml
kubectl apply -f consumers-credentials-secret.yaml

curl -i -H 'apikey: my-sooper-secret-key' 10.96.161.216/foo/status/200
HTTP/1.1 200 OK
```

## KongIngress

```sh
kubectl apply -f k8s-echo-server.yaml
```

### 简单访问

```sh
kubectl apply -f kongingress-demo.yaml

curl -i $PROXY_IP/foo
```

### Use KongIngress with Ingress resource

```sh
kubectl apply -f kongingress-ingress.yaml

curl -s $PROXY_IP/foo -X POST
{"message":"no Route matched with those values"}

# Kong will proxy only GET requests on /foo path and not strip away /foo
curl -s $PROXY_IP/foo
```

### Use KongIngress with Service resource

```sh
kubectl apply -f kongingress-service.yaml

# Real path received by the upstream service (echo) is now changed to /bar/foo
curl $PROXY_IP/foo
```

## kong + cert + metallb

```sh
# 部署
kubectl apply -f metallb.yaml
kubectl apply -f metallb-config.yaml
kubectl apply -f cert-manager.yaml
kubectl apply -f k8s-echo-server.yaml
kubectl apply -f kong-cert-metallb.yaml

# 访问测试
kubectl get ingress
NAME           HOSTS          ADDRESS          PORTS     AGE
echo-foo-org   echo.foo.org   192.168.50.200   80, 443   39m
curl echo.foo.org/foo/headers -I

# 强制使用 https
# redirect HTTP request to HTTPS
kubectl apply -f kong-cert-metallb-https-redirect.yaml
```

## Prometheus and Grafana

```sh
# 参考： https://github.com/Kong/kubernetes-ingress-controller/blob/master/docs/guides/prometheus-grafana.md

# 安装 metallb
kubectl apply -f metallb.yaml
# 配置 metallb
kubectl apply -f metallb-config.yaml

# 创建 namespace
kubectl apply -f namespace-monitoring.yaml
# 或者
echo "apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
" | kubectl apply -f -

# 安装 Prometheus
# helm install --name prometheus stable/prometheus --namespace monitoring --values https://bit.ly/2RgzDtg --version 8.4.1
helm install prometheus stable/prometheus --namespace monitoring --values prometheus-values.yaml
#####################
NOTES:
The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:
prometheus-server.monitoring.svc.cluster.local

Get the Prometheus server URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace monitoring port-forward $POD_NAME 9090

The Prometheus alertmanager can be accessed via port 80 on the following DNS name from within your cluster:
prometheus-alertmanager.monitoring.svc.cluster.local

Get the Alertmanager URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=prometheus,component=alertmanager" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace monitoring port-forward $POD_NAME 9093
######################

# 安装 Grafana
# 注意修改配置
# helm install stable/grafana --name grafana --namespace monitoring --values http://bit.ly/2FuFVfV --version 1.22.1
helm install grafana stable/grafana --namespace monitoring --values grafana-values.yaml
####################
NOTES:
1. Get your 'admin' user password by running:

   kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

2. The Grafana server can be accessed via port 80 on the following DNS name from within your cluster:
   grafana.monitoring.svc.cluster.local
   Get the Grafana URL to visit by running these commands in the same shell:

     export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=grafana,release=grafana" -o jsonpath="{.items[0].metadata.name}")
     kubectl --namespace monitoring port-forward $POD_NAME 3000

3. Login with the password from step 1 and the username: admin
################################


# 安装 Kong Ingress Controller
# helm install stable/kong --name kong --namespace kong --values https://bit.ly/2YDHyoh
helm install stable/kong --name kong --namespace kong --values kong-ingress-dbless.yaml

# 全局启用 Prometheus 插件
kubectl apply -f prometheus-plugin.yaml
# 或者
echo "apiVersion: configuration.konghq.com/v1
kind: KongPlugin
metadata:
  labels:
    global: \"true\"
  name: prometheus
plugin: prometheus
" | kubectl apply -f -

# 修改
kubectl edit svc/grafana -n monitoring
# 将
type: ClusterIP
# 修改为
type: LoadBalancer

# 查看访问地址
kubectl get svc -n monitoring
NAME                            TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
grafana                         LoadBalancer   10.96.72.87     192.168.50.201   80:31870/TCP   16m
prometheus-alertmanager         ClusterIP      10.96.25.132    <none>           80/TCP         18m
prometheus-kube-state-metrics   ClusterIP      None            <none>           80/TCP         18m
prometheus-node-exporter        ClusterIP      None            <none>           9100/TCP       18m
prometheus-pushgateway          ClusterIP      10.96.79.181    <none>           9091/TCP       18m
prometheus-server               ClusterIP      10.96.107.203   <none>           80/TCP         18m

# 访问
# 浏览器打开
192.168.50.201

# 登录
# 帐号：admin
# 获取密码
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# 测试
# 部署测试服务
kubectl apply -f multiple-services.yaml
kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
billing      NodePort    10.96.62.189    <none>        80:31298/TCP   17m
comments     NodePort    10.96.243.197   <none>        80:32348/TCP   17m
invoice      NodePort    10.96.252.197   <none>        80:30872/TCP   17m
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP        6d1h

# 添加ingress
kubectl apply -f multiple-services-ingress.yaml

# 测试请求
while true;
do
  curl http://192.168.50.200/billing/status/200
  curl http://192.168.50.200/billing/status/501
  curl http://192.168.50.200/invoice/status/201
  curl http://192.168.50.200/invoice/status/404
  curl http://192.168.50.200/comments/status/200
  curl http://192.168.50.200/comments/status/200
  sleep 0.01
done


##########################################################
### 启用 persistence / persistentVolume 时，遇到问题待解决 ###
kubectl get po -n monitoring
NAME                                             READY   STATUS    RESTARTS   AGE
grafana-7df5f4564-2wgqf                          0/1     Pending   0          22h
prometheus-alertmanager-779c54c8b7-hmjbx         0/2     Pending   0          22h
prometheus-kube-state-metrics-7995648b78-n554n   1/1     Running   0          22h
prometheus-node-exporter-zmxlq                   1/1     Running   0          22h
prometheus-pushgateway-84884f6dcb-g4nxv          1/1     Running   0          22h
prometheus-server-76b7cf695-flbxg                0/2     Pending   0          22h

kubectl describe pod grafana-7df5f4564-2wgqf -n monitoring
error while running "VolumeBinding" filter plugin for pod "grafana-7df5f4564-2wgqf": pod has unbound immediate PersistentVolumeClaims

kubectl describe pod grafana-7df5f4564-2wgqf -n monitoring
error while running "VolumeBinding" filter plugin for pod "prometheus-alertmanager-779c54c8b7-hmjbx": pod has unbound immediate PersistentVolumeClaims

kubectl describe pod prometheus-server-76b7cf695-flbxg -n monitoring
error while running "VolumeBinding" filter plugin for pod "prometheus-server-76b7cf695-flbxg": pod has unbound immediate PersistentVolumeClaims
```

## konga

```sh
# 安装 metallb
kubectl apply -f metallb.yaml
kubectl apply -f metallb-config.yaml

# 添加 namespace
echo "apiVersion: v1
kind: Namespace
metadata:
  name: kong
" | kubectl apply -f -

# 安装 kong
# kong内置了 konga？貌似可以通过配置直接安装 konga
# helm install kong stable/kong --namespace kong --values kong-ingress-dbless.yaml
helm install kong stable/kong --namespace kong --values kong-values.yaml

NAME: kong
LAST DEPLOYED: Sat Jan 11 06:47:50 2020
NAMESPACE: kong
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
To connect to Kong, please execute the following command
  HOST=$(kubectl get svc --namespace kong kong-kong-proxy -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  PORT=$(kubectl get svc --namespace kong kong-kong-proxy -o jsonpath='{.spec.ports[0].port}')export PROXY_IP=${HOST}:${PORT}
curl $PROXY_IP

Once installed, please follow along the getting started guide to start using Kong:
https://bit.ly/k4k8s-get-started

# 安装 konga + ingress
kubectl apply -f konga.yaml

# helm 方式
# 参考：https://github.com/pantsel/konga/tree/master/charts/konga
# （略）

# 查看
kubectl get svc -n kong
NAME              TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                      AGE
kong-kong-admin   NodePort       10.96.195.220   <none>           8444:30428/TCP               41m
kong-kong-proxy   LoadBalancer   10.96.210.86    192.168.50.200   80:30381/TCP,443:30290/TCP   41m
konga             ClusterIP      10.96.216.11    <none>           80/TCP                       80s

kubectl get ingress -n kong
NAME              HOSTS            ADDRESS          PORTS   AGE
kong-kong-admin   admin.kong.org   192.168.50.200   80      7m15s
kong-kong-proxy   proxy.kong.org   192.168.50.200   80      7m15s
konga-ingress     konga.kong.org   192.168.50.200   80      4m49s

# 浏览器打开 konga.kong.org
# 注册帐号 admin/admin123
# 登陆后填写
# name： （随便填）
# kong admin url：http://admin.kong.org
```
