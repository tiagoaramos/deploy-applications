#!/bin/bash

# Script para criar estrutura de dados persistentes para todos os serviços do cluster
# Autor: Tiago Ramos
# Data: $(date)

set -e

echo "🚀 Configurando estrutura de dados persistentes para o cluster..."

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

# Verificar se está rodando como root ou com sudo
if [[ $EUID -ne 0 ]]; then
   error "Este script precisa ser executado como root ou com sudo"
   exit 1
fi

# Diretório base para dados persistentes
CLUSTER_DATA_DIR="/var/cluster_data"

log "Criando estrutura de diretórios para dados persistentes..."

# Criar diretório principal
mkdir -p "$CLUSTER_DATA_DIR"

# Estrutura para ArgoCD
log "Configurando estrutura para ArgoCD..."
mkdir -p "$CLUSTER_DATA_DIR/argocd"/{redis,server,repo-server,dex-server,application-controller}

# Estrutura para Drone CI
log "Configurando estrutura para Drone CI..."
mkdir -p "$CLUSTER_DATA_DIR/drone"/{data,logs,cache}

# Estrutura para Harbor
log "Configurando estrutura para Harbor..."
mkdir -p "$CLUSTER_DATA_DIR/harbor"/{registry,database,redis,trivy,jobservice}

# Site é stateless - não precisa de dados persistentes
log "Site é stateless - pulando configuração de dados persistentes..."

# Configurar permissões adequadas
log "Configurando permissões..."

# ArgoCD - usuário 999 (argocd)
chown -R 999:999 "$CLUSTER_DATA_DIR/argocd"
chmod -R 755 "$CLUSTER_DATA_DIR/argocd"

# Drone - usuário 1000 (drone)
chown -R 1000:1000 "$CLUSTER_DATA_DIR/drone"
chmod -R 755 "$CLUSTER_DATA_DIR/drone"

# Harbor - usuário 10000 (harbor)
chown -R 10000:10000 "$CLUSTER_DATA_DIR/harbor"
chmod -R 755 "$CLUSTER_DATA_DIR/harbor"

# Criar arquivos de configuração básicos
log "Criando arquivos de configuração..."

# README para cada serviço
cat > "$CLUSTER_DATA_DIR/README.md" << 'EOF'
# Cluster Data Directory

Este diretório contém os dados persistentes para todos os serviços do cluster Kubernetes.

## Estrutura de Diretórios

### ArgoCD (`/var/cluster_data/argocd/`)
- `redis/` - Dados do Redis para cache do ArgoCD
- `server/` - Dados do servidor ArgoCD
- `repo-server/` - Cache de repositórios Git
- `dex-server/` - Dados do servidor de autenticação Dex
- `application-controller/` - Dados do controlador de aplicações

### Drone CI (`/var/cluster_data/drone/`)
- `data/` - Banco de dados SQLite do Drone
- `logs/` - Logs de execução dos builds
- `cache/` - Cache de dependências e builds

### Harbor (`/var/cluster_data/harbor/`)
- `registry/` - Imagens Docker armazenadas
- `database/` - Banco de dados PostgreSQL do Harbor
- `redis/` - Cache Redis do Harbor
- `trivy/` - Dados do scanner de vulnerabilidades Trivy
- `jobservice/` - Logs e dados dos jobs do Harbor

### Site
- **Stateless** - Não requer dados persistentes

## Backup

É recomendado fazer backup regular destes diretórios para preservar os dados dos serviços.

## Permissões

As permissões foram configuradas para os usuários apropriados de cada serviço:
- ArgoCD: usuário 999
- Drone: usuário 1000  
- Harbor: usuário 10000
EOF

# Criar arquivo .gitkeep para manter os diretórios no git
find "$CLUSTER_DATA_DIR" -type d -exec touch {}/.gitkeep \;

log "Estrutura de dados persistentes criada com sucesso!"
log "Diretório base: $CLUSTER_DATA_DIR"

echo ""
echo -e "${BLUE}📁 Estrutura criada:${NC}"
tree "$CLUSTER_DATA_DIR" || ls -la "$CLUSTER_DATA_DIR"

echo ""
log "✅ Configuração concluída!"
log "Os dados persistentes estão prontos para uso pelos serviços do cluster."