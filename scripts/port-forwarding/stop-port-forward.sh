#!/bin/bash

# ========================================
# STOP PORT-FORWARDING PER CLUSTER KUBERNETES
# ========================================
# Questo script ferma tutti i port-forwarding attivi

echo "🛑 Fermando tutti i port-forwarding attivi..."

# Ferma tutti i processi kubectl port-forward
echo "   🔍 Cercando processi kubectl port-forward..."
pkill -f "kubectl port-forward" || true

# Aspetta un momento per permettere ai processi di terminare
sleep 2

# Verifica se ci sono ancora processi attivi
REMAINING=$(ps aux | grep "kubectl port-forward" | grep -v grep | wc -l)

if [ "$REMAINING" -eq 0 ]; then
    echo "   ✅ Tutti i port-forwarding sono stati fermati"
else
    echo "   ⚠️  Ancora $REMAINING processi attivi, forzando la chiusura..."
    pkill -9 -f "kubectl port-forward" || true
    sleep 1
fi

# Rimuovi il file dei PID se esiste
if [ -f "cluster/scripts/port-forwarding/port-forward-pids.txt" ]; then
    rm -f cluster/scripts/port-forwarding/port-forward-pids.txt
    echo "   🗑️  File PID rimosso"
fi

# Verifica finale
FINAL_CHECK=$(ps aux | grep "kubectl port-forward" | grep -v grep | wc -l)

if [ "$FINAL_CHECK" -eq 0 ]; then
    echo ""
    echo "🎯 TUTTI I PORT-FORWARDING SONO STATI FERMATI!"
    echo "================================================"
    echo "✅ Cluster tornato allo stato normale"
    echo ""
    echo "💡 Per riavviare i port-forwarding:"
echo "   ./cluster/scripts/port-forwarding/auto-port-forward.sh"
else
    echo ""
    echo "⚠️  ATTENZIONE: Alcuni processi potrebbero essere ancora attivi"
    echo "==============================================================="
    echo "🔍 Processi rimanenti:"
    ps aux | grep "kubectl port-forward" | grep -v grep
    echo ""
    echo "💡 Prova a riavviare il terminale o usa:"
    echo "   pkill -9 -f 'kubectl port-forward'"
fi 