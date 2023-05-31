kind create cluster --config kind.yaml

# Pod errors due to “too many open files”
# https://kind.sigs.k8s.io/docs/user/known-issues/#pod-errors-due-to-too-many-open-files
# sudo sysctl fs.inotify.max_user_watches=524288
# sudo sysctl fs.inotify.max_user_instances=512
# make persistent in /etc/sysctl.conf

kubectl apply -f argocd
# kubectl create namespace argocd
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.6.8/manifests/install.yaml
# kubectl get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" -n argocd | base64 -d && echo
helm upgrade --install prometheus kube-prometheus-stack/kube-prometheus-stack --values prometheus/values.yaml
# helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm upgrade --install opentelemetry-collector open-telemetry/opentelemetry-collector --values otel-collector/values.yaml

kubectl create namespace minio-tenant-1
# kubectl krew update
# kubectl krew install minio
kubectl minio init
kubectl apply -f minio
# local-storage 
# default
# 1 1 1 1 2 parity 0
# helm repo add grafana https://grafana.github.io/helm-charts
helm upgrade --install --values loki/loki.yaml loki grafana/loki
helm upgrade --install --values tempo/tempo.yaml tempo grafana/tempo

# kubectl get pods -n minio-operator
# kubectl port-forward svc/argocd-server 8001:80 -n argocd
