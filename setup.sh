#!/bin/bash

set -e

echo "🚀 Iniciando setup do cluster com persistência..."

# Iniciar minikube
echo "📦 Iniciando minikube..."
minikube start

# Habilitar addons necessários
echo "🔧 Habilitando addons..."
minikube addons enable ingress

kubectl create namespace argocd
kubectl create namespace drone-space
kubectl create namespace harbor
kubectl apply -f persistent-volumes.yml

# Conectar rede Docker
echo "🌐 Conectando rede Docker..."
docker network connect appwebdiario-network minikube || true


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

echo "⏳ Aguardando Harbor ficar pronto..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=harbor -n harbor --timeout=300s


# Instalar Drone CI
echo "🚁 Instalando Drone CI..."

devops/certificates/global-tls/apply-secret.sh drone-space

# Aplicar configurações de autenticação do Harbor para o Drone
echo "🔐 Configurando autenticação do Drone com Harbor..."
cd devops/drone
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

cd ../..

# Aplicar aplicação do Drone no ArgoCD
kubectl apply -f devops/drone/drone-application.yml



# Instalar aplicação Site

# Verificação final do Drone com Harbor
echo "🔍 Verificando configuração do Drone com Harbor..."
cd devops/drone
./verify-harbor-auth.sh
cd ../..

echo "✅ Setup concluído com sucesso!"
echo ""
echo "📋 Serviços disponíveis:"
echo "- ArgoCD: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "- Drone: kubectl port-forward svc/drone -n drone-space 8081:80"
echo "- Harbor: kubectl port-forward svc/harbor -n harbor 8082:80"
echo ""
echo "🔐 Configuração Harbor:"
echo "- Usuário: deployer"
echo "- Senha: D3ployer"
echo "- Registry: harbor.appwebdiario.com.br"
echo ""
echo "🔍 Verificar status:"
echo "- kubectl get pods --all-namespaces"
echo "- kubectl get pvc --all-namespaces"
echo "- kubectl get pv"
echo "- kubectl get secrets,configmaps -n drone-space | grep harbor"
