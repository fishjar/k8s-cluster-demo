# service

## 访问一个服务

### `hostNet` 方式

```sh
kubectl apply -f nginx-hostnet.yaml

kubectl get po -o wide
NAME                     READY   STATUS              RESTARTS   AGE   IP              NODE   NOMINATED NODE   READINESS GATES
nginx-8487556bdc-4fkdc   0/1     ContainerCreating   0          27s   192.168.50.12   k8s2   <none>           <none>
nginx-8487556bdc-cphr5   1/1     Running             0          27s   192.168.50.11   k8s1   <none>           <none>

curl 192.168.50.11
```

```yaml
# nginx-hostnet.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      # dnsPolicy: ClusterFirstWithHostNet
      hostNetwork: true # 重点
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
    - port: 80
      protocol: TCP
  selector:
    app: nginx
```

### `nodeport` 方式

```sh
kubectl apply -f nginx-nodeport.yaml

kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP        86m
nginx        NodePort    10.96.193.112   <none>        80:32532/TCP   26s

curl 192.168.50.10:32532
curl 192.168.50.11:32532
curl 192.168.50.12:32532
```

```yaml
# nginx-nodeport.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  type: NodePort # 重点
  ports:
    - port: 80
      protocol: TCP
  selector:
    app: nginx
```

### `metallb` 方式

```sh
kubectl apply -f metallb.yaml
kubectl apply -f nginx-metallb.yaml

kubectl get svc
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)        AGE
kubernetes   ClusterIP      10.96.0.1      <none>           443/TCP        25m
nginx        LoadBalancer   10.96.32.144   192.168.50.200   80:31689/TCP   26s

curl 192.168.50.200
```

```yaml
# nginx-metallb.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.50.200-192.168.50.210
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  type: LoadBalancer # 重点
  ports:
    - port: 80
      protocol: TCP
  selector:
    app: nginx
```

### `ingress` + `nodeport` 方式

```sh
kubectl apply -f mandatory.yaml
kubectl apply -f nginx-ingress-nodeport.yaml

kubectl get svc
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP                                 PORT(S)                      AGE
ingress-nginx   LoadBalancer   10.96.54.230    192.168.50.10,192.168.50.11,192.168.50.12   80:30701/TCP,443:31398/TCP   8s
kubernetes      ClusterIP      10.96.0.1       <none>                                      443/TCP                      61m
nginx           ClusterIP      10.96.125.130   <none>                                      80/TCP                       8s

curl -D- http://192.168.50.10 -H 'Host: nginx.foo.org'
curl -D- http://192.168.50.11 -H 'Host: nginx.foo.org'
curl -D- http://192.168.50.12 -H 'Host: nginx.foo.org'
```

```yaml
# nginx-ingress.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  ports:
    - port: 80
      protocol: TCP
  selector:
    app: nginx
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: ingress-nginx
spec:
  rules:
    - host: nginx.foo.org
      http:
        paths:
          - path: /
            backend:
              serviceName: nginx
              servicePort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
spec:
  # 以下两个参数用于 type: NodePort 或 type: LoadBalancer
  externalTrafficPolicy: Local
  externalIPs:
    - 192.168.50.10
    - 192.168.50.11
    - 192.168.50.12
  type: NodePort
  # 或者
  # type: LoadBalancer
  ports:
    - name: http
      port: 80
      targetPort: 80
      protocol: TCP
    - name: https
      port: 443
      targetPort: 443
      protocol: TCP
  selector:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
```

### `ingress` + `metallb` 方式

```sh
kubectl apply -f mandatory.yaml
kubectl apply -f metallb.yaml
kubectl apply -f nginx-ingress-metallb.yaml

kubectl get svc
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP                                 PORT(S)                      AGE
ingress-nginx   LoadBalancer   10.96.54.230    192.168.50.10,192.168.50.11,192.168.50.12   80:30701/TCP,443:31398/TCP   8s
kubernetes      ClusterIP      10.96.0.1       <none>                                      443/TCP                      61m
nginx           ClusterIP      10.96.125.130   <none>                                      80/TCP                       8s

curl -D- http://192.168.50.200 -H 'Host: nginx.foo.org'
curl -D- http://192.168.50.10 -H 'Host: nginx.foo.org'
curl -D- http://192.168.50.11 -H 'Host: nginx.foo.org'
curl -D- http://192.168.50.12 -H 'Host: nginx.foo.org'
```

```yaml
# nginx-ingress-metallb.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.50.200-192.168.50.210
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  type: LoadBalancer
  ports:
    - port: 80
      protocol: TCP
  selector:
    app: nginx
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: ingress-nginx
  annotations:
    # use the shared ingress-nginx
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
    - host: nginx.foo.org
      http:
        paths:
          - path: /
            backend:
              serviceName: nginx
              servicePort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: ingress-nginx
spec:
  type: LoadBalancer
  selector:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
spec:
  type: LoadBalancer
  ports:
    - name: http
      port: 80
      targetPort: 80
      protocol: TCP
    - name: https
      port: 443
      targetPort: 443
      protocol: TCP
  selector:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
```
