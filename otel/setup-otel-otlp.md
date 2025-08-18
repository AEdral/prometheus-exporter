# 📡 Integrazione OTEL Collector - OTLP - Kafka

Questo documento spiega come configurare OTEL Collector per esportare le metriche Kubernetes via protocollo OTLP a un bridge che le invia a Kafka.

## 🎯 Obiettivo

Creare un pipeline completo e standard:
```
Kubernetes (cAdvisor/kubelet) → OTEL Collector → OTLP → Bridge → Kafka
```

## 📁 File necessari

### **OTEL Collector:**
- `configmap-otel-otlp.yaml` - Configurazione OTEL con export OTLP
- `setup-otel-otlp.md` - Questa documentazione

### **Bridge OTLP→Kafka:**
- `../otel-kafka-bridge/deploy-all.yaml` - Bridge completo
- `../otel-kafka-bridge/setup.md` - Documentazione bridge

## 🚀 Setup

### 1. Prerequisiti
- ✅ Cluster Kubernetes attivo
- ✅ Namespace `monitoring` con OTEL Collector
- ✅ Namespace `kafka` con Kafka e Zookeeper

### 2. Deploy del bridge OTLP→Kafka
```bash
# Deploy del bridge
kubectl apply -f cluster/otel-kafka-bridge/deploy-all.yaml
```

### 3. Applica la nuova configurazione OTEL
```bash
# Applica la configurazione OTEL con export OTLP
kubectl apply -f cluster/otel/configmap-otel-otlp.yaml
```

### 4. Riavvia OTEL Collector
```bash
# Riavvia per applicare la nuova configurazione
kubectl rollout restart deployment/otel-collector -n monitoring

# Verifica lo stato
kubectl rollout status deployment/otel-collector -n monitoring
```

### 5. Verifica la configurazione
```bash
# Controlla che il ConfigMap sia stato applicato
kubectl get configmap -n monitoring otel-config-otlp

# Verifica la configurazione
kubectl get configmap -n monitoring otel-config-otlp -o yaml
```

## 🔧 Configurazione

### 📊 **Receivers**
- **Prometheus**: Raccoglie metriche da cAdvisor e kubelet
- **Auto-discovery**: Rileva automaticamente i nodi Kubernetes

### ⚙️ **Processors**
- **Batch**: Raggruppa metriche per performance
- **Memory Limiter**: Controlla l'uso di memoria
- **Attributes**: Aggiunge metadati custom

### 📤 **Exporters**
- **Prometheus**: Espone metriche su porta 9464 (locale)
- **OTLP**: Esporta via protocollo standard a `otel-kafka-bridge:4317`
- **Logging**: Debug e monitoraggio

### 🔗 **Pipeline**
```
prometheus → [attributes, memory_limiter, batch] → [prometheus, otlp, logging]
```

## 📨 Configurazione OTLP

### 🎯 **Endpoint:**
- **Servizio**: `otel-kafka-bridge.monitoring.svc.cluster.local:4317`
- **Protocollo**: gRPC
- **Formato**: Protobuf binario (standard OTLP)

### ⚡ **Performance:**
- **Retry**: Abilitato con backoff esponenziale
- **Intervallo iniziale**: 5s
- **Intervallo massimo**: 30s
- **Tempo massimo**: 300s

## 🧪 Test

### 1. Test rapido
```bash
# Esegui il test completo
./cluster/scripts/otel-kafka-test.sh
```

### 2. Test manuale
```bash
# Verifica stato bridge
kubectl get pods -n monitoring | grep otel-kafka-bridge

# Controlla log bridge
kubectl logs -n monitoring deployment/otel-kafka-bridge

# Monitora topic Kafka
kubectl exec -n kafka deployment/kafka -- kafka-console-consumer.sh --topic otel-metrics --bootstrap-server localhost:9092 --from-beginning
```

### 3. Verifica log OTEL
```bash
# Monitora i log per errori
kubectl logs -f -n monitoring deployment/otel-collector | grep -i otlp
```

## 🔍 Monitoraggio

### 📊 **Metriche OTEL**
```bash
# Endpoint Prometheus locale
curl http://localhost:9464/metrics
```

### 📨 **Topic Kafka**
```bash
# Lista topic
kubectl exec -n kafka deployment/kafka -- kafka-topics.sh --list --bootstrap-server localhost:9092

# Statistiche topic
kubectl exec -n kafka deployment/kafka -- kafka-topics.sh --describe --topic otel-metrics --bootstrap-server localhost:9092
```

### 🔗 **Bridge OTLP→Kafka**
```bash
# Log del bridge
kubectl logs -f -n monitoring deployment/otel-kafka-bridge

# Health check
kubectl port-forward -n monitoring service/otel-kafka-bridge 8080:8080
curl http://localhost:8080/health
```

### 📈 **Grafana Dashboard**
- **URL**: http://localhost:3000
- **DataSource**: Prometheus (localhost:9090)
- **Query**: `otel_*` per metriche OTEL

## 🚨 Troubleshooting

### ❌ **OTEL Collector non si avvia**
```bash
# Verifica la configurazione
kubectl describe pod -n monitoring -l app=otel-collector

# Controlla i log
kubectl logs -n monitoring deployment/otel-collector
```

### ❌ **Bridge non si avvia**
```bash
# Verifica dipendenze Kafka
kubectl get pods -n kafka

# Controlla log
kubectl logs -n monitoring deployment/otel-kafka-bridge
```

### ❌ **Dati non arrivano a Kafka**
```bash
# Verifica connessione OTLP
kubectl exec -n monitoring deployment/otel-kafka-bridge -- nslookup otel-kafka-bridge.monitoring.svc.cluster.local

# Testa la connessione
kubectl exec -n monitoring deployment/otel-kafka-bridge -- telnet otel-kafka-bridge.monitoring.svc.cluster.local 4317
```

## 📈 **Metriche esportate**

### 🖥️ **Sistema**
- CPU, memoria, disco per nodo
- Utilizzo risorse per container
- Metriche di rete

### 🐳 **Kubernetes**
- Stato pod e deployment
- Metriche di scheduling
- Utilizzo risorse cluster

### 📊 **OTEL Collector**
- Metriche di performance
- Errori di export
- Statistiche pipeline

## 🎉 **Vantaggi dell'approccio OTLP**

- **📊 Protocollo standard** - OTLP è il protocollo ufficiale OpenTelemetry
- **🔗 Compatibilità garantita** - Nessun problema di encoding o configurazione
- **📈 Scalabilità** - Facile aggiungere più destinazioni
- **🔄 Resilienza** - Retry automatico e fault tolerance
- **🛠️ Manutenibilità** - Configurazione standard e documentata
- **📊 Dati strutturati** - Formato JSON leggibile in Kafka

## 🔄 **Flusso dati completo**

```
1. Kubernetes genera metriche (cAdvisor, kubelet)
2. OTEL Collector le raccoglie via receiver Prometheus
3. Processors aggiungono attributi e raggruppano
4. OTLP Exporter invia dati al bridge via gRPC
5. Bridge riceve dati OTLP e li converte in JSON
6. Bridge invia dati strutturati a topic Kafka
7. Sistemi downstream consumano da Kafka
```

---

**💡 Pro-tip**: Questo pipeline è completamente standard e può essere facilmente esteso per supportare tracce, log e altre destinazioni! 