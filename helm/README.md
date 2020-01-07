# helm

## 安装

```sh
# 确认集群信息
kubectl config current-context

# From Snap (Linux)
sudo snap install helm --classic

# add a chart repository
# helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo add stable http://mirror.azure.cn/kubernetes/charts/
helm search repo stable

# install a chart
helm repo update 
helm install stable/mysql --generate-name

helm ls
NAME            	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART      	APP VERSION
mysql-1578380091	default  	1       	2020-01-07 06:55:04.513681593 +0000 UTC	deployed	mysql-1.6.2	5.7.28

# 卸载
helm uninstall mysql-1578380091
```
