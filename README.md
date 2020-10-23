# Steps for building the Jenkins Pipeline Components

```bash
export PROJECT="pipes"

bash ./create_jenkins.sh
```

# Steps for replicating it with Tekton

```bash
export PROJECT="pipes"
export POSTGRESQL_DATABASE="quotes"
export POSTGRESQL_USER="user"
export POSTGRESQL_PASSWORD="`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo ''`"
export external_imape_base_url="http://imagelookup.${PROJECT}.svc.cluster.local:8080"

cat ./app/manifests/backend/backend.yaml | envsubst | oc apply -f -

oc apply -f ./app/manifests/frontend
oc apply -f ./app/manifests/imagelookup

oc expose svc/frontend

```