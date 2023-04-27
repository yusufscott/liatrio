#!/bin/bash
brew install jq terraform helm
export AWS_ACCOUNT=$(aws sts get-caller-identity | jq -r .Account)
terraform apply -auto-approve
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT}.dkr.ecr.us-east-1.amazonaws.com
docker build -t liatrio.app .
docker tag liatrio.app:latest ${AWS_ACCOUNT}.dkr.ecr.us-east-1.amazonaws.com/liatrio.app:latest
docker push ${AWS_ACCOUNT}.dkr.ecr.us-east-1.amazonaws.com/liatrio.app:latest
aws eks update-kubeconfig --name liatrio-cluster --region=us-east-1
helm install app ./app
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=app,app.kubernetes.io/instance=app" -o jsonpath="{.items[0].metadata.name}")
export CONTAINER_PORT=$(kubectl get pod --namespace default $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
echo "Visit http://127.0.0.1:8080 to use your application"
kubectl --namespace default port-forward $POD_NAME 8080:$CONTAINER_PORT
