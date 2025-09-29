#!/bin/bash

# Script para configurar os secrets e configmaps do Harbor nos namespaces necessários

echo "🚀 Configurando secrets e configmaps do Harbor..."

# Aplicar secrets do Harbor no namespace drone-space
echo "📦 Aplicando secrets no namespace drone-space..."
kubectl apply -f /home/tiago/workspace/devops/deploy-applications/devops/harbor/harbor-image-pull-secret-drone-space.yaml
kubectl apply -f /home/tiago/workspace/devops/deploy-applications/devops/harbor/harbor-ca-cert-configmap-drone-space.yaml

# Aplicar secrets do Harbor no namespace site-space
echo "📦 Aplicando secrets no namespace site-space..."
kubectl apply -f /home/tiago/workspace/devops/deploy-applications/devops/harbor/harbor-image-pull-secret-site-space.yaml

# Configurar service accounts para usar os image pull secrets
echo "🔧 Configurando service accounts..."

# Configurar service account no namespace drone-space
kubectl patch serviceaccount default -n drone-space -p '{"imagePullSecrets": [{"name": "harbor-secret"}]}' || echo "Service account no drone-space já configurado"

# Configurar service account no namespace site-space
kubectl patch serviceaccount default -n site-space -p '{"imagePullSecrets": [{"name": "harbor-secret"}]}' || echo "Service account no site-space já configurado"

echo "✅ Configuração do Harbor concluída!"
echo "📋 Secrets e ConfigMaps aplicados nos namespaces:"
echo "   - drone-space: harbor-secret, harbor-ca-cert"
echo "   - site-space: harbor-secret"
echo "   - Service accounts configurados para usar os secrets"
