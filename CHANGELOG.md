# Changelog - Configuração de Dados Persistentes

## Versão 2.0 - Integração de PVCs por Módulo

### ✅ Alterações Implementadas

#### 1. Integração de PVCs por Módulo
- **ArgoCD**: PVCs integrados em `devops/argocd/argocd-pvc.yml`
- **Drone CI**: PVCs integrados em `devops/drone/drone-pvc.yml` e `values.yaml` atualizado
- **Site**: Removido (stateless - não requer persistência)

#### 2. Arquivos Criados/Modificados

**Novos Arquivos:**
- `devops/argocd/argocd-pvc.yml` - PVCs específicos do ArgoCD
- `devops/argocd/argocd-persistent-storage-patch.yml` - Patch para ArgoCD
- `devops/drone/drone-pvc.yml` - PVCs específicos do Drone

**Arquivos Modificados:**
- `devops/drone/drone-helm/charts/drone/values.yaml` - Configurado para usar PVCs específicos
- `applications/site/site-helm/templates/site-deployment.yml` - Revertido para stateless
- `setup.sh` - Atualizado para aplicar PVCs específicos
- `apply-persistent-storage.sh` - Atualizado para aplicar PVCs por módulo
- `setup-cluster-data.sh` - Removido Site (stateless)

**Arquivos Removidos:**
- `persistent-volume-claims.yml` - Substituído por PVCs específicos por módulo
- `applications/site/site-pvc.yml` - Site é stateless

#### 3. Estrutura Final de Dados Persistentes

```
/var/cluster_data/
├── argocd/                    # ArgoCD
│   ├── redis/                 # Cache Redis
│   ├── server/                # Dados do servidor
│   ├── repo-server/           # Cache de repositórios Git
│   ├── dex-server/            # Servidor de autenticação
│   └── application-controller/ # Controlador de aplicações
├── drone/                     # Drone CI
│   ├── data/                 # Banco SQLite
│   ├── logs/                 # Logs de builds
│   └── cache/                # Cache de dependências
```

#### 4. Configurações por Serviço

**ArgoCD:**
- `argocd-redis-pvc` (1Gi) - Cache Redis
- `argocd-server-pvc` (1Gi) - Dados do servidor
- `argocd-repo-server-pvc` (2Gi) - Cache de repositórios

**Drone CI:**
- `drone-data-pvc` (8Gi) - Banco SQLite
- `drone-logs-pvc` (2Gi) - Logs de builds


**Site:**
- **Stateless** - Não requer dados persistentes

#### 5. Scripts Atualizados

**`setup.sh`:**
- Aplica PVCs específicos antes de cada serviço
- Ordem: ArgoCD → Drone → Site

**`apply-persistent-storage.sh`:**
- Aplica PVCs por módulo específico
- Remove referências ao Site

**`setup-cluster-data.sh`:**
- Remove configuração do Site (stateless)
- Mantém apenas serviços que requerem persistência

#### 6. Documentação Atualizada

- `README.md` - Atualizado para refletir estrutura final
- `PERSISTENT_STORAGE.md` - Removidas referências ao Site
- `setup-cluster-data.sh` - README interno atualizado

### 🎯 Benefícios da Nova Estrutura

1. **Modularidade**: Cada serviço tem seus próprios PVCs
2. **Manutenibilidade**: Fácil gerenciar persistência por serviço
3. **Flexibilidade**: Cada módulo pode ser configurado independentemente
4. **Clareza**: Separação clara entre serviços stateful e stateless
5. **Escalabilidade**: Fácil adicionar novos serviços com persistência

### 🚀 Como Usar

```bash
# 1. Configurar estrutura de dados persistentes
sudo ./setup-cluster-data.sh

# 2. Aplicar PersistentVolumes e PVCs
./apply-persistent-storage.sh

# 3. Deploy completo do cluster
./setup.sh
```

### 📋 Próximos Passos

1. Testar a configuração em ambiente de desenvolvimento
2. Validar que todos os PVCs estão sendo criados corretamente
3. Verificar que os serviços estão usando os volumes persistentes
4. Documentar qualquer ajuste necessário nos tamanhos dos volumes
