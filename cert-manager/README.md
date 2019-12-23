# cert manager

```sh
# https://cert-manager.io/docs/installation/kubernetes/

# 创建命名空间
kubectl create namespace cert-manager

# 安装
# If you are running Kubernetes v1.15 or below, you will need to add the --validate=false flag
# kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.12.0/cert-manager.yaml
kubectl apply -f cert-manager.yaml

# 确认
kubectl get pods --namespace cert-manager

# 测试
cat <<EOF > test-resources.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: cert-manager-test
---
apiVersion: cert-manager.io/v1alpha2
kind: Issuer
metadata:
  name: test-selfsigned
  namespace: cert-manager-test
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: selfsigned-cert
  namespace: cert-manager-test
spec:
  commonName: example.com
  secretName: selfsigned-cert-tls
  issuerRef:
    name: test-selfsigned
EOF
# 部署
kubectl apply -f test-resources.yaml
# 查看证书
kubectl describe certificate -n cert-manager-test
# 清除
kubectl delete -f test-resources.yaml
```