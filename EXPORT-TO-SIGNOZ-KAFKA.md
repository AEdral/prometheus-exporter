# 📊 Export Metriche verso SigNoz e Kafka

## 🎯 Panoramica

Questa configurazione estende il sistema di monitoring esistente per esportare le metriche Kubernetes verso:
- **SigNoz** (via OTLP/HTTP sulla porta 4318)
- **Kafka** (via OTLP/gRPC sulla porta 4317)

## 📁 File di Configurazione

### 1. ConfigMap Esteso
- **File**: `cluster/otel/configmap-otel-with-external-export.yaml`
- **Nome**: `otel-config-extended`
- **Funzione**: Configurazione OTEL con exporter OTLP

### 2. Service Esteso
- **File**: `cluster/otel/service-otel-with-external-export.yaml`
- **Nome**: `otel-collector-extended`
- **Porte**: 9464 (metrics), 4317 (OTLP/gRPC), 4318 (OTLP/HTTP)

## 🚀 Deploy della Configurazione Estesa

### Passo 1: Applicare la Configurazione
```bash
# Applica il ConfigMap esteso
kubectl apply -f cluster/otel/configmap-otel-with-external-export.yaml

# Applica il Service esteso
kubectl apply -f cluster/otel/service-otel-with-external-export.yaml
```

### Passo 2: Aggiornare il Deployment OTEL
```bash
# Modifica il deployment per usare la nuova configurazione
kubectl patch deployment otel-collector -n monitoring \
  -p '{"spec":{"template":{"spec":{"volumes":[{"name":"config","configMap":{"name":"otel-config-extended"}}]}}}}'
```

### Passo 3: Riavviare il Collector
```bash
# Riavvia il deployment per applicare le modifiche
kubectl rollout restart deployment/otel-collector -n monitoring

# Verifica lo stato
kubectl rollout status deployment/otel-collector -n monitoring
```

## 🔌 Configurazione Client Esterni

### SigNoz (OTLP/HTTP - Porta 4318)

#### Configurazione SigNoz
```yaml
# In SigNoz, configura un nuovo datasource OTLP
datasource:
  type: otlp
  url: http://otel-collector-extended.monitoring.svc.cluster.local:4318
  headers:
    signoz-tenant: "default"
    cluster-name: "production-cluster"
```

#### Test di Connessione
```bash
# Port-forward per test esterno
kubectl port-forward -n monitoring service/otel-collector-extended 4318:4318

# Test con curl
curl -X POST http://localhost:4318/v1/metrics \
  -H "Content-Type: application/json" \
  -H "signoz-tenant: default" \
  -H "cluster-name: production-cluster"
```

### Kafka (OTLP/gRPC - Porta 4317)

#### Configurazione Kafka
```yaml
# In Kafka, configura un consumer per il topic
consumer:
  topic: "kubernetes-metrics"
  bootstrap_servers: ["localhost:9092"]
  group_id: "otel-metrics-consumer"
```

#### Test di Connessione
```bash
# Port-forward per test esterno
kubectl port-forward -n monitoring service/otel-collector-extended 4317:4317

# Test con grpcurl (se installato)
grpcurl -plaintext localhost:4317 list
```

## 📊 Verifica Funzionamento

### 1. Controllo Log OTEL
```bash
# Verifica che gli exporter OTLP funzionino
kubectl logs -l app=otel-collector -n monitoring --tail=50 | grep -E "(otlp|grpc|http)"
```

### 2. Controllo Porte
```bash
# Verifica che le porte siano in ascolto
kubectl exec -n monitoring deployment/otel-collector -- netstat -tlnp | grep -E "(4317|4318)"
```

### 3. Controllo Metriche
```bash
# Verifica che le metriche siano esportate
kubectl port-forward -n monitoring service/otel-collector-extended 9464:9464
curl http://localhost:9464/metrics | grep -E "(otlp|grpc|http)"
```

## 🔧 Personalizzazione

### Headers Custom
Puoi modificare gli headers negli exporter OTLP:

```yaml
# Per SigNoz
otlp/http:
  headers:
    signoz-tenant: "your-tenant"
    cluster-name: "your-cluster"
    environment: "staging"

# Per Kafka
otlp/grpc:
  headers:
    kafka-topic: "your-topic"
    cluster-name: "your-cluster"
    data-center: "dc1"
```

### Configurazione TLS
Per ambienti di produzione, rimuovi `insecure: true` e configura certificati:

```yaml
otlp/http:
  tls:
    ca_file: "/etc/ssl/certs/ca-bundle.crt"
    cert_file: "/etc/ssl/certs/client.crt"
    key_file: "/etc/ssl/private/client.key"
```

## 🚨 Troubleshooting

### Problema: Metriche non esportate
```bash
# Verifica configurazione
kubectl get configmap otel-config-extended -n monitoring -o yaml

# Verifica log
kubectl logs -l app=otel-collector -n monitoring --tail=100
```

### Problema: Porte non accessibili
```bash
# Verifica servizi
kubectl get svc -n monitoring | grep otel

# Verifica endpoint
kubectl get endpoints -n monitoring | grep otel
```

### Problema: Connessione esterna fallita
```bash
# Test connettività interna
kubectl exec -n monitoring deployment/otel-collector -- curl -v http://localhost:4318/health

# Verifica firewall e network policies
kubectl get networkpolicies -n monitoring
```

## 📚 Risorse Aggiuntive

- [OpenTelemetry OTLP Exporter](https://opentelemetry.io/docs/specs/otel/protocol/exporter/)
- [SigNoz OTLP Integration](https://signoz.io/docs/userguide/ingestion-methods/otlp/)
- [Kafka OTLP Consumer](https://kafka.apache.org/documentation/) 