kind create cluster --config kind.yaml
# Pod errors due to “too many open files”
# https://kind.sigs.k8s.io/docs/user/known-issues/#pod-errors-due-to-too-many-open-files
# sudo sysctl fs.inotify.max_user_watches=524288
# sudo sysctl fs.inotify.max_user_instances=512
# make persistent in /etc/sysctl.conf
helm repo add prometheus https://prometheus-community.github.io/helm-charts
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

kubectl create namespace prometheus
helm upgrade --install -n prometheus --values prometheus/values.yaml prometheus prometheus/kube-prometheus-stack --version=46.5.0

# helm upgrade --install --values loki/values.yaml loki grafana/loki-distributed
kubectl create namespace loki
helm upgrade --install -n loki --values promtail/values.yaml promtail grafana/promtail --version=6.11.1
helm upgrade --install -n loki --values loki/values.yaml loki grafana/loki --version=5.6.0

# helm upgrade --install --values tempo/values.yaml tempo grafana/tempo-distributed --version=1.4.2
kubectl create namespace tempo
helm upgrade --install -n tempo tempo grafana/tempo --version=1.3.1

kubectl create namespace otel
helm upgrade --install -n otel --values otel-collector/values.yaml opentelemetry-collector open-telemetry/opentelemetry-collector --version=0.56.0

kubectl create namespace demo
kubectl apply -f demo

# Fixes
kubectl delete deployment loki-grafana-agent-operator
kubectl delete grafanaagents loki

# Import TNT Dashboard 16491
