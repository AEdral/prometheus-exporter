# ========================================
# SETUP COMPLETO SIGNOZ SU KUBERNETES
# ========================================

## 🎯 **Panoramica**
SigNoz è una piattaforma di observability open-source che fornisce logs, metrics e traces in un'unica interfaccia.

## 📋 **Prerequisiti**
- Kubernetes >= 1.22
- Helm 3
- kubectl configurato
- ~8GB RAM / 4 CPU disponibili
- StorageClass disponibile (es. `standard` su Minikube)

## 🚀 **Installazione con Helm**

### **Passo 1: Preparazione**
```bash
# Aggiungi il repository Helm di SigNoz
helm repo add signoz https://charts.signoz.io
helm repo update

# Verifica la storage class disponibile
kubectl get storageclass
```

### **Passo 2: Configurazione**
Il file `values.yaml` è già configurato nella cartella `signoz/` con:
- Storage class appropriata per Minikube
- Risorse ottimizzate per cluster di sviluppo
- Configurazione ClickHouse personalizzata

### **Passo 3: Deploy**
```bash
# Installa SigNoz nel namespace 'signoz'
helm install signoz signoz/signoz \
  -n signoz --create-namespace \
  --wait --timeout 1h \
  -f cluster/signoz/values.yaml
```

### **Passo 4: Verifica Installazione**
```bash
# Controlla i pod
kubectl get pods -n signoz

# Controlla i servizi
kubectl get svc -n signoz

# Controlla lo stato Helm
helm status signoz -n signoz
```

## 🌐 **Accesso ai Servizi**

### **UI di SigNoz**
```bash
# Port-forward per l'interfaccia web
kubectl port-forward -n signoz svc/signoz 8080:8080

# UI: http://localhost:8080
```

### **Health Check**
```bash
# Verifica che SigNoz sia funzionante
curl -s http://localhost:8080/api/v1/health
# Atteso: {"status":"ok"}
```

## 🔌 **Endpoint OTLP per Applicazioni**

### **Raccolta Dati**
```bash
# Ottieni gli endpoint per le tue applicazioni
kubectl get svc -n signoz signoz-otel-collector

# OTLP gRPC:  signoz-otel-collector.signoz.svc.cluster.local:4317
# OTLP HTTP:  signoz-otel-collector.signoz.svc.cluster.local:4318
```

### **Integrazione con OTEL Collector Esistente**
Dopo aver installato SigNoz, aggiorna la configurazione del tuo OTEL Collector per esportare verso SigNoz:

```yaml
# In cluster/otel/configmap-otel.yaml, aggiungi:
exporters:
  otlp/signoz:
    endpoint: "signoz-otel-collector.signoz.svc.cluster.local:4317"
    tls:
      insecure: true

service:
  pipelines:
    metrics:
      exporters: [prometheus, otlp/signoz]
```

## 🛠️ **Gestione e Manutenzione**

### **Upgrade**
```bash
# Aggiorna SigNoz alla versione più recente
helm -n signoz upgrade signoz signoz/signoz -f cluster/signoz/values.yaml
```

### **Disinstallazione**
```bash
# Rimuovi SigNoz
helm -n signoz uninstall signoz

# Rimuovi il namespace (opzionale)
kubectl delete namespace signoz
```

### **Log e Troubleshooting**
```bash
# Controlla i log di SigNoz
kubectl logs -n signoz deployment/signoz

# Controlla i log dell'OTEL Collector
kubectl logs -n signoz deployment/signoz-otel-collector

# Controlla i log di ClickHouse
kubectl logs -n signoz deployment/chi-signoz-clickhouse-cluster-0-0-0
```

## 📊 **Dashboard e Metriche**

### **Dashboard Predefiniti**
SigNoz include dashboard predefiniti per:
- Kubernetes Infrastructure
- Application Performance
- Database Performance
- Custom Metrics

### **Retention dei Dati**
- **Logs e Traces**: 7 giorni (configurabile)
- **Metrics**: 30 giorni (configurabile)
- **Modifica**: Settings > General nell'UI di SigNoz

## 🔧 **Configurazione Avanzata**

### **Storage Class**
Se la StorageClass predefinita non supporta resize, abilitalo:
```bash
DEFAULT_STORAGE_CLASS=$(kubectl get storageclass -o=jsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")].metadata.name}')
kubectl patch storageclass "$DEFAULT_STORAGE_CLASS" -p '{"allowVolumeExpansion": true}'
```

### **Risorse Personalizzate**
Modifica `cluster/signoz/values.yaml` per:
- Aumentare/diminuire risorse CPU e memoria
- Configurare repliche per alta disponibilità
- Personalizzare configurazioni ClickHouse

## 📚 **Risorse Utili**
- [Documentazione Ufficiale SigNoz](https://signoz.io/docs/)
- [Helm Charts Repository](https://charts.signoz.io/)
- [Community Slack](http://signoz.io/slack/)
- [GitHub Repository](https://github.com/SigNoz/signoz)

## 🚨 **Troubleshooting Comune**

### **Pod in CrashLoopBackOff**
```bash
# Controlla i log per errori di configurazione
kubectl logs -n signoz <pod-name>

# Verifica la configurazione Helm
helm get values signoz -n signoz
```

### **PVC in Pending**
```bash
# Verifica che la StorageClass sia disponibile
kubectl get storageclass

# Controlla i PVC
kubectl get pvc -n signoz
```

### **Port-forward non funziona**
```bash
# Verifica che il servizio sia attivo
kubectl get svc -n signoz

# Controlla i pod
kubectl get pods -n signoz
``` 