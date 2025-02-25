# CP Flink Infrastructure Deployment

## Operator and Helm Setup for CFK, FKO
```shell
helm upgrade --install confluent-operator confluentinc/confluent-for-kubernetes \
  --set namespaced=false \
  --set enableCMFDay2Ops=true \
  --namespace confluent

helm upgrade --install cp-flink-kubernetes-operator confluentinc/flink-kubernetes-operator \
  --set "watchNamespaces={confluent,flink}" \
  --namespace confluent
```

## CMF Deployment
CMF (Confluent Manager for Apache Flink) deployments are use-case specific - please use the installation instruction in the subdirectories.

## CP Deployments
Available deployment examples (one per subdirectory):
* minimal
* minimal with mTLS
* RBAC without LDAP
* mTLS-RBAC without LDAP (WIP)
* mTLS-RBAC with OAuth (WIP)
