#!/bin/bash

(
  # create basic ingress framework
  cd init
  kubectl apply -f ns-sa.yaml
  kubens nginx-ingress
  kubectl apply -f default-server-secret.yaml

  # create ingress custom configs
  cd ../eks-custom
  kubectl apply -f .

  # create ingress control items
  cd ../eks-config
  kubectl apply -f .

  # wait for ingress to finish
  kubectl wait --namespace nginx-ingress \
    --for=condition=ready pod \
    --selector=app.component=controller \
    --timeout=180s
)

# create and move to new namespace
kubectl create ns apis-ns
kubens apis-ns
kubectl apply -f secret.yaml

# load objects
cd objects && kubectl apply -f .
