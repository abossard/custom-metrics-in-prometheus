#SETUP
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts

helm repo update
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack -f values.yaml
helm upgrade --install loki grafana/loki-stack

mkdir hello-func
cd hello-func
func init --docker --csharp


#CONFIG LOCAL
POD=$(kubectl get pod -n default -l app.kubernetes.io/name=grafana -o jsonpath='{.items[0].metadata.name}')
ACR=anbossar
echo $POD
kubectl port-forward -n prometheus $POD 3000
echo Login to Grafana with admin / prom-operator
echo https://localhost:3000

#TEST BUILD function app
cd hello-func
func start
docker build -t anbossar.azurecr.io/prom-func-app:latest .
docker buildx build --platform linux/amd64 -t anbossar.azurecr.io/prom-func-app:latest --push .
az acr build --registry $ACR --image prom-func-app:latest .

az acr login -n $ACR
az acr update --name anbossar --anonymous-pull-enabled

cd webapi
docker build -t anbossar.azurecr.io/prom-webapi:latest .
docker buildx build --platform linux/amd64 -t anbossar.azurecr.io/prom-webapi:latest --push .
az acr build --registry $ACR --image prom-webapi:latest .