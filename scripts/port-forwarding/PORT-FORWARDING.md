# 🚀 Auto Port-Forwarding per Cluster Kubernetes

Questo documento spiega come usare gli scripts automatici per il port-forwarding di tutti gli applicativi del cluster.

## 📁 File disponibili

- `auto-port-forward.sh` - Avvia automaticamente tutti i port-forwarding
- `stop-port-forward.sh` - Ferma tutti i port-forwarding attivi
- `PORT-FORWARDING.md` - Questa documentazione

## 🎯 Applicativi supportati

### 📊 **MONITORING**
- **Grafana**: http://localhost:3000
- **Prometheus**: http://localhost:9090  
- **OTEL Collector**: http://localhost:9464

### 📨 **KAFKA**
- **Kafka**: localhost:9092
- **Zookeeper**: localhost:2181
- **Kafka UI**: http://localhost:30080

### 🖥️ **KUBERNETES**
- **Dashboard**: https://localhost:8443

## 🚀 Come usare

### 1. Avvia tutti i port-forwarding
```bash
./cluster/scripts/port-forwarding/auto-port-forward.sh
```

### 2. Ferma tutti i port-forwarding
```bash
./cluster/scripts/port-forwarding/stop-port-forward.sh
```

### 3. Verifica i processi attivi
```bash
ps aux | grep "kubectl port-forward"
```

## 🔧 Funzionalità

### ✅ **Auto-rilevamento**
- Rileva automaticamente i namespace esistenti
- Verifica la presenza dei servizi prima di avviare il port-forwarding
- Gestisce namespace mancanti senza errori

### 🛑 **Gestione intelligente**
- Ferma automaticamente i port-forwarding esistenti
- Salva i PID per tracciabilità
- Gestione graceful dei processi

### 📝 **Logging dettagliato**
- Mostra tutti i servizi configurati
- Indica le porte e URL di accesso
- Conferma l'avvio di ogni port-forwarding

## 🎨 Esempio di output

```
🚀 Avvio auto port-forwarding per tutti gli applicativi del cluster...
📊 Configurando port-forwarding per MONITORING...
   📈 Grafana: http://localhost:3000
   ✅ Port-forwarding Grafana avviato (PID: 12345)
   🔍 Prometheus: http://localhost:9090
   ✅ Port-forwarding Prometheus avviato (PID: 12346)
📨 Configurando port-forwarding per KAFKA...
   🚀 Kafka: localhost:9092
   ✅ Port-forwarding Kafka avviato (PID: 12347)

🎯 PORT-FORWARDING COMPLETATO!
================================
📊 MONITORING:
   Grafana:        http://localhost:3000
   Prometheus:     http://localhost:9090
   OTEL Collector: http://localhost:9464

📨 KAFKA:
   Kafka:          localhost:9092
   Zookeeper:      localhost:2181
   Kafka UI:       http://localhost:30080

🖥️  KUBERNETES:
   Dashboard:      https://localhost:8443
```

## ⚠️ Note importanti

### 🔒 **Sicurezza**
- I port-forwarding sono solo per sviluppo locale
- Non esporre queste porte su reti pubbliche
- Usa solo su cluster di sviluppo/test

### 🧹 **Pulizia**
- Usa sempre `stop-port-forward.sh` prima di chiudere il terminale
- Gli script gestiscono automaticamente la pulizia dei processi
- I PID vengono salvati per tracciabilità

### 🔄 **Riavvio**
- Se un servizio si riavvia, riavvia anche lo script
- Gli script verificano automaticamente la presenza dei servizi
- Gestiscono gracefully i servizi mancanti

## 🚨 Troubleshooting

### Porta già in uso
```bash
# Verifica processi attivi
ps aux | grep "kubectl port-forward"

# Ferma forzatamente
pkill -9 -f "kubectl port-forward"

# Riavvia
./cluster/scripts/port-forwarding/auto-port-forward.sh
```

### Servizio non raggiungibile
```bash
# Verifica stato del cluster
kubectl get pods -A

# Verifica servizi
kubectl get svc -A

# Riavvia port-forwarding
./cluster/scripts/port-forwarding/stop-port-forward.sh
./cluster/scripts/port-forwarding/auto-port-forward.sh
```

## 🎉 Vantaggi

- **🚀 Setup automatico** - Un comando per tutto
- **🔄 Auto-rilevamento** - Si adatta al cluster
- **🛑 Gestione intelligente** - Ferma e riavvia automaticamente
- **📝 Logging completo** - Sa sempre cosa sta facendo
- **🧹 Pulizia automatica** - Non lascia processi orfani
- **🔧 Manutenzione zero** - Funziona senza configurazione

---

**💡 Pro-tip**: Usa questi script all'avvio della sessione di lavoro per avere subito accesso a tutti i servizi!

## 📁 Struttura delle cartelle

```
cluster/
├── scripts/
│   └── port-forwarding/
│       ├── auto-port-forward.sh
│       ├── stop-port-forward.sh
│       └── PORT-FORWARDING.md
├── kafka/
├── monitoring/
└── ...
``` 