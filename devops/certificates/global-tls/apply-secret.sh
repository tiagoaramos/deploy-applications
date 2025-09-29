#!/bin/bash

# Script para aplicar o Secret TLS no Kubernetes
# Uso: ./apply-secret.sh [namespace]

set -e

NAMESPACE=${1:-default}
SECRET_NAME="global-tls-secret"

echo "Aplicando Secret TLS no namespace: $NAMESPACE"

# Verificar se os arquivos de certificado existem
if [ ! -f "./devops/certificates/global-tls/tls.crt" ] || [ ! -f "./devops/certificates/global-tls/tls.key" ]; then
    echo "❌ Erro: Arquivos tls.crt e tls.key não encontrados!"
    echo "   Renomeie os arquivos .example para .crt e .key"
    echo "   Ou gere novos certificados com:"
    echo "   openssl req -x509 -newkey rsa:4096 -keyout tls.key -out tls.crt -days 365 -nodes \\"
    echo "     -subj \"/C=BR/ST=SP/L=SaoPaulo/O=DevOps/OU=IT/CN=*.local\""
    exit 1
fi

# Verificar se kubectl está disponível
if ! command -v kubectl &> /dev/null; then
    echo "❌ Erro: kubectl não encontrado!"
    echo "   Instale o kubectl e configure o acesso ao cluster"
    exit 1
fi

# Criar o namespace se não existir
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Aplicar o Secret
echo "📝 Criando Secret TLS..."
kubectl create secret tls "$SECRET_NAME" \
  --cert=./devops/certificates/global-tls/tls.crt \
  --key=./devops/certificates/global-tls/tls.key \
  --namespace="$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "✅ Secret '$SECRET_NAME' aplicado com sucesso no namespace '$NAMESPACE'"

# Verificar o Secret
echo "🔍 Verificando Secret..."
kubectl get secret "$SECRET_NAME" -n "$NAMESPACE"

echo ""
echo "📋 Para usar em um Ingress, adicione:"
echo "spec:"
echo "  tls:"
echo "  - hosts:"
echo "    - seu-dominio.com"
echo "    secretName: $SECRET_NAME"
