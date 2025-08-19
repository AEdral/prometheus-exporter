#!/bin/bash

# ========================================
# AUTO PORT-FORWARDING PER CLUSTER KUBERNETES
# ========================================
# Questo script avvia automaticamente il port-forwarding
# per tutti gli applicativi del cluster

echo "🚀 Avvio auto port-forwarding per tutti gli applicativi del cluster..."

# Funzione per fermare tutti i port-forwarding attivi
stop_all_port_forwards() {
    echo "🛑 Fermando tutti i port-forwarding attivi..."
    pkill -f "kubectl port-forward" || true
    sleep 2
}

# Funzione per verificare se un namespace esiste
namespace_exists() {
    kubectl get namespace "$1" >/dev/null 2>&1
}

# Funzione per verificare se un service esiste
service_exists() {
    kubectl get service "$1" -n "$2" >/dev/null 2>&1
}

# Ferma tutti i port-forwarding esistenti
stop_all_port_forwards

# ========================================
# MONITORING (Prometheus + Grafana)
# ========================================
if namespace_exists "monitoring"; then
    echo "📊 Configurando port-forwarding per MONITORING..."
    
    # Grafana
    if service_exists "grafana" "monitoring"; then
        echo "   📈 Grafana: http://localhost:3000"
        kubectl port-forward -n monitoring service/grafana 3000:3000 >/dev/null 2>&1 &
        echo "   ✅ Port-forwarding Grafana avviato (PID: $!)"
    fi
    
    # Prometheus
    if service_exists "prometheus" "monitoring"; then
        echo "   🔍 Prometheus: http://localhost:9090"
        kubectl port-forward -n monitoring service/prometheus 9090:9090 >/dev/null 2>&1 &
        echo "   ✅ Port-forwarding Prometheus avviato (PID: $!)"
    fi
    
    # OTEL Collector (opzionale, per debugging)
    if service_exists "otel-collector" "monitoring"; then
        echo "   📡 OTEL Collector: http://localhost:9464"
        kubectl port-forward -n monitoring service/otel-collector 9464:9464 >/dev/null 2>&1 &
        echo "   ✅ Port-forwarding OTEL Collector avviato (PID: $!)"
    fi
else
    echo "⚠️  Namespace 'monitoring' non trovato"
fi

# ========================================
# KAFKA
# ========================================
if namespace_exists "kafka"; then
    echo "📨 Configurando port-forwarding per KAFKA..."
    
    # Kafka
    if service_exists "kafka" "kafka"; then
        echo "   🚀 Kafka: localhost:9092"
        kubectl port-forward -n kafka service/kafka 9092:9092 >/dev/null 2>&1 &
        echo "   ✅ Port-forwarding Kafka avviato (PID: $!)"
    fi
    
    # Zookeeper
    if service_exists "zookeeper" "kafka"; then
        echo "   🐘 Zookeeper: localhost:2181"
        kubectl port-forward -n kafka service/zookeeper 2181:2181 >/dev/null 2>&1 &
        echo "   ✅ Port-forwarding Zookeeper avviato (PID: $!)"
    fi
    
    # Kafka UI
    if service_exists "kafka-ui" "kafka"; then
        echo "   🖥️  Kafka UI: http://localhost:8080"
        kubectl port-forward -n kafka service/kafka-ui 8080:8080 >/dev/null 2>&1 &
        echo "   ✅ Port-forwarding Kafka UI avviato (PID: $!)"
    fi
else
    echo "⚠️  Namespace 'kafka' non trovato"
fi

# ========================================
# KUBERNETES DASHBOARD
# ========================================
if namespace_exists "kubernetes-dashboard"; then
    echo "🖥️  Configurando port-forwarding per KUBERNETES DASHBOARD..."
    
    # Kubernetes Dashboard
    if service_exists "kubernetes-dashboard" "kubernetes-dashboard"; then
        echo "   🎛️  Kubernetes Dashboard: https://localhost:8443"
        kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8443:443 >/dev/null 2>&1 &
        echo "   ✅ Port-forwarding Kubernetes Dashboard avviato (PID: $!)"
    fi
else
    echo "⚠️  Namespace 'kubernetes-dashboard' non trovato"
fi

# ========================================
# VERIFICA FINALE
# ========================================
echo ""
echo "🎯 PORT-FORWARDING COMPLETATO!"
echo "================================"
echo "📊 MONITORING:"
echo "   Grafana:        http://localhost:3000"
echo "   Prometheus:     http://localhost:9090"
echo "   OTEL Collector: http://localhost:9464"
echo ""
echo "📨 KAFKA:"
echo "   Kafka:          localhost:9092"
echo "   Zookeeper:      localhost:2181"
echo "   Kafka UI:       http://localhost:30080"
echo ""
echo "🖥️  KUBERNETES:"
echo "   Dashboard:      https://localhost:8443"
echo ""
echo "💡 Per fermare tutti i port-forwarding:"
echo "   ./cluster/scripts/port-forwarding/stop-port-forward.sh"
echo ""
echo "🔍 Per verificare i processi attivi:"
echo "   ps aux | grep 'kubectl port-forward'"
echo ""

# Salva i PID per poterli fermare dopo
echo "Saving PIDs to cluster/scripts/port-forwarding/port-forward-pids.txt..."
ps aux | grep "kubectl port-forward" | grep -v grep | awk '{print $2}' > cluster/scripts/port-forwarding/port-forward-pids.txt 2>/dev/null || true

echo "✅ Auto port-forwarding completato!" 