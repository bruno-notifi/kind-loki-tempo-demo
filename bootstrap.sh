kind create cluster --config kind.yaml
# Pod errors due to “too many open files”
# https://kind.sigs.k8s.io/docs/user/known-issues/#pod-errors-due-to-too-many-open-files
# sudo sysctl fs.inotify.max_user_watches=524288
# sudo sysctl fs.inotify.max_user_instances=512
# make persistent in /etc/sysctl.conf
helm repo add prometheus https://prometheus-community.github.io/helm-charts
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add sloth https://slok.github.io/sloth
helm repo update

# prometheus
kubectl create namespace prometheus
helm upgrade --install -n prometheus --values prometheus/values.yaml prometheus prometheus/kube-prometheus-stack --version=46.5.0

# loki
kubectl create namespace loki
helm upgrade --install -n loki --values promtail/values.yaml promtail grafana/promtail --version=6.11.1
helm upgrade --install -n loki --values loki/values.yaml loki grafana/loki --version=5.6.0

# tempo
kubectl create namespace tempo
helm upgrade --install -n tempo tempo grafana/tempo --version=1.3.1

# otel
kubectl create namespace otel
helm upgrade --install -n otel --values otel-collector/values.yaml opentelemetry-collector open-telemetry/opentelemetry-collector --version=0.56.0

# sloth
helm upgrade --install -n prometheus sloth sloth/sloth --values sloth/values.yaml --version=0.7.0
kubectl apply -f demo/slo/test.yaml -n prometheus
kubectl apply -f sloth/configmap.yaml -n prometheus

# demo
kubectl create namespace demo
kubectl apply -f demo/deploy.yaml
kubectl apply -f demo/svc.yaml
kubectl apply -f demo/svc-monitor.yaml -n prometheus
kubectl apply -f demo/configmap.yaml -n prometheus

# K6
kubectl apply -f k6/configmap.yaml -n prometheus
# Install K6 on Linux
# https://github.com/grafana/k6/releases/download/v0.44.1/k6-v0.44.1-linux-amd64.deb

# Fixes
kubectl delete deployment loki-grafana-agent-operator -n loki
kubectl delete grafanaagents loki -n lokiw
