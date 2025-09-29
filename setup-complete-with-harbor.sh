#!/bin/bash

set -e

echo "🚀 Setup completo do cluster com Drone + Harbor integrados..."

# Verificar se estamos no diretório correto
if [ ! -f "setup.sh" ]; then
    echo "❌ Execute este script a partir do diretório raiz do projeto"
    exit 1
fi

# Executar setup principal
echo "📦 Executando setup principal..."
./setup.sh

# Verificação adicional
echo ""
echo "🔍 Verificação adicional da integração Harbor..."
cd devops/drone
./verify-harbor-auth.sh
cd ../..

echo ""
echo "🎯 Teste de conectividade com Harbor..."
echo "Para testar a autenticação com Harbor:"
echo "1. Acesse o Drone: kubectl port-forward svc/drone -n drone-space 8081:80"
echo "2. Crie um pipeline que faça pull de uma imagem do Harbor"
echo "3. Use as credenciais: deployer/D3ployer"
echo ""
echo "📋 Comandos úteis:"
echo "- Ver pods: kubectl get pods --all-namespaces"
echo "- Ver secrets Harbor: kubectl get secrets -n drone-space | grep harbor"
echo "- Ver logs Drone: kubectl logs -n drone-space deployment/drone"
echo "- Ver logs Runner: kubectl logs -n drone-space deployment/drone-runner-kube"
