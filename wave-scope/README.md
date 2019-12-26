# weave-scope

```sh
# 安装
# kubectl apply -f "https://cloud.weave.works/k8s/scope.yaml?k8s-service-type=LoadBalancer&k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl apply -f "https://cloud.weave.works/k8s/scope.yaml?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# 访问
kubectl port-forward -n weave "$(kubectl get -n weave pod --selector=weave-scope-component=app -o jsonpath='{.items..metadata.name}')" 4040
```