# RBAC-Setup with mTLS without IdP/LDAP/OAuth

## Create Certificates, Keys and Secrets
* Deploy Issuer ans Certificate CRs:
```shell
kubectl apply -f ../certs/issuer.yaml
kubectl apply -f ../certs/certs.yaml
```
* Create RSA keypair for MDS token generations:
```shell
openssl genrsa -out mds-keypair-priv.pem 2048
openssl rsa -in mds-keypair-priv.pem -outform PEM -pubout -out mds-keypair-pub.pem
kubectl create secret generic mds-token \
--from-file=mdsPublicKey.pem=mds-keypair-pub.pem \
--from-file=mdsTokenKeyPair.pem=mds-keypair-priv.pem \
-n confluent
```

* Create file-based credentials:
```shell
# Create credentials for SASL clients
kubectl create secret generic credential \
  --from-file=plain-users.json=./creds-kafka-sasl-users.json \
  --from-file=plain.txt=./creds-client-kafka-sasl-user.txt \
  --namespace confluent
    
# Create MDS users
kubectl create secret generic file-secret \
--from-file=userstore.txt=fileUserPassword.txt \
-n confluent

# Kafka RBAC credential
kubectl create secret generic kafka-client \
--from-file=bearer.txt=bearer.txt \
--namespace confluent

# Kafka REST credential
kubectl create secret generic rest-credential \
--from-file=bearer.txt=bearer.txt \
--from-file=basic.txt=creds-client-kafka-sasl-user.txt \
--namespace confluent
```

## Deploy CP and CMF Rolebindings
* Deploy minimal CP:
```shell
kubectl apply -f cp.yaml
```
Wait for brokers to be in running state.
* Deploy Rolebindings for CMF user:
```shell
kubectl apply -f cmf-rolebindings.yaml
```

## CMF Configuration and Deployment
* Deploy CMF:
```shell
helm upgrade --install cmf confluentinc/confluent-manager-for-apache-flink \
  --values cmf-values.yaml \
  --namespace confluent
```
* Deploy rolebindings for different users (Alice, Bob, Sudo):
```shell
kubectl apply -f user-rolebindings.yaml
```

* Deploy CMF Rest Class references that correspond to the diferent CMF users:
```shell
kubectl apply -f cmf-rest-alice.yaml
kubectl apply -f cmf-rest-bob.yaml
kubectl apply -f cmf-rest-sudo.yaml
```
Each `CMFRestClass` instance corresponds to a connection to CMF/CP-Flink with a different user.
The Rolebindings are configured in a way that sudo as a cluster admin can create/delete FlinkEnvironments and FlinkApplications, alice can manage Applications in the environment `flink-env1` and bob can only read/list applications in `flink-env1`.
