kind create cluster --config kind.yaml
# Pod errors due to “too many open files”
# https://kind.sigs.k8s.io/docs/user/known-issues/#pod-errors-due-to-too-many-open-files
# sudo sysctl fs.inotify.max_user_watches=524288
# sudo sysctl fs.inotify.max_user_instances=512
# make persistent in /etc/sysctl.conf
helm repo add prometheus https://prometheus-community.github.io/helm-charts
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
help repo update
helm upgrade --install --values prometheus/values.yaml prometheus prometheus/kube-prometheus-stack
helm upgrade --install --values otel-collector/values.yaml opentelemetry-collector open-telemetry/opentelemetry-collector
helm upgrade --install --values promtail/values.yaml promtail grafana/promtail
helm upgrade --install --values loki/loki.yaml loki grafana/loki-distributed
helm upgrade --install --values tempo/values.yaml tempo grafana/tempo
