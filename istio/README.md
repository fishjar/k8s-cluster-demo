# istio

## 安装

- `install/kubernetes` 目录下，有 Kubernetes 相关的 YAML 安装文件
- `samples/` 目录下，有示例应用程序
- `bin/` 目录下，包含 istioctl 的客户端文件。istioctl 工具用于手动注入 Envoy sidecar 代理。

```sh
# 参考：https://preliminary.istio.io/zh/docs/setup/getting-started/

# 下载
curl -L https://istio.io/downloadIstio | sh -
cd istio-1.5.0
export PATH=$PWD/bin:$PATH

# 安装 demo 配置
istioctl manifest apply --set profile=demo

# 验证
# 验证除 jaeger-agent 服务外的其他服务，是否均有正确的 CLUSTER-IP：
# 如果集群运行在一个不支持外部负载均衡器的环境中（例如：minikube），
# istio-ingressgateway 的 EXTERNAL-IP 将显示为 <pending> 状态。
# 请使用服务的 NodePort 或 端口转发来访问网关。
kubectl get svc -n istio-system

# 请确保关联的 Kubernetes pod 已经部署，并且 STATUS 为 Running：
kubectl get pods -n istio-system


# 当使用 kubectl apply 来部署应用时，
# 如果 pod 启动在标有 istio-injection=enabled 的命名空间中，
# 那么，Istio sidecar 注入器 将自动注入 Envoy 容器到应用的 pod 中：
kubectl label namespace <namespace> istio-injection=enabled
kubectl create -n <namespace> -f <your-app-spec>.yaml

# 在没有 istio-injection 标记的命名空间中，
# 在部署前可以使用 istioctl kube-inject 命令将 Envoy 容器手动注入到应用的 pod 中
istioctl kube-inject -f <your-app-spec>.yaml | kubectl apply -f -

# 卸载
istioctl manifest generate --set profile=demo | kubectl delete -f -
```

## 应用

```sh
# 参考： https://preliminary.istio.io/zh/docs/examples/bookinfo/

# Istio 默认自动注入 Sidecar.
# 请为 default 命名空间打上标签 istio-injection=enabled：
kubectl label namespace default istio-injection=enabled

# 部署应用
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml

# 确认所有的服务和 Pod 都已经正确的定义和启动
kubectl get services
kubectl get pods

# 要确认 Bookinfo 应用是否正在运行，
# 请在某个 Pod 中用 curl 命令对应用发送请求，例如 ratings
kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>"


# 定义 Ingress 网关
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

# 确认网关创建完成
kubectl get gateway

# 设置访问网关的 INGRESS_HOST 和 INGRESS_PORT 变量
# 参考：https://preliminary.istio.io/zh/docs/tasks/traffic-management/ingress/ingress-control/#determining-the-ingress-i-p-and-ports
# 使用了外部负载均衡器
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
# node port 访问
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')


# 设置 GATEWAY_URL
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
# 查看地址
echo $GATEWAY_URL

# 访问
# 还可以用浏览器打开网址 http://$GATEWAY_URL/productpage，来浏览应用的 Web 页面
# http://192.168.50.200/productpage
curl -s http://${GATEWAY_URL}/productpage | grep -o "<title>.*</title>"


# 应用默认目标规则（没有启用双向 TLS）
kubectl apply -f samples/bookinfo/networking/destination-rule-all.yaml

# 使用以下命令查看目标规则
kubectl get destinationrules -o yaml


# 清理
samples/bookinfo/platform/kube/cleanup.sh
# 确认应用已经关停
kubectl get virtualservices   #-- there should be no virtual services
kubectl get destinationrules  #-- there should be no destination rules
kubectl get gateway           #-- there should be no gateway
kubectl get pods              #-- the Bookinfo pods should be deleted
```

## sidecar

### 手工注入

```sh
# 默认情况下将使用集群内的配置
istioctl kube-inject -f samples/sleep/sleep.yaml | kubectl apply -f -

# 导出配置的本地副本
kubectl -n istio-system get configmap istio-sidecar-injector -o=jsonpath='{.data.config}' > inject-config.yaml
kubectl -n istio-system get configmap istio-sidecar-injector -o=jsonpath='{.data.values}' > inject-values.yaml
kubectl -n istio-system get configmap istio -o=jsonpath='{.data.mesh}' > mesh-config.yaml

# 使用本地配置
istioctl kube-inject \
    --injectConfigFile inject-config.yaml \
    --meshConfigFile mesh-config.yaml \
    --valuesFile inject-values.yaml \
    --filename samples/sleep/sleep.yaml \
    | kubectl apply -f -

# 验证
kubectl get pod  -l app=sleep
NAME                     READY   STATUS    RESTARTS   AGE
sleep-64c6f57bc8-f5n4x   2/2     Running   0          24s
```

### 自动注入

当 `Kubernetes` 调用 `webhook` 时， `admissionregistration` 配置被应用。
默认配置将 `sidecar` 注入到所有拥有 `istio-injection=enabled` 标签的 `namespace` 下的 `pod` 中。

```sh
# 部署 sleep 应用
kubectl apply -f samples/sleep/sleep.yaml
kubectl get deployment -o wide

# 将 default namespace 标记为 istio-injection=enabled
# 启用自动注入
kubectl label namespace default istio-injection=enabled
kubectl get namespace -L istio-injection
NAME           STATUS    AGE       ISTIO-INJECTION
default        Active    1h        enabled
istio-system   Active    1h
kube-public    Active    1h
kube-system    Active    1h

# 验证新创建的 pod 是否注入 sidecar
kubectl delete pod -l app=sleep
kubectl get pod -l app=sleep
NAME                     READY     STATUS        RESTARTS   AGE
sleep-776b7bcdcd-7hpnk   1/1       Terminating   0          1m
sleep-776b7bcdcd-bhn9m   2/2       Running       0          7s

# 查看已注入 pod 的详细状态
kubectl describe pod -l app=sleep

# 禁用 default namespace 注入
kubectl label namespace default istio-injection-

# 确认新的 pod 在创建时没有 sidecar
kubectl delete pod -l app=sleep
kubectl get pod
NAME                     READY     STATUS        RESTARTS   AGE
sleep-776b7bcdcd-bhn9m   2/2       Terminating   0          2m
sleep-776b7bcdcd-gmvnr   1/1       Running       0          2s

# 卸载 sidecar 自动注入器
kubectl delete mutatingwebhookconfiguration istio-sidecar-injector
kubectl -n istio-system delete service istio-sidecar-injector
kubectl -n istio-system delete deployment istio-sidecar-injector
kubectl -n istio-system delete serviceaccount istio-sidecar-injector-service-account
kubectl delete clusterrole istio-sidecar-injector-istio-system
kubectl delete clusterrolebinding istio-sidecar-injector-admin-role-binding-istio-system

# 清理在此任务中修改过的其他资源
kubectl label namespace default istio-injection-
```

```yaml
# 使用 sidecar.istio.io/inject 注解来禁用 sidecar 注入
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ignored
spec:
  template:
    metadata:
      annotations:
        sidecar.istio.io/inject: "false"
    spec:
      containers:
        - name: ignored
          image: tutum/curl
          command: ["/bin/sleep", "infinity"]
```
