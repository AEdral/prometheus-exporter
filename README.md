# Sistema di Monitoring Kubernetes con OpenTelemetry

## Panoramica

Questo progetto implementa un sistema di monitoring completo per cluster Kubernetes utilizzando **OpenTelemetry Collector** come hub centrale per la raccolta e distribuzione delle metriche.

## Architettura del Sistema

### Diagramma Compatto (Overview)

```mermaid
graph LR
    %% Stile semplificato
    classDef k8s fill:#326ce5,stroke:#333,color:#fff
    classDef otel fill:#ff6b35,stroke:#333,color:#fff
    classDef backend fill:#e6522c,stroke:#333,color:#fff
    classDef cloud fill:#ff6b6b,stroke:#333,color:#fff

    %% Kubernetes Cluster (semplificato)
    subgraph "K8S CLUSTER"
        K8S[Nodes<br/>cAdvisor + kubelet]
    end

    %% OTEL Collector (centro)
    OTEL[OTEL Collector<br/>Processing Hub]

    %% Backend Locali
    subgraph "LOCAL BACKENDS"
        PROM[Prometheus<br/>:9090]
        GRAF[Grafana<br/>:3000]
    end

    %% Backend OTLP
    subgraph "OTLP BACKENDS"
        OTLP_GRPC[OTLP/gRPC<br/>:4317]
        OTLP_HTTP[OTLP/HTTP<br/>:4318]
    end

    %% Cloud Providers (semplificato)
    subgraph "CLOUD SYSTEMS"
        CLOUD[Cloud Providers<br/>AWS, GCP, Azure, etc.]
    end

    %% Flussi principali
    K8S -->|HTTPS| OTEL
    OTEL -->|HTTP :9464| PROM
    OTEL -->|OTLP/gRPC| OTLP_GRPC
    OTEL -->|OTLP/HTTP| OTLP_HTTP
    PROM -->|PromQL| GRAF
    OTLP_GRPC --> CLOUD
    OTLP_HTTP --> CLOUD

    %% Applicazione classi
    class K8S k8s
    class OTEL otel
    class PROM,GRAF,OTLP_GRPC,OTLP_HTTP backend
    class CLOUD cloud
```
## Porte e Protocolli

| Componente | Porta Interna | Porta Esterna | Protocollo | Scopo |
|------------|----------------|----------------|------------|-------|
| **cAdvisor** | `:4194` | - | HTTPS | Metriche container |
| **kubelet** | `:10250` | - | HTTPS | Metriche nodo |
| **OTEL Collector** | `:9464` | `localhost:9464` | HTTP | API metriche |
| **Prometheus** | `:9090` | `localhost:9090` | HTTP | UI + API |
| **Grafana** | `:3000` | `localhost:3000` | HTTP | Dashboard |
| **OTLP/gRPC** | - | - | gRPC | Export verso Kafka |
| **OTLP/HTTP** | - | - | HTTP | Export verso SigNoz |




## Diagramma Architetturale Completo

