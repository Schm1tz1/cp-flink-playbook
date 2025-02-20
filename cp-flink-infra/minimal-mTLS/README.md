# CMF-Deployment with mTLS
```shell
helm upgrade --install cmf confluentinc/confluent-manager-for-apache-flink \
  --values cmf-values.yaml \
  --namespace confluent
```