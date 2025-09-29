#!/bin/bash

minikube start

kubectl create namespace argocd

minikube addons enable ingress

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

sleep 30

docker network connect appwebdiario-network minikube

kubectl apply -f devops/argocd/argocd-application.yml

# Aplicar PVCs do ArgoCD
kubectl apply -f devops/argocd/argocd-pvc.yml

# Aplicar patch de armazenamento persistente do ArgoCD
kubectl apply -f devops/argocd/argocd-persistent-storage-patch.yml

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

kubectl create namespace drone-space

# Aplicar PVCs do Drone antes da aplicação
kubectl apply -f devops/drone/drone-pvc.yml

kubectl apply -f devops/drone/drone-application.yml

# Configurar Harbor secrets e configmaps
echo "🚀 Configurando Harbor secrets..."
./devops/harbor/setup-harbor-secrets.sh

# Aplicar PVCs do Harbor
kubectl apply -f devops/harbor/harbor-pvc.yml

kubectl apply -f applications/site/site-application.yml
