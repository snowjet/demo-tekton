#!/bin/bash

if [[ -z $1 ]] && [[ -z $PROJECT ]]; then
    echo "Pass project into script of set PROJECT env var"
    exit 1
fi

if [[ -z $PROJECT ]]; then
   export PROJECT="${1}"
fi

oc new-project "${PROJECT}"

cat ./tekton/pipeline-ws/*.yml | envsubst '${PROJECT}' | oc apply -n ${PROJECT} -f -

# There is a bug that requires this to be applied with the oc/kubectl create command
oc create -f ./tekton/pipeline-ws/pipelineRun.yml
