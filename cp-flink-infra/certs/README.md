# Example Certificate Setup with Certificate Manager
This provides a full set of self-signed certificates to be used with the test setups.
Steps to install:
* Install Certificate Manger:
```shell
helm repo add jetstack https://charts.jetstack.io --force-update

helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --set 'extraArgs={--dns01-recursive-nameservers-only,--dns01-recursive-nameservers=8.8.8.8:53\,1.1.1.1:53}' \
  --set installCRDs=true
```

* Deploy issuers and certificates
```shell
kubectl apply -f issuer.yaml
kubectl apply -f certs.yaml
```

* (optional) Install and deploy Trust Manager and generate truststore:
```shell
helm upgrade trust-manager jetstack/trust-manager   --install   --namespace cert-manager   --wait
kubectl apply -f truststore.yaml
```


 