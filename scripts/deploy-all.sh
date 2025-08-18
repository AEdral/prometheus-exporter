 #!/bin/bash

# Script di deployment completo per il cluster Kubernetes
# Applica tutti i file YAML e fa rollout per riavviare tutto

set -e  # Exit on error

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funzione per logging colorato
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Funzione per verificare se kubectl è disponibile
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl non è installato o non è nel PATH"
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Impossibile connettersi al cluster Kubernetes"
        exit 1
    fi
    
    log_success "Connessione al cluster Kubernetes verificata"
}

# Funzione per creare namespace se non esiste
create_namespace() {
    local namespace=$1
    if ! kubectl get namespace $namespace &> /dev/null; then
        log_info "Creazione namespace: $namespace"
        kubectl create namespace $namespace
    else
        log_info "Namespace $namespace già esistente"
    fi
}

# Funzione per applicare file YAML
apply_yaml() {
    local file=$1
    local description=$2
    
    if [ -f "$file" ]; then
        log_info "Applicazione: $description"
        kubectl apply -f "$file"
        log_success "Applicato: $description"
    else
        log_warning "File non trovato: $file"
    fi
}

# Funzione per rollout restart
rollout_restart() {
    local deployment=$1
    local namespace=$2
    
    if kubectl get deployment $deployment -n $namespace &> /dev/null; then
        log_info "Rollout restart per: $deployment in namespace $namespace"
        kubectl rollout restart deployment/$deployment -n $namespace
        log_success "Rollout avviato per: $deployment"
    else
        log_warning "Deployment non trovato: $deployment in namespace $namespace"
    fi
}

# Funzione per attendere che i deployment siano pronti
wait_for_deployments() {
    local namespace=$1
    shift
    local deployments=("$@")
    
    log_info "Attendo che i deployment in $namespace siano pronti..."
    
    for deployment in "${deployments[@]}"; do
        if kubectl get deployment $deployment -n $namespace &> /dev/null; then
            log_info "Attendo deployment: $deployment"
            kubectl rollout status deployment/$deployment -n $namespace --timeout=300s
            log_success "Deployment $deployment è pronto"
        fi
    done
}

# Main script
main() {
    log_info "=== SCRIPT DI DEPLOYMENT COMPLETO ==="
    log_info "Data e ora: $(date)"
    
    # Verifica kubectl
    check_kubectl
    
    # Creazione namespace necessari
    log_info "--- Creazione namespace ---"
    create_namespace "monitoring"
    create_namespace "kafka"
    create_namespace "signoz"
    
    # 1. DEPLOYMENT KAFKA (prima di tutto)
    log_info "--- DEPLOYMENT KAFKA ---"
    apply_yaml "cluster/kafka/namespace-kafka.yaml" "Namespace Kafka"
    apply_yaml "cluster/kafka/pvc-zookeeper.yaml" "PVC Zookeeper"
    apply_yaml "cluster/kafka/pvc-kafka.yaml" "PVC Kafka"
    apply_yaml "cluster/kafka/configmap-zookeeper.yaml" "ConfigMap Zookeeper"
    apply_yaml "cluster/kafka/service-zookeeper.yaml" "Service Zookeeper"
    apply_yaml "cluster/kafka/deployment-zookeeper-simple.yaml" "Deployment Zookeeper"
    apply_yaml "cluster/kafka/service-kafka.yaml" "Service Kafka"
    apply_yaml "cluster/kafka/deploy-all.yaml" "Deployment Kafka completo"
    
    # 2. DEPLOYMENT PROMETHEUS
    log_info "--- DEPLOYMENT PROMETHEUS ---"
    apply_yaml "cluster/prometheus/rbac-prometheus.yaml" "RBAC Prometheus"
    apply_yaml "cluster/prometheus/configmap-prometheus.yaml" "ConfigMap Prometheus"
    apply_yaml "cluster/prometheus/deployment-prometheus.yaml" "Deployment Prometheus"
    apply_yaml "cluster/prometheus/service-prometheus.yaml" "Service Prometheus"
    
    # 3. DEPLOYMENT GRAFANA
    log_info "--- DEPLOYMENT GRAFANA ---"
    apply_yaml "cluster/grafana/configmap-grafana.yaml" "ConfigMap Grafana"
    apply_yaml "cluster/grafana/deployment-grafana.yaml" "Deployment Grafana"
    apply_yaml "cluster/grafana/service-grafana.yaml" "Service Grafana"
    
    # 4. DEPLOYMENT OTEL
    log_info "--- DEPLOYMENT OTEL ---"
    apply_yaml "cluster/otel/rbac-otel.yaml" "RBAC OTEL"
    apply_yaml "cluster/otel/configmap-otel-otlp.yaml" "ConfigMap OTEL"
    apply_yaml "cluster/otel/deployment-otel-otlp.yaml" "Deployment OTEL"
    apply_yaml "cluster/otel/service-otel.yaml" "Service OTEL"
    
    # 5. DEPLOYMENT SIGNOZ (se necessario)
    log_info "--- DEPLOYMENT SIGNOZ ---"
    if [ -f "cluster/signoz/values.yaml" ]; then
        log_info "SignOz trovato - applicazione con Helm (se installato)"
        if command -v helm &> /dev/null; then
            helm upgrade --install signoz signoz/signoz -f cluster/signoz/values.yaml -n signoz --create-namespace
            log_success "SignOz deployato con Helm"
        else
            log_warning "Helm non installato - SignOz non deployato"
        fi
    fi
    
    # 6. ROLLOUT RESTART DI TUTTI I DEPLOYMENT
    log_info "--- ROLLOUT RESTART ---"
    
    # Kafka namespace
    rollout_restart "zookeeper" "kafka"
    rollout_restart "kafka" "kafka"
    
    # Monitoring namespace
    rollout_restart "prometheus" "monitoring"
    rollout_restart "grafana" "monitoring"
    rollout_restart "otel-collector" "monitoring"
    
    # 7. ATTESA CHE TUTTO SIA PRONTO
    log_info "--- ATTESA COMPLETAMENTO DEPLOYMENT ---"
    
    # Attendi Kafka
    wait_for_deployments "kafka" "zookeeper" "kafka"
    
    # Attendi Monitoring
    wait_for_deployments "monitoring" "prometheus" "grafana" "otel-collector"
    
    # 8. VERIFICA FINALE
    log_info "--- VERIFICA FINALE ---"
    
    log_info "Stato dei pod:"
    kubectl get pods -n kafka
    kubectl get pods -n monitoring
    kubectl get pods -n signoz 2>/dev/null || log_warning "Namespace signoz non trovato"
    
    log_info "Stato dei servizi:"
    kubectl get svc -n kafka
    kubectl get svc -n monitoring
    kubectl get svc -n signoz 2>/dev/null || log_warning "Namespace signoz non trovato"
    
    log_success "=== DEPLOYMENT COMPLETATO CON SUCCESSO ==="
    log_info "Prometheus: http://localhost:30090"
    log_info "Grafana: http://localhost:30091"
    log_info "Kafka: localhost:9092"
    log_info "OTEL Collector: localhost:30092"
}

# Esecuzione script
main "$@"