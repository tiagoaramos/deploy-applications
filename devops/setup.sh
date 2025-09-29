#!/bin/bash

minikube start

kubectl create namespace argocd

minikube addons enable ingress

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

sleep 30

docker network connect appwebdiario-network minikube

kubectl apply -f devops/argocd/argocd-application.yml

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

kubectl create namespace drone-space

# Aplicar configurações de autenticação do Harbor para o Drone
echo "🔐 Configurando autenticação do Drone com Harbor..."
cd drone
./apply-harbor-auth.sh

# Aguardar recursos serem criados
echo "⏳ Aguardando recursos do Harbor serem criados..."
sleep 5

# Deploy do Drone Server
echo "🚀 Deploy do Drone Server..."
helm upgrade --install drone ./drone-helm/charts/drone \
    -f ./drone-helm/charts/drone/values.yaml \
    --namespace drone-space \
    --create-namespace

# Aguardar o Drone Server ficar pronto
echo "⏳ Aguardando Drone Server ficar pronto..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=drone -n drone-space --timeout=300s

# Deploy do Drone Runner
echo "🏃 Deploy do Drone Runner..."
helm upgrade --install drone-runner-kube ./drone-helm/charts/drone-runner-kube \
    -f ./drone-helm/charts/drone-runner-kube/values.yaml \
    --namespace drone-space

# Aguardar o Drone Runner ficar pronto
echo "⏳ Aguardando Drone Runner ficar pronto..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=drone-runner-kube -n drone-space --timeout=300s

cd ..

# Aplicar aplicação do Drone no ArgoCD
kubectl apply -f devops/drone/drone-application.yml


kubectl apply -f applications/site/site-application.yml
