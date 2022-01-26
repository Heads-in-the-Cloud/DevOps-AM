#!/bin/bash

# subscript a bunch of directory changes and wait
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

# create and move to API-specific namespace
kubectl create ns apis-ns
kubens apis-ns

# inject secrets from environment
kubectl create secret generic utopia-secret \
  --from-literal=DB_NAME=utopia \
  --from-literal=DB_PORT=3306 \
  --from-literal=DB_TYPE=mysql \
  --from-literal=DB_ADDRESS="${AWS_RDS_ENDPOINT}" \
  --from-literal=DB_USERNAME="${AWS_RDS_USERNAME}" \
  --from-literal=DB_PASSWORD="${AWS_RDS_PASSWORD}"

# load and update API and Ingress objects
# TODO: parameterize
cd objects
for f in $(find .); do envsubst < $f | kubectl apply -f -; done

# fetch load balancer endpoint
LB_ADDRESS=$(kubectl get svc --namespace=nginx-ingress | awk 'NR==2{print $4}')

# hook up Route53 to loadbalancer
aws route53 change-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" \
  --change-batch '{"Changes":[{"Action":"UPSERT","ResourceRecordSet":{"Name":"'"$RECORD_NAME"'","Type":"CNAME","TTL":60,"ResourceRecords":[{"Value":"'"$LB_ADDRESS"'"}]}}]}'

# info and exit
echo "Balancer Address: '$LB_ADDRESS'"
echo "Endpoint reachable at: '$RECORD_NAME'"
