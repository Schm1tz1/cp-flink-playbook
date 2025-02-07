# CP Flink Infrastructure Deployment

## Operator and Helm Setup for CFK, FKO, CMF
```shell
helm upgrade --install confluent-operator  confluentinc/confluent-for-kubernetes \
  --set namespaced=false \
  --set enableCMFDay2Ops=true \
  --namespace confluent

helm upgrade --install cp-flink-kubernetes-operator confluentinc/flink-kubernetes-operator \
  --set watchNamespaces={confluent} \
  --namespace confluent

# Note: These value overrides are for debugging. For normal operation you can sefely remove the lines with `--set` below
helm upgrade --install cmf confluentinc/confluent-manager-for-apache-flink \
  --set cmf.logging.level.root=debug \
  --set cmf.k8s.client-connection-timeout-msec=5000 \
  --set cmf.k8s.client-request-timeout-msec=5000 \
  --namespace confluent
```

## CP Deployments

Available deployment examples (one per subdirectory):
* minimal
* mTLS-RBAC (WIP)

### CP
```shell
kubectl apply -f cpf.yaml
```

### CMF Rest Class
* Deploy:
```shell
kubectl apply -f cmf-rest.yaml
```
