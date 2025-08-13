kubectl create namespace monitoring

kubectl apply -f cluster/prometheus/
kubectl apply -f cluster/grafana/

kubectl get svc -n monitoring grafana

kubectl port-forward -n monitoring service/prometheus 9090:9090

kubectl port-forward -n monitoring service/grafana 3000:3000