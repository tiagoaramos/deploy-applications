#!/bin/bash

echo "🔍 Verificando configuração de autenticação do Harbor no Drone..."

# Verificar namespace
echo "📦 Verificando namespace drone-space..."
kubectl get namespace drone-space

# Verificar secrets
echo ""
echo "🔐 Verificando secrets..."
kubectl get secrets -n drone-space | grep harbor-secret
if [ $? -eq 0 ]; then
    echo "✅ Secret harbor-secret encontrado"
    kubectl describe secret harbor-secret -n drone-space
else
    echo "❌ Secret harbor-secret não encontrado"
fi

# Verificar configmaps
echo ""
echo "📋 Verificando configmaps..."
kubectl get configmaps -n drone-space | grep harbor-ca-cert
if [ $? -eq 0 ]; then
    echo "✅ ConfigMap harbor-ca-cert encontrado"
else
    echo "❌ ConfigMap harbor-ca-cert não encontrado"
fi

kubectl get configmaps -n drone-space | grep docker-daemon-config
if [ $? -eq 0 ]; then
    echo "✅ ConfigMap docker-daemon-config encontrado"
else
    echo "❌ ConfigMap docker-daemon-config não encontrado"
fi

# Verificar pods do Drone
echo ""
echo "🚁 Verificando pods do Drone..."
kubectl get pods -n drone-space

# Verificar se os pods estão usando os secrets corretos
echo ""
echo "🔍 Verificando configuração dos pods..."
echo "Drone Server:"
kubectl get deployment drone -n drone-space -o yaml | grep -A 5 imagePullSecrets

echo ""
echo "Drone Runner:"
kubectl get deployment drone-runner-kube -n drone-space -o yaml | grep -A 5 imagePullSecrets

# Verificar logs se houver problemas
echo ""
echo "📝 Logs do Drone Server (últimas 10 linhas):"
kubectl logs -n drone-space deployment/drone --tail=10

echo ""
echo "📝 Logs do Drone Runner (últimas 10 linhas):"
kubectl logs -n drone-space deployment/drone-runner-kube --tail=10

echo ""
echo "✅ Verificação concluída!"
echo ""
echo "💡 Para testar a autenticação com Harbor:"
echo "1. Crie um pipeline no Drone que faça pull de uma imagem do Harbor"
echo "2. Verifique se o build é executado com sucesso"
echo "3. Monitore os logs do Drone Runner durante o build"
