# ========================================
# SISTEMA DI MONITORING KUBERNETES
# ========================================

# ========================================
# DEPLOY INIZIALE
# ========================================

# Creazione namespace monitoring
kubectl create namespace monitoring

# Deploy OpenTelemetry Collector
kubectl apply -f cluster/otel/

# Deploy Prometheus e Grafana
kubectl apply -f cluster/prometheus/
kubectl apply -f cluster/grafana/

# ========================================
# SIGNOZ (OPZIONALE - VIA HELM)
# ========================================
# Per installare SigNoz, usa il file cluster/signoz/setup.md
# Comando rapido: helm install signoz signoz/signoz -n signoz --create-namespace -f cluster/signoz/values.yaml

# ========================================
# KAFKA
# ========================================
# Per installare Kafka, usa il file cluster/kafka/setup.md
# Comando rapido: kubectl apply -f cluster/kafka/deploy-all.yaml

# ========================================
# INTEGRAZIONE OTEL-KAFKA
# ========================================
# Per integrare OTEL Collector con Kafka:
# 1. Deploy Kafka: kubectl apply -f cluster/kafka/deploy-all.yaml
# 2. Configura OTEL: kubectl apply -f cluster/otel/configmap.yaml
# 3. Riavvia OTEL: kubectl rollout restart deployment/otel-collector -n monitoring
# Documentazione: cluster/otel/setup.md

# ========================================
# SCRIPTS UTILI
# ========================================
# Per gestire i port-forwarding automatici:
# - Avvia tutti: ./cluster/scripts/port-forwarding/auto-port-forward.sh
# - Ferma tutti: ./cluster/scripts/port-forwarding/stop-port-forward.sh
# - Documentazione: cluster/scripts/port-forwarding/PORT-FORWARDING.md



# ========================================
# VERIFICA SERVIZI
# ========================================

# Verifica servizi attivi
kubectl get svc -n monitoring

# Verifica pod in esecuzione
kubectl get pods -n monitoring

# Verifica deployment
kubectl get deployments -n monitoring

# ========================================
# RIAVVIO SERVIZI
# ========================================

# Riavviare tutti i servizi contemporaneamente
kubectl rollout restart deployment -n monitoring

# ========================================
# MONITORAGGIO RIAVVIO
# ========================================

# Verificare stato rollout
kubectl rollout status deployment/otel-collector -n monitoring
kubectl rollout status deployment/prometheus -n monitoring
kubectl rollout status deployment/grafana -n monitoring

# Verificare log dopo riavvio
kubectl logs -l app=otel-collector -n monitoring --tail=20
kubectl logs -l app=prometheus -n monitoring --tail=20
kubectl logs -l app=grafana -n monitoring --tail=20

# ========================================
# ACCESSO AI SERVIZI
# ========================================

# Port-forward per accesso ai servizi monitoring
kubectl port-forward -n monitoring service/prometheus 9090:9090
kubectl port-forward -n monitoring service/grafana 3000:3000
kubectl port-forward -n monitoring service/otel-collector 9464:9464

# Porta 4317 (OTLP/gRPC)
kubectl port-forward -n monitoring service/otel-collector 4317:4317
# Porta 4318 (OTLP/HTTP)
kubectl port-forward -n monitoring service/otel-collector 4318:4318

