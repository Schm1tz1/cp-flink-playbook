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

## Keycloak Deployment
* Create OIDC credentials:
```shell
kubectl create secret generic oidccredential \
--from-file=oidcClientSecret.txt=oidcClientSecret.txt \
-n confluent
```

* Create OIDC Client secrets:
```shell
kubectl create secret generic oauth-jass \
--from-file=oauth.txt=oidcClientSecret.txt \
-n confluent
```

* Deploy Keycloak:
```shell
kubectl apply -f keycloak.yaml
```

## Deploy CP, C3 and Rolebindings
* Deploy minimal CP:
```shell
kubectl apply -f cp.yaml
```
Wait for brokers to be in running state.
* Deploy Rolebindings for test users:
```shell
kubectl apply -f rbac.yaml
```
* Deploy Controlcenter (C3):
```shell
kubectl apply -f c3.yaml
```

## Test C3 and log in with test user
Once Controlcenter is up and running, either add some ingress component or forward the port - e.g.:
```shell
kubectl port-forward -n confluent svc/controlcenter 9021:9021
```
Then point you browser to thre ingress URL or to `https://localhost:9021` - accept the self-signed certificate.
You can log in with the credentials from `fileUserPassword.txt` - for example user `testuser1` with password `password1`.
