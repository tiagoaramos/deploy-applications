#!/bin/bash

set -e

echo "🚁 Deploy completo do Drone CI com autenticação Harbor..."

# Verificar se estamos no diretório correto
if [ ! -f "apply-harbor-auth.sh" ]; then
    echo "❌ Execute este script a partir do diretório devops/drone"
    exit 1
fi

# Aplicar configurações de autenticação do Harbor
echo "🔐 Aplicando configurações de autenticação do Harbor..."
./apply-harbor-auth.sh

# Aguardar um momento para os recursos serem criados
echo "⏳ Aguardando recursos serem criados..."
sleep 5

# Verificar se os recursos foram criados
echo "🔍 Verificando recursos criados..."
kubectl get secrets -n drone-space | grep harbor-secret
kubectl get configmaps -n drone-space | grep harbor-ca-cert
kubectl get configmaps -n drone-space | grep docker-daemon-config

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

# Verificar status final
echo "✅ Deploy concluído!"
echo ""
echo "🔍 Status dos pods:"
kubectl get pods -n drone-space

echo ""
echo "🔍 Status dos secrets e configmaps:"
kubectl get secrets,configmaps -n drone-space | grep -E "(harbor|docker)"

echo ""
echo "📋 Para acessar o Drone:"
echo "- kubectl port-forward svc/drone -n drone-space 8081:80"
echo "- Acesse: http://localhost:8081"
echo ""
echo "🔍 Para verificar logs:"
echo "- Drone Server: kubectl logs -n drone-space deployment/drone"
echo "- Drone Runner: kubectl logs -n drone-space deployment/drone-runner-kube"
