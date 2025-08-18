# Setup Kafka su Kubernetes

## Prerequisiti
- Cluster Kubernetes attivo (Minikube)
- Namespace `kafka` creato

## Deploy

### Deploy completo (raccomandato)
```bash
kubectl apply -f cluster/kafka/deploy-all.yaml
```

### Deploy manuale (se necessario)
```bash
# 1. Crea il namespace
kubectl apply -f cluster/kafka/namespace-kafka.yaml

# 2. Deploy Zookeeper
kubectl apply -f cluster/kafka/configmap-zookeeper.yaml
kubectl apply -f cluster/kafka/pvc-zookeeper.yaml
kubectl apply -f cluster/kafka/deployment-zookeeper-simple.yaml
kubectl apply -f cluster/kafka/service-zookeeper.yaml

# 3. Deploy Kafka
kubectl apply -f cluster/kafka/pvc-kafka.yaml
kubectl apply -f cluster/kafka/deployment-kafka-final.yaml
kubectl apply -f cluster/kafka/service-kafka.yaml
```

## Verifica

### Controlla i pod
```bash
kubectl get pods -n kafka
```

### Controlla i servizi
```bash
kubectl get svc -n kafka
```

### Controlla i PVC
```bash
kubectl get pvc -n kafka
```

## Test

### Test interno (raccomandato)
```bash
# Lista topic
kubectl exec -n kafka deployment/kafka -- kafka-topics.sh --list --bootstrap-server localhost:9092

# Crea topic
kubectl exec -n kafka deployment/kafka -- kafka-topics.sh --create --topic my-topic --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1

# Produci messaggi
echo "Messaggio" | kubectl exec -i -n kafka deployment/kafka -- kafka-console-producer.sh --topic my-topic --bootstrap-server localhost:9092

# Consuma messaggi
kubectl exec -n kafka deployment/kafka -- kafka-console-consumer.sh --topic my-topic --bootstrap-server localhost:9092 --from-beginning
```

### Test con kafka-console-producer/consumer
```bash
# Crea un topic
kubectl exec -n kafka deployment/kafka -- kafka-topics --create --topic test-topic --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1

# Lista i topic
kubectl exec -n kafka deployment/kafka -- kafka-topics --list --bootstrap-server localhost:9092
```

## Porte
- **Kafka**: 9092 (interno)
- **Zookeeper**: 2181 (client), 2888 (server), 3888 (leader election)
- **JMX**: 9101

## Note
- Configurazione per sviluppo locale (1 replica)
- Storage persistente con PVC
- Risorse limitate per Minikube 