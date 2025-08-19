#!/bin/bash

echo "🔥 ELIMINAZIONE COMPLETA di tutti i dati Kafka e Monitoring..."
echo "============================================================"

# Namespace da riavviare
NAMESPACE="kafka"
MONITORING_NAMESPACE="monitoring"

echo "📋 Passo 1: Eliminando tutti i deployment e servizi di Kafka..."
kubectl delete deployment kafka zookeeper -n $NAMESPACE --ignore-not-found=true
kubectl delete service kafka zookeeper -n $NAMESPACE --ignore-not-found=true

echo "📋 Passo 2: Eliminando tutti i PVC di Kafka..."
kubectl delete pvc --all -n $NAMESPACE --ignore-not-found=true

echo "📋 Passo 3: Eliminando TUTTI i PV di Kafka e Zookeeper..."
# Trova e elimina tutti i PV che contengono "kafka" o "zookeeper" nel nome
kubectl get pv | grep -E "(kafka|zookeeper)" | awk '{print $1}' | xargs -r kubectl delete pv

echo "📋 Passo 4: Eliminando il namespace Kafka completo..."
kubectl delete namespace $NAMESPACE --ignore-not-found=true

echo "📋 Passo 5: Eliminando il namespace Monitoring completo..."
kubectl delete namespace $MONITORING_NAMESPACE --ignore-not-found=true

echo "📋 Passo 6: Aspettando che tutti i namespace siano completamente eliminati..."
sleep 25

kubectl create namespace monitoring

echo "📋 Passo 7: Verificando che tutto sia pulito..."
kubectl get namespace $NAMESPACE 2>/dev/null || echo "   Namespace $NAMESPACE eliminato"
kubectl get namespace $MONITORING_NAMESPACE 2>/dev/null || echo "   Namespace $MONITORING_NAMESPACE eliminato"
kubectl get pv | grep -E "(kafka|zookeeper)" || echo "   Nessun PV Kafka/Zookeeper rimasto"

echo "📋 Passo 8: Ricreando Kafka da zero (il namespace viene creato automaticamente dai YAML)..."
kubectl apply -f kafka/

echo "📋 Passo 9: Ricreando Monitoring (il namespace viene creato automaticamente dai YAML)..."

kubectl apply -f prometheus/
kubectl apply -f grafana/
kubectl apply -f otel/
kubectl apply -f infra-otel/

echo "📋 Passo 10: Aspettando che tutti i pod si avvino..."
sleep 25

echo "📋 Passo 11: Verificando lo stato finale di tutti i namespace..."
echo "   Stato Kafka:"
kubectl get pods -n $NAMESPACE 2>/dev/null || echo "     Namespace non ancora disponibile"
echo "   Stato Monitoring (Prometheus + Grafana + OTEL + Infra-OTEL):"
kubectl get pods -n $MONITORING_NAMESPACE 2>/dev/null || echo "     Namespace non ancora disponibile"

echo ""
echo "✅ ELIMINAZIONE COMPLETA COMPLETATA!"
echo "💡 I namespace sono stati riavviati da zero:"
echo "   - Kafka (contiene solo i servizi Kafka)"
echo "   - Monitoring (contiene Prometheus, Grafana, OTEL, Infra-OTEL)"
echo "💡 Kafka dovrebbe ora funzionare senza Cluster ID mismatch"
echo "💡 Per verificare: kubectl get pods -n kafka"
echo "💡 Per i log: kubectl logs -n kafka kafka-<pod-id>" 