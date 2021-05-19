#!/bin/bash

if [[ -z $1 ]] && [[ -z $PROJECT ]]; then
    echo "Pass project into script of set PROJECT env var"
    exit 1
fi

if [[ -z $PROJECT ]]; then
   export PROJECT="${1}"
fi

oc new-app -n ${PROJECT} \
 -p DISABLE_ADMINISTRATIVE_MONITORS=true \
 -p MEMORY_LIMIT=2Gi \
 -p VOLUME_CAPACITY=4Gi \
 jenkins-persistent

oc set resources DeploymentConfigs jenkins --limits=cpu=2,memory=2Gi --requests=cpu=500m,memory=1Gi -n ${PROJECT}

oc apply -f ./jenkins/manifests/pipeline-bc.yml -n ${PROJECT}
oc apply -f ./jenkins/manifests/is-jnlp-agent-python.yml -n ${PROJECT}

# Set up ConfigMap with Jenkins Agent definition
oc create -f ./jenkins/manifests/agent-cm.yml -n ${PROJECT}

# ========================================
# No changes are necessary below this line
# Make sure that Jenkins is fully up and running before proceeding!
while : ; do
  echo "Checking if Jenkins is Ready..."
  AVAILABLE_REPLICAS=$(oc get dc jenkins -n ${PROJECT} -o=jsonpath='{.status.availableReplicas}')
  if [[ "$AVAILABLE_REPLICAS" == "1" ]]; then
    echo "...Yes. Jenkins is ready."
    break
  fi
  echo "...no. Sleeping 10 seconds."
  sleep 10
done
