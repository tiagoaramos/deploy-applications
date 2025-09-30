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
kubectl create namespace harbor
kubectl create namespace drone
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
argocd_password=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo $argocd_password
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

# Instalar aplicação drone

kubectl create secret docker-registry docker-registry \
  --docker-server=harbor.appwebdiario.com.br \
  --docker-username=deployer \
  --docker-password=D3ployer \
  --docker-email=deployer@appwebdiario.com.br \
  --namespace default


devops/certificates/global-tls/apply-secret.sh drone

helm install --namespace drone drone drone/drone -f devops/drone/drone/values.yaml
helm install --namespace drone drone-runner-docker drone/drone-runner-docker -f devops/drone/drone-runner-docker/values.yaml
helm install --namespace drone drone-kubernetes-secrets drone/drone-kubernetes-secrets -f devops/drone/drone-kubernetes-secrets/values.yaml

echo "⏳ Aguardando Drone ficar pronto..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=drone -n drone --timeout=300s



curl -X 'POST' \
  'https://harbor.appwebdiario.com.br/api/v2.0/projects' \
  -H 'accept: application/json' \
  -H 'authorization: Basic YWRtaW46SGFyYm9yMTIzNDU=' \
  -H 'Content-Type: application/json' \
  -d '{
    "project_name": "appwebdiario",
    "public": false,
    "metadata": {
        "public": "false",
        "enable_content_trust": "false",
        "enable_content_trust_cosign": "false"
    },
    "storage_limit": 0
}
'
curl -X 'POST' \
  'https://harbor.appwebdiario.com.br/api/v2.0/users' \
  -H 'accept: application/json' \
  -H 'authorization: Basic YWRtaW46SGFyYm9yMTIzNDU=' \
  -H 'Content-Type: application/json' \
  -H 'X-Harbor-CSRF-Token: XNRs5dz5Mkrju8/R7g32cgZK8nWmNjzBWJxwrUKYnvMPXHmbrpHBFKOplfsCqr1LCQcxgS+XecGzNsYniKfUog==' \
  -d '{
  "email": "deployer@appwebdiario.com.br",
  "realname": "Deployer",
  "comment": "deployer",
  "password": "D3ployer",
  "username": "deployer"
}'

curl -X 'PUT' \
  'https://harbor.appwebdiario.com.br/api/v2.0/users/3/sysadmin' \
  -H 'accept: application/json' \
  -H 'authorization: Basic YWRtaW46SGFyYm9yMTIzNDU=' \
  -H 'Content-Type: application/json' \
  -H 'X-Harbor-CSRF-Token: vfJQjYow9YNyg9EuCiKTy3KzlOc8XOukBxT4FQ+jKp7uekXz+FgG3TKRiwTmhdjyff5XE7X9rqTsvk6fxZxgzw==' \
  -d '{
  "sysadmin_flag": true
}'

docker push harbor.appwebdiario.com.br/appwebdiario/docker-build:latest
docker push harbor.appwebdiario.com.br/appwebdiario/pipeline-base-module:latest

echo "✅ Setup concluído com sucesso!"
echo "🔐 Configuração ArgoCD:"
echo "- URL: https://argocd.appwebdiario.com.br"
echo "- Usuário: admin"
echo "- Senha: $argocd_password"
echo ""
echo "🔐 Configuração Harbor:"
echo "- URL: https://harbor.appwebdiario.com.br"
echo "- Usuário: deployer"
echo "- Senha: D3ployer"
echo ""
echo "🔐 Configuração Drone:"
echo "- URL: https://drone.appwebdiario.com.br"
