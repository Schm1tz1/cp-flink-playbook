#!/bin/bash

# Flink SQL Client

echo "=== Flink SQL Client ==="
echo "Connecting to Flink session cluster..."
echo ""

# Check if the session cluster is running
POD=$(kubectl get pods -n flink -l app=flink-session-cluster,component=jobmanager -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$POD" ]; then
    echo "Error: No Flink session cluster found in namespace 'flink'"
    echo "Please ensure flink-session-cluster is deployed and running"
    exit 1
fi

echo "Found JobManager pod: $POD"
echo ""

echo "Creating SQL client configuration in pod..."
kubectl exec $POD -n flink -- bash -c 'cat > /tmp/sql-client-conf.yaml << '"'"'EOF'"'"'
################################################################################
# SQL Client Configuration
################################################################################

# Kafka connection defaults that can be used in CREATE TABLE statements
configuration:
  execution.checkpointing.interval: 10s
  execution.checkpointing.mode: EXACTLY_ONCE
  restart-strategy: fixed-delay
  restart-strategy.fixed-delay.attempts: 3
  restart-strategy.fixed-delay.delay: 10s
  
  # Default Kafka properties
  table.exec.sink.not-null-enforcer: drop
  
# Catalogs
catalogs:
  - name: default_catalog
    type: generic_in_memory

# Deployment
deployment:
  response-timeout: 10000
EOF'

echo ""
echo "Starting SQL Client..."
echo "================================================="
echo "Type 'QUIT;' or 'EXIT;' to exit the SQL client"
echo "================================================="
echo ""

# Start the SQL client
kubectl exec -it $POD -n flink -- /opt/flink/bin/sql-client.sh \
    embedded \
    --environment /tmp/sql-client-conf.yaml

echo ""
echo "SQL Client session ended."