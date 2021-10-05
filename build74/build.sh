#!/usr/bin/env bash

export IP=ocp.datr.eu
export APP=custom-sso
export PROJECT=$APP-build

oc login https://${IP}:8443 -u justin

oc delete project $PROJECT
oc new-project $PROJECT 2> /dev/null
while [ $? \> 0 ]; do
    sleep 1
    printf "."
oc new-project $PROJECT 2> /dev/null
done

oc project $PROJECT

oc create secret docker-registry quay-dockercfg \
  --docker-server=${QUAYIO_HOST} \
  --docker-username=${QUAYIO_USER} \
  --docker-password=${QUAYIO_PASSWORD} \
  --docker-email=${QUAYIO_EMAIL} \
  -n ${PROJECT}

oc apply -f docker-build-template.yaml \
    -p APPLICATION_NAME=custom-sso \
    -p SOURCE_REPOSITORY_URL="https://github.com/justindav1s/custom-sso.git" \
    -p SOURCE_REPOSITORY_REF="master" \
    -p DOCKERFILE_PATH="build" \
    -p DOCKERFILE_NAME="Dockerfile" \
    -n ${PROJECT}

oc start-build custom-sso-docker-build --follow

