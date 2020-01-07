# ambassador

```sh
# 确认是否启用 RBAC
kubectl cluster-info dump --namespace kube-system | grep authorization-mode

# 部署
kubectl apply -f ambassador-rbac.yaml

# 暴露 Ambassador Service
# 注意修改配置
kubectl apply -f ambassador-service.yaml

# 测试
kubectl apply -f tour.yaml

# NodePort 方式
kubectl get svc -o wide ambassador
NAME         TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE   SELECTOR
ambassador   NodePort   10.96.223.254   <none>        80:31798/TCP   21m   service=ambassador
# 访问
curl http://192.168.50.10:31798/
curl http://192.168.50.10:31798/backend/

# 端口转发 方式
kubectl port-forward --address 0.0.0.0 service/ambassador 8080:80
# 访问
curl http://192.168.50.10:8080/
curl http://192.168.50.10:8080/backend/
```