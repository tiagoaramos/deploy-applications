#!/bin/bash

# Script para aplicar configurações de armazenamento persistente
# Autor: Tiago Ramos
# Data: $(date)

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log "🚀 Aplicando configurações de armazenamento persistente..."

# Verificar se kubectl está disponível
if ! command -v kubectl &> /dev/null; then
    error "kubectl não está instalado ou não está no PATH"
    exit 1
fi

# Verificar se o cluster está acessível
if ! kubectl cluster-info &> /dev/null; then
    error "Não é possível acessar o cluster Kubernetes"
    exit 1
fi

log "Cluster Kubernetes acessível ✅"

# Criar namespaces se não existirem
log "Criando namespaces necessários..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace drone-space --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace harbor --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace site-space --dry-run=client -o yaml | kubectl apply -f -

# Aplicar StorageClass
log "Aplicando StorageClass..."
kubectl apply -f persistent-volumes.yml

# Aguardar um momento para os recursos serem criados
sleep 2

# Aplicar PersistentVolumes
log "Aplicando PersistentVolumes..."
kubectl apply -f persistent-volumes.yml

# Aplicar PersistentVolumeClaims específicos de cada módulo
log "Aplicando PersistentVolumeClaims específicos..."

# ArgoCD PVCs
log "Aplicando PVCs do ArgoCD..."
kubectl apply -f devops/argocd/argocd-pvc.yml

# Drone PVCs
log "Aplicando PVCs do Drone..."
kubectl apply -f devops/drone/drone-pvc.yml

# Harbor PVCs
log "Aplicando PVCs do Harbor..."
kubectl apply -f devops/harbor/harbor-pvc.yml

# Verificar status dos recursos
log "Verificando status dos PersistentVolumes..."
kubectl get pv

log "Verificando status dos PersistentVolumeClaims..."
kubectl get pvc --all-namespaces

log "Verificando StorageClass..."
kubectl get storageclass

echo ""
log "✅ Configurações de armazenamento persistente aplicadas com sucesso!"
log ""
log "📋 Próximos passos:"
log "1. Verifique se os PersistentVolumes estão em status 'Available'"
log "2. Verifique se os PersistentVolumeClaims estão em status 'Bound'"
log "3. Atualize os manifests dos serviços para usar os PVCs criados"
log ""
log "💡 Para verificar o status detalhado:"
log "   kubectl get pv,pvc --all-namespaces"
log "   kubectl describe pv [nome-do-pv]"
log "   kubectl describe pvc [nome-do-pvc] -n [namespace]"