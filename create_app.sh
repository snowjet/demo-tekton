#!/bin/bash

if [[ -z $1 ]] && [[ -z $PROJECT ]]; then
    echo "Pass project into script of set PROJECT env var"
    exit 1
fi

if [[ -z $PROJECT ]]; then
   export PROJECT="${1}"
fi

export POSTGRESQL_DATABASE="quotes"
export POSTGRESQL_USER="user"
export POSTGRESQL_PASSWORD="`head /dev/urandom | base64 | head -c 13 ; echo ''`"
export external_imape_base_url="http://imagelookup.${PROJECT}.svc.cluster.local:8080"

oc new-project "${PROJECT}"

cat ./app/manifests/backend/backend.yml | envsubst '${PROJECT} ${external_imape_base_url} ${POSTGRESQL_DATABASE} ${POSTGRESQL_USER} ${POSTGRESQL_PASSWORD}' | oc apply -n ${PROJECT} -f -

cat ./app/manifests/frontend/frontend.yml | envsubst '${PROJECT}' | oc apply -n ${PROJECT} -f -

oc apply -f ./app/manifests/imagelookup -n ${PROJECT}

oc expose svc/frontend -n ${PROJECT}