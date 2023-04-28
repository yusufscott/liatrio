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
sleep 60
export SERVICE_IP=$(kubectl get svc --namespace default app --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
echo http://$SERVICE_IP:80