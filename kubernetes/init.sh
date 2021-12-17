#!/bin/bash

# recreate cluster
kind delete cluster --name=api-cluster
kind create cluster --config=clusterconfig.yaml

# initialize ingress-nginx and clean up
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission

# create and move to new namespace
kubectl create namespace apis-ns
kubens apis-ns
kubectl apply -f secret.yaml

# load objects
cd objects && kubectl apply -f .
