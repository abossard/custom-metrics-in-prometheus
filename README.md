# Igredients for a Prometheus Kube Stack Setup

1. Services that expose prometheus compatible metrics
2. ServiceMonitor that collects metrics from the services
3. Prometheus manifest that refers to the service monitors

## Overview of Kubernetes Resource to enable metrics collection
![Kubernetes Resources for Metrics Collection](./imgs/overview.drawio.svg)

# Setup instruction
## 1. Have a nice and fresh Kubernetes cluster
   Docker Desktop, AKS, or any cluster should work fine
## 2. Configure the local Helm Repositories:
    
    ```
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    ```

### 3. Think about to which namespace you want to deploy Prometheus and Grafana and deploy it there

    ```
    N=monitoring
    kubectl create namespace $N
    helm upgrade -n $N --install prometheus prometheus-community/kube-prometheus-stack
    helm upgrade -n $N --install loki grafana/loki-stack
    ```

    Now it'll take a while until Prometheus and Grafana are ready to use.

### 4. Setup the services that expose metrics
Prometheus can collect metrics from your application. For that you need to create a ServiceMonitor, that targets the services that
expose metrics. If you don't have services, but only Pods, you can create a PodMonitor.
Add a label to your services and pods (e.g. monitoring=true) and use that as selector in the Service/PodMonitor.

* check out [./manifests/webapi.yaml](./manifests/webapi.yaml)
  
On top of that, you need to tell Prometheus to use your Service/PodMonitor by creating a Prometheus Resource with serviceMonitorSelector that matches your monitors.

* check out [./manifests/monitor.yaml](./manifests/monitor.yaml)

### 5. Implement your metrics

There are two examples provided:
* [ASP.NET WebAPI](./webapi)
* [Function App](./hello-func)

### 6. Container Logs with Promtail and Loki

As part of the loki-stack, promtail is installed. It discovers log sources and sends them to Loki.

* [Promtail Docs](https://grafana.com/docs/loki/latest/clients/promtail/)

Promtail is a daemon and runs once per machine and also only discovers logs on the machines it runs.

Check the `loki-promtail` ConfigMap to see the default configuration. With it, it already ships all containerlogs to Loki.

### 7. Custom Logging to Loki
It's possible to use customer libraries to send logs to Loki. See the example in:

* [ASP.NET WebAPI](./webapi)