```mermaid
graph TB
    %% Stile e definizioni
    classDef k8sNode fill:#326ce5,stroke:#333,stroke-width:2px,color:#fff
    classDef otel fill:#ff6b35,stroke:#333,stroke-width:2px,color:#fff
    classDef prometheus fill:#e6522c,stroke:#333,stroke-width:2px,color:#fff
    classDef grafana fill:#f46800,stroke:#333,stroke-width:2px,color:#fff
    classDef otlpBackend fill:#00d4aa,stroke:#333,stroke-width:2px,color:#fff
    classDef cloud fill:#ff6b6b,stroke:#333,stroke-width:2px,color:#fff
    classDef external fill:#a8e6cf,stroke:#333,stroke-width:2px,color:#000

    %% Kubernetes Cluster
    subgraph "KUBERNETES CLUSTER"
        subgraph "NODE 1"
            N1[Node 1<br/>192.168.58.2]
            N1_cAdvisor[cAdvisor<br/>:4194]
            N1_kubelet[kubelet<br/>:10250]
        end
        
        subgraph "NODE 2"
            N2[Node 2<br/>192.168.58.3]
            N2_cAdvisor[cAdvisor<br/>:4194]
            N2_kubelet[kubelet<br/>:10250]
        end
        
        subgraph "NODE N"
            NN[Node N<br/>192.168.58.x]
            NN_cAdvisor[cAdvisor<br/>:4194]
            NN_kubelet[kubelet<br/>:10250]
        end
    end

    %% OpenTelemetry Collector
    subgraph "NAMESPACE: monitoring"
        subgraph "OTEL COLLECTOR (HUB CENTRALE)"
            OTEL[OpenTelemetry Collector<br/>Processing + Enrichment]
            OTEL_SVC[Service: otel-collector<br/>ClusterIP: 9464]
        end
    end

    %% Prometheus
    subgraph "NAMESPACE: monitoring"
        PROM[Prometheus<br/>:9090]
        PROM_SVC[Service: prometheus<br/>ClusterIP: 9090]
        GRAF[Grafana<br/>:3000]
        GRAF_SVC[Service: grafana<br/>ClusterIP: 3000]
    end

    %% Sistemi Esterni che si connettono a OTEL
    subgraph "EXTERNAL SYSTEMS"
        KAFKA[Kafka<br/>OTLP/gRPC Client]
        GRAFANA_EXT[Grafana Esterno<br/>OTLP/HTTP Client]
        CLOUD_SYS[Cloud Systems<br/>AWS, GCP, Azure]
    end



    %% Port Forwarding per accesso esterno
    EXT_PROM[Port Forward<br/>localhost:9090]
    EXT_GRAF[Port Forward<br/>localhost:3000]
    EXT_OTEL[Port Forward<br/>localhost:9464]

    %% Flussi di dati
    %% Da cAdvisor a OTEL
    N1_cAdvisor -->|HTTPS :4194/metrics/cadvisor| OTEL
    N2_cAdvisor -->|HTTPS :4194/metrics/cadvisor| OTEL
    NN_cAdvisor -->|HTTPS :4194/metrics/cadvisor| OTEL

    %% Da kubelet a OTEL
    N1_kubelet -->|HTTPS :10250/metrics| OTEL
    N2_kubelet -->|HTTPS :10250/metrics| OTEL
    NN_kubelet -->|HTTPS :10250/metrics| OTEL

    %% Da OTEL a sistemi locali ed esterni
    OTEL -->|HTTP :9464/metrics| PROM
    OTEL -->|OTLP/gRPC| KAFKA
    OTEL -->|OTLP/HTTP| GRAFANA_EXT

    %% Da Prometheus a Grafana
    PROM -->|PromQL Queries| GRAF

    %% Cloud systems ricevono dati da OTEL
    OTEL -->|OTLP/gRPC| CLOUD_SYS
    OTEL -->|OTLP/HTTP| CLOUD_SYS

    %% Port forwarding per accesso esterno
    PROM_SVC --> EXT_PROM
    GRAF_SVC --> EXT_GRAF
    OTEL_SVC --> EXT_OTEL

    %% Applicazione delle classi
    class N1,N2,NN,N1_cAdvisor,N2_cAdvisor,NN_cAdvisor,N1_kubelet,N2_kubelet,NN_kubelet k8sNode
    class OTEL,OTEL_SVC otel
    class PROM,PROM_SVC prometheus
    class GRAF,GRAF_SVC grafana
    class KAFKA,GRAFANA_EXT,CLOUD_SYS cloud
    class EXT_PROM,EXT_GRAF,EXT_OTEL external
```

---


## Flusso dei Dati Completo

### **1. Raccolta Metriche (Sources)**
- **cAdvisor** su ogni nodo espone metriche su `:4194/metrics/cadvisor`
- **kubelet** su ogni nodo espone metriche su `:10250/metrics`
- **OpenTelemetry Collector** raccoglie queste metriche via HTTPS

### **2. Elaborazione (Processing)**
- **OTEL Collector** standardizza e processa le metriche
- **Batch processing** per ottimizzazione
- **Memory limiting** per gestione risorse
- **Relabeling** per organizzazione dati

### **3. Esportazione (Export)**
- **OTEL Collector** espone metriche su `:9464/metrics` per Prometheus
- **OTEL Collector** esporta metriche via OTLP/gRPC verso Kafka
- **OTEL Collector** esporta metriche via OTLP/HTTP verso SigNoz
- **Prometheus** memorizza e fornisce API query su `:9090`

### **4. Visualizzazione (Visualization)**
- **Grafana** si connette a Prometheus per query
- **Grafana** espone dashboard su `:3000`
- **Port forwarding** per accesso esterno
