# Configuração de Dados Persistentes

Este documento descreve como configurar e usar os dados persistentes para todos os serviços do cluster.

## Visão Geral

Os sistemas que requerem persistência têm dados persistentes configurados na pasta `/var/cluster_data/[nome-do-serviço]`:

- **ArgoCD**: `/var/cluster_data/argocd/`
- **Drone CI**: `/var/cluster_data/drone/`
- **Harbor**: `/var/cluster_data/harbor/`
- **Site**: Stateless (não requer persistência)

## Estrutura Detalhada

### ArgoCD (`/var/cluster_data/argocd/`)
```
argocd/
├── redis/                    # Cache Redis do ArgoCD
├── server/                  # Dados do servidor ArgoCD
├── repo-server/             # Cache de repositórios Git
├── dex-server/              # Dados do servidor de autenticação Dex
└── application-controller/   # Dados do controlador de aplicações
```

### Drone CI (`/var/cluster_data/drone/`)
```
drone/
├── data/                    # Banco de dados SQLite do Drone
├── logs/                    # Logs de execução dos builds
└── cache/                   # Cache de dependências e builds
```

### Harbor (`/var/cluster_data/harbor/`)
```
harbor/
├── registry/                # Imagens Docker armazenadas
├── database/                # Banco de dados PostgreSQL do Harbor
├── redis/                   # Cache Redis do Harbor
├── trivy/                   # Dados do scanner de vulnerabilidades Trivy
└── jobservice/              # Logs e dados dos jobs do Harbor
```

### Site
- **Stateless** - Não requer dados persistentes
- A aplicação web é completamente stateless e não precisa de armazenamento persistente

## Configuração Inicial

### 1. Criar Estrutura de Diretórios

```bash
# Executar como root ou com sudo
sudo ./setup-cluster-data.sh
```

Este script irá:
- Criar todos os diretórios necessários
- Configurar permissões adequadas para cada serviço
- Criar arquivos `.gitkeep` para manter a estrutura
- Gerar documentação README

### 2. Aplicar PersistentVolumes e PVCs

```bash
# Aplicar configurações do Kubernetes
./apply-persistent-storage.sh
```

Este script irá:
- Criar namespaces necessários
- Aplicar StorageClass `local-storage`
- Criar PersistentVolumes para cada diretório
- Criar PersistentVolumeClaims nos namespaces apropriados

## Verificação

### Verificar Estrutura de Diretórios
```bash
ls -la /var/cluster_data/
find /var/cluster_data/ -type d | sort
```

### Verificar PersistentVolumes
```bash
kubectl get pv
kubectl get pvc --all-namespaces
kubectl get storageclass
```

### Verificar Status Detalhado
```bash
kubectl describe pv [nome-do-pv]
kubectl describe pvc [nome-do-pvc] -n [namespace]
```

## Integração com Serviços

### ArgoCD
Os PersistentVolumes devem ser referenciados nos manifests do ArgoCD:
- `argocd-redis-pvc` para Redis
- `argocd-server-pvc` para Server
- `argocd-repo-server-pvc` para Repo Server

### Drone CI
Os PersistentVolumes devem ser referenciados nos manifests do Drone:
- `drone-data-pvc` para dados do banco SQLite
- `drone-logs-pvc` para logs de builds

### Harbor
Os PersistentVolumes devem ser referenciados nos manifests do Harbor:
- `harbor-registry-pvc` para registry de imagens
- `harbor-database-pvc` para banco PostgreSQL
- `harbor-redis-pvc` para cache Redis
- `harbor-trivy-pvc` para scanner Trivy
- `harbor-jobservice-pvc` para job service

### Site
- **Stateless** - Não requer PersistentVolumes

## Backup e Restore

### Backup
```bash
# Criar backup completo
sudo tar -czf cluster-data-backup-$(date +%Y%m%d).tar.gz /var/cluster_data/

# Backup específico por serviço
sudo tar -czf argocd-backup-$(date +%Y%m%d).tar.gz /var/cluster_data/argocd/
sudo tar -czf drone-backup-$(date +%Y%m%d).tar.gz /var/cluster_data/drone/
sudo tar -czf harbor-backup-$(date +%Y%m%d).tar.gz /var/cluster_data/harbor/
```

### Restore
```bash
# Restaurar backup completo
sudo tar -xzf cluster-data-backup-YYYYMMDD.tar.gz -C /

# Restaurar serviço específico
sudo tar -xzf argocd-backup-YYYYMMDD.tar.gz -C /
sudo tar -xzf drone-backup-YYYYMMDD.tar.gz -C /
sudo tar -xzf harbor-backup-YYYYMMDD.tar.gz -C /
```

## Monitoramento

### Espaço em Disco
```bash
# Verificar uso de espaço
du -sh /var/cluster_data/*
df -h /var/cluster_data
```

### Logs de Aplicação
```bash
# Logs do ArgoCD
kubectl logs -n argocd deployment/argocd-server

# Logs do Drone
kubectl logs -n drone-space deployment/uzi-drone-poc

# Logs do Harbor
kubectl logs -n harbor deployment/harbor-core

# Site é stateless - logs são temporários
```

## Troubleshooting

### Problemas Comuns

1. **PersistentVolume não está sendo usado**
   - Verificar se o PVC está em status "Bound"
   - Verificar se o PV está em status "Available"
   - Verificar se o StorageClass está correto

2. **Permissões incorretas**
   - Executar novamente o script de configuração
   - Verificar ownership dos diretórios

3. **Espaço insuficiente**
   - Verificar espaço disponível em disco
   - Considerar aumentar o tamanho dos volumes

### Comandos de Diagnóstico
```bash
# Verificar eventos do cluster
kubectl get events --all-namespaces --sort-by='.lastTimestamp'

# Verificar status dos pods
kubectl get pods --all-namespaces

# Verificar logs de inicialização
kubectl describe pod [pod-name] -n [namespace]
```

## Manutenção

### Limpeza de Logs Antigos
```bash
# Limpar logs antigos (manter últimos 30 dias)
find /var/cluster_data/*/logs -name "*.log" -mtime +30 -delete
```

### Rotação de Logs
Configure logrotate para os logs dos serviços:
```bash
sudo nano /etc/logrotate.d/cluster-data
```

Exemplo de configuração:
```
/var/cluster_data/*/logs/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 root root
}
```

## Considerações de Segurança

1. **Permissões**: Os diretórios são configurados com permissões restritivas
2. **Backup**: Faça backup regular dos dados importantes
3. **Monitoramento**: Monitore o uso de espaço em disco
4. **Acesso**: Limite o acesso aos diretórios de dados persistentes

## Suporte

Para problemas ou dúvidas sobre a configuração de dados persistentes:
1. Verifique os logs do sistema
2. Consulte a documentação do Kubernetes sobre PersistentVolumes
3. Verifique a documentação específica de cada serviço