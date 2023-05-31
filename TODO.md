# Pre-requisites

kind create cluster --config kind.yaml

# 0. install prometheus 
helm upgrade --install prometheus kube-prometheus-stack/kube-prometheus-stack

# 0. install minio(locally)

kubectl create namespace minio-tenant-1
kubectl krew update
kubectl krew install minio
kubectl minio init
kubectl get pods -n minio-operator

kubectl minio proxy -n minio-operator
# connect open a browser and go to http://localhost:9090

Note: alternative is using [kube2iam](https://github.com/jtblin/kube2iam) and creating a secret with credentials

# 1. install loki
helm repo add grafana https://grafana.github.io/helm-charts

helm upgrade --install --values loki.yaml loki grafana/loki

iam service account for loki accessing S3 buckets

# 2. install grafana tempo
    
To set up Tempo, you need to:

2.1 Plan your deployment
    monolithic or microservices modes

2.2 Deploy Tempo
helm upgrade --install --values tempo.yaml tempo grafana/tempo
iam service account for tempo accessing S3 buckets

2.3 Setup Grafana Agent to collect traces
helm upgrade --install --values grafana-agent.yaml grafana-agent grafana/grafana-agent
kubectl apply -f grafana/grafana-agent.yaml

2.4 Create a Grafana Tempo data source
https://grafana.com/docs/tempo/latest/setup/set-up-test-app/#create-a-grafana-tempo-data-source

# 3. create a demo in grafana

```sh
 kubectl logs $(kubectl get pod -l name=app -o jsonpath="{.items[0].metadata.name}")

 level=debug traceID=50075ac8b434e8f7 msg="GET / (200) 1.950625ms"
 level=info msg="HTTP client success" status=200 url=http://db duration=1.297806ms traceID=2c2fd669c388e76
 level=debug traceID=2c2fd669c388e76 msg="GET / (200) 1.70755ms"
 level=info msg="HTTP client success" status=200 url=http://db duration=1.853271ms traceID=79058bb9cc39acfb
 level=debug traceID=79058bb9cc39acfb msg="GET / (200) 2.300922ms"
 level=info msg="HTTP client success" status=200 url=http://db duration=1.381894ms traceID=7b0e0526f5958549
 level=debug traceID=7b0e0526f5958549 msg="GET / (200) 2.105263ms"
```

3.1 Go to Grafana and select the Explore menu item.

3.2 Select the Tempo data source from the list of data sources.

3.3 Copy the trace ID into the Trace ID edit field.

3.4 Select Run query.

Confirm that the trace is displayed in the traces Explore panel.

# 4. Exemplars

Prometheus exemplars let you jump from Prometheus metrics to Tempo traces by clicking on recorded exemplars.
https://grafana.com/blog/2021/03/31/intro-to-exemplars-which-enable-grafana-tempos-distributed-tracing-at-massive-scale/

