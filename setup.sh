kubectl delete deployment --all -n monitoring
kubectl delete configmap --all -n monitoring
kubectl delete service --all -n monitoring

# Applica i file OTEL
kubectl apply -f otel/rbac-otel.yaml
kubectl apply -f otel/configmap.yaml
kubectl apply -f otel/deployment.yaml
kubectl apply -f otel/service-otel.yaml

# Applica i file Prometheus
kubectl apply -f prometheus/rbac-prometheus.yaml
kubectl apply -f prometheus/configmap-prometheus.yaml
kubectl apply -f prometheus/deployment-prometheus.yaml
kubectl apply -f prometheus/service-prometheus.yaml

# Applica i file Grafana
kubectl apply -f grafana/configmap-grafana.yaml
kubectl apply -f grafana/deployment-grafana.yaml
kubectl apply -f grafana/service-grafana.yaml

# ========================================
# ATTESA POD PRONTI
# ========================================

echo "=== ATTENDO CHE I POD SIANO PRONTI ==="
echo "Verifico stato dei pod..."

# Attendi che tutti i pod siano Running
while true; do
    READY_PODS=$(kubectl get pods -n monitoring --no-headers | grep -c "Running")
    TOTAL_PODS=$(kubectl get pods -n monitoring --no-headers | wc -l)
    
    if [ "$READY_PODS" -eq "$TOTAL_PODS" ] && [ "$TOTAL_PODS" -gt 0 ]; then
        echo "✅ Tutti i $TOTAL_PODS pod sono pronti!"
        break
    else
        echo "⏳ Pod pronti: $READY_PODS/$TOTAL_PODS - attendo..."
        sleep 5
    fi
done

echo ""
echo "=== STATO FINALE POD ==="
kubectl get pods -n monitoring
echo ""

# ========================================
# PORT FORWARDING AUTOMATICO
# ========================================

echo "=== AVVIO PORT FORWARDING AUTOMATICO ==="
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 (admin/admin)"
echo "OTEL Collector: http://localhost:9464/metrics"
echo ""

# Avvia tutti i port forwarding in background
echo "Avvio port forwarding per Prometheus..."
kubectl port-forward -n monitoring service/prometheus 9090:9090 &
PROMETHEUS_PID=$!

echo "Avvio port forwarding per Grafana..."
kubectl port-forward -n monitoring service/grafana 3000:3000 &
GRAFANA_PID=$!

echo "Avvio port forwarding per OTEL Collector..."
kubectl port-forward -n monitoring service/otel-collector 9464:9464 &
OTEL_PID=$!

echo ""
echo "✅ Tutti i port forwarding sono attivi!"
echo "PROMETHEUS_PID: $PROMETHEUS_PID"
echo "GRAFANA_PID: $GRAFANA_PID"
echo "OTEL_PID: $OTEL_PID"
echo ""
echo "Per fermare tutti i port forwarding:"
echo "kill $PROMETHEUS_PID $GRAFANA_PID $OTEL_PID"
echo ""
echo "Oppure usa: pkill -f 'kubectl port-forward'"
echo ""
echo "=== SERVIZI DISPONIBILI ==="
echo "🌐 Prometheus: http://localhost:9090"
echo "📊 Grafana: http://localhost:3000"
echo "📈 OTEL Collector: http://localhost:9464/metrics"
echo ""
echo "Premi Ctrl+C per fermare questo script (i port forwarding continueranno in background)"
echo ""

# Mantieni lo script attivo per mostrare i log
wait



