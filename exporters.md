
      # OPZIONI ENDPOINT:
      # 
      # 1. SERVIZIO INTERNO (raccomandato per cluster Kubernetes):
      #    endpoint: "http://otel-kafka-proxy:8080"
      #    # Invia al servizio "otel-kafka-proxy" nel namespace monitoring
      #    # Il servizio deve esistere e essere raggiungibile
      #
      # 2. POD DIRETTO (per test/debug):
      #    endpoint: "http://10.244.0.123:8080"
      #    # Invia direttamente all'IP del pod specifico
      #    # IP dinamico, cambia ad ogni riavvio del pod
      #
      # 3. PORTA LOCALE (espone localmente):
      #    endpoint: "http://0.0.0.0:8080"
      #    # Espone su localhost del pod (come fa Prometheus)
      #    # Utile per debugging o per servizi nello stesso pod
      #
      # 4. SERVIZIO ESTERNO (per API esterne):
      #    endpoint: "http://api.example.com:8080"
      #    # Invia a servizio esterno al cluster
      #    # Richiede connessione internet e configurazione TLS
      #