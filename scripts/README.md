# 🛠️ Scripts per Cluster Kubernetes

Questa cartella contiene tutti gli script utili per gestire il cluster Kubernetes.

## 📁 Struttura

```
scripts/
├── README.md                    # Questo file
└── port-forwarding/            # Script per port-forwarding automatico
    ├── auto-port-forward.sh    # Avvia tutti i port-forwarding
    ├── stop-port-forward.sh    # Ferma tutti i port-forwarding
    └── PORT-FORWARDING.md      # Documentazione completa
```

## 🚀 Script disponibili

### 📡 **Port-Forwarding Automatico**
Script per gestire automaticamente tutti i port-forwarding del cluster.

**Comandi rapidi:**
```bash
# Avvia tutti i port-forwarding
./cluster/scripts/port-forwarding/auto-port-forward.sh

# Ferma tutti i port-forwarding
./cluster/scripts/port-forwarding/stop-port-forward.sh
```

**Applicativi supportati:**
- 📊 **Monitoring**: Grafana, Prometheus, OTEL Collector
- 📨 **Kafka**: Kafka, Zookeeper
- 🖥️ **Kubernetes**: Dashboard

## 🔧 Come usare

1. **Naviga nella cartella del progetto:**
   ```bash
   cd /path/to/your/project
   ```

2. **Esegui gli script:**
   ```bash
   # Avvia port-forwarding
   ./cluster/scripts/port-forwarding/auto-port-forward.sh
   
   # Ferma port-forwarding
   ./cluster/scripts/port-forwarding/stop-port-forward.sh
   ```

## 📚 Documentazione

- **Port-Forwarding**: Vedi `port-forwarding/PORT-FORWARDING.md` per documentazione completa
- **Troubleshooting**: Ogni script include istruzioni per la risoluzione dei problemi

## 🎯 Vantaggi

- **🚀 Automazione completa** - Un comando per tutto
- **🔄 Auto-rilevamento** - Si adatta al tuo cluster
- **🛑 Gestione intelligente** - Gestisce processi e pulizia
- **📝 Logging completo** - Sa sempre cosa sta facendo
- **🔧 Zero configurazione** - Funziona subito

---

**💡 Suggerimento**: Usa questi script all'avvio della sessione di lavoro per avere accesso immediato a tutti i servizi del cluster! 