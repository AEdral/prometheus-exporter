# Creazione namespace monitoring
kubectl create namespace monitoring

# Deploy OpenTelemetry Collector
kubectl apply -f cluster/otel/

# Deploy Prometheus e Grafana
kubectl apply -f cluster/prometheus/
kubectl apply -f cluster/grafana/

# Verifica servizi
kubectl get svc -n monitoring

# Port-forward per accesso ai servizi
kubectl port-forward -n monitoring service/prometheus 9090:9090
kubectl port-forward -n monitoring service/grafana 3000:3000
kubectl port-forward -n monitoring service/otel-collector 9464:9464