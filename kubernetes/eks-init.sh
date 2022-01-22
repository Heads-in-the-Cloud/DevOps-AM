#!/bin/bash

# switch context to EKS before running:
#   aws eks --region us-west-2 update-kubeconfig --name <NAME>
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

# grab load balancer endpoint
NEW_RECORD=kubectl get svc --namespace=nginx-ingress | awk 'NR==2{print $4}'

# hook up Route53
aws route53 change-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" \
  --change-batch '{"Changes":[{"Action":"UPSERT","ResourceRecordSet":{"Name":"'"$RECORD_NAME"'","Type":"CNAME","TTL":60,"ResourceRecords":[{"Value":"'"$NEW_RECORD"'"}]}}]}'

# exit
echo "Endpoint reachable at: '$RECORD_NAME'"
