#!/bin/sh

source k8s-setenv.sh

echo -------
echo bx target
bx target
echo -------
echo KUBECONFIG=$KUBECONFIG

echo Create services
# conversation
bx cf create-service conversation free my-conversation-service
# speech-to-text
bx cf create-service speech_to_text standard speech-to-text-service
# text-to-speech
bx cf create-service text_to_speech standard text-to-speech-service

echo Bind services to the cluster
bx cs cluster-service-bind $CLUSTER_NAME $KUBE_NAMESPACE my-conversation-service
bx cs cluster-service-bind $CLUSTER_NAME $KUBE_NAMESPACE speech-to-text-service
bx cs cluster-service-bind $CLUSTER_NAME $KUBE_NAMESPACE text-to-speech-service

echo Deploy the service to kubernetes
echo substitute deployment values from environment variables
sed s/\$TAG/$TAG/g k8s-car-dashboard.yml | \
sed s/\$REGISTRY_NAMESPACE/$REGISTRY_NAMESPACE/g | \
sed s/\$REGISTRY/$REGISTRY/g | \
sed s/\$IMAGE_NAME/$IMAGE_NAME/g | \
sed s/\$APP_NAME/$APP_NAME/g | \
kubectl --namespace $KUBE_NAMESPACE create -f -

# Echo description
kubectl --namespace $KUBE_NAMESPACE describe deployment car-dashboard
bx cs workers $CLUSTER_NAME

# Create Ingress
#kubectl apply -f k8s-car-dashboard-ingress.yml
