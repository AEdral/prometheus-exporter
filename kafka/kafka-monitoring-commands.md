# Comandi Kafka per Monitoraggio Messaggi

## Verificare messaggi nel topic

### Contare messaggi
```bash
kubectl exec -it kafka-8984fc869-xf9hj -n kafka -- kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list localhost:9092 --topic otel-metrics
```

### Leggere ultimi messaggi
```bash
kubectl exec -it kafka-8984fc869-xf9hj -n kafka -- kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic otel-metrics --max-messages 5 --timeout-ms 10000
```

### Monitorare in tempo reale
```bash
kubectl exec -it kafka-8984fc869-xf9hj -n kafka -- kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic otel-metrics --from-beginning
```

### Stato topic
```bash
kubectl exec -it kafka-8984fc869-xf9hj -n kafka -- kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic otel-metrics
``` 