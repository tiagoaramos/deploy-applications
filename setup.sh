#!/bin/bash

set -e

echo "🚀 Iniciando setup do cluster com persistência..."

# Iniciar minikube
echo "📦 Iniciando minikube..."
minikube start

# Habilitar addons necessários
echo "🔧 Habilitando addons..."
minikube addons enable ingress

kubectl apply -f persistent-volumes.yml

# Conectar rede Docker
echo "🌐 Conectando rede Docker..."
docker network connect appwebdiario-network minikube || true

kubectl create namespace argocd
devops/certificates/global-tls/apply-secret.sh argocd

# Instalar ArgoCD via Helm
echo "🔧 Instalando ArgoCD via Helm..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Aguardar ArgoCD ficar pronto
echo "⏳ Aguardando ArgoCD ficar pronto..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Mostrar senha do ArgoCD
echo "🔑 Senha do ArgoCD:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
kubectl apply -f devops/argocd/argocd-application.yml

# Instalar Drone CI
echo "🚁 Instalando Drone CI..."
kubectl create namespace drone-space
devops/certificates/global-tls/apply-secret.sh drone-space
kubectl apply -f devops/drone/drone-application.yml

kubectl create namespace harbor
devops/certificates/global-tls/apply-secret.sh harbor

helm install harbor harbor/harbor \
  --namespace harbor \
  --set expose.ingress.hosts.core=harbor.appwebdiario.com.br \
  --set externalURL=https://harbor.appwebdiario.com.br \
  --set harborAdminPassword="Harbor12345" \
  --set tls.enabled=true \
  --set tls.certSource=auto \
  --set tls.secret.secretName=global-tls-secret \
  --set persistence.enabled=true \
  --set persistence.resourcePolicy=keep

kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=harbor -n harbor --timeout=300s

# Instalar aplicação Site

echo "✅ Setup concluído com sucesso!"
echo ""
echo "📋 Serviços disponíveis:"
echo "- ArgoCD: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "- Drone: kubectl port-forward svc/drone -n drone-space 8081:80"
echo ""
echo "🔍 Verificar status:"
echo "- kubectl get pods --all-namespaces"
echo "- kubectl get pvc --all-namespaces"
echo "- kubectl get pv"
