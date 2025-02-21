# Troubleshooting, Debugging

## Certificates
* Check specific certs and CN:
```shell
kubectl get secret -n confluent tls-client-alice -o json | \
  jq -r '.data."tls.crt"' | \
  base64 -d | \
  openssl x509 | grep 'Subject' -A1-text
```

## CMF
* Enable debug logging (and longer connection timeouts) in `values.yaml`:
```yaml
cmf:
  logging:
    level:
      root: debug
  k8s:
    client-connection-timeout-msec: 5000
    client-connection-request-msec: 5000
```
or via `--set` in helm:
```shell
helm upgrade --install cmf confluentinc/confluent-manager-for-apache-flink \
  --set cmf.logging.level.root=debug \
  --set cmf.k8s.client-connection-timeout-msec=5000 \
  --set cmf.k8s.client-request-timeout-msec=5000 \
  --namespace confluent
```

## MDS (CP)
* Set MDS logging to DEBUG level via override in Kafka CR:
```yaml
spec:
  configOverrides:
    log4j:
      - log4j.logger.io.confluent.security.auth=TRACE, metadataServiceAppender
      - log4j.logger.io.confluent.rbacapi=TRACE, metadataServiceAppender
      - log4j.logger.io.confluent.security.store=TRACE, metadataServiceAppender
      - log4j.logger.io.confluent.rest-utils=TRACE, metadataServiceAppender
      - log4j.logger.io.confluent.tokenapi=TRACE, metadataServiceAppender
      - log4j.logger.io.confluent.common.security.jetty=TRACE, metadataServiceAppender
```
