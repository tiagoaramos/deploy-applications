# deploy-applications
Repositório para deploy de aplicações pelo Argo CD

## Aplicações Deployadas

### ArgoCD
- **URL:** `http://argocd.appwebdiario.com.br`
- **IP Minikube:** `192.168.49.2:80`
- **Namespace:** `argocd`
- **Ingress:** `argocd-ingress`

### Drone CI
- **URL:** `http://drone.appwebdiario.com.br`
- **IP Minikube:** `192.168.49.2:80`
- **Namespace:** `drone-space`
- **Ingress:** `drone-ingress`

### Harbor
- **URL:** `https://harbor.appwebdiario.com.br`
- **Namespace:** `harbor`
- **Função:** Registry de containers Docker

### Site
- **Namespace:** `site-space`
- **Função:** Aplicação web principal (stateless)

## Configuração do Nginx Proxy Manager (NPM)

Para acessar as aplicações através do NPM, configure os seguintes proxy hosts:

### ArgoCD
- **Forward Hostname/IP:** `192.168.49.2`
- **Port:** `80`
- **Domain Names:** `argocd.appwebdiario.com.br`
- **Use SSL:** Não (HTTP)

### Drone
- **Forward Hostname/IP:** `192.168.49.2`
- **Port:** `80`
- **Domain Names:** `drone.appwebdiario.com.br`
- **Use SSL:** Não (HTTP)

### Harbor
- **Forward Hostname/IP:** `192.168.49.2`
- **Port:** `443`
- **Domain Names:** `harbor.appwebdiario.com.br`
- **Use SSL:** Sim (HTTPS)

## Dados Persistentes

Os serviços que requerem persistência têm dados persistentes configurados em `/var/cluster_data/[nome-do-serviço]`:

### Estrutura de Diretórios
```
/var/cluster_data/
├── argocd/
│   ├── redis/
│   ├── server/
│   ├── repo-server/
│   ├── dex-server/
│   └── application-controller/
├── drone/
│   ├── data/
│   ├── logs/
│   └── cache/
└── harbor/
    ├── registry/
    ├── database/
    ├── redis/
    ├── trivy/
    └── jobservice/
```

### Configuração de Dados Persistentes

```bash
# 1. Criar estrutura de diretórios e configurar permissões
sudo ./setup-cluster-data.sh

# 2. Aplicar PersistentVolumes e PersistentVolumeClaims
./apply-persistent-storage.sh
```

## Aplicação dos Manifests

```bash
# Aplicar configurações de ingress
kubectl apply -f devops/argocd/argocd-application.yml

# Aplicar aplicações do ArgoCD
kubectl apply -f devops/drone/drone-application.yml

# Aplicar aplicação do site
kubectl apply -f applications/site/site-application.yml
```

## Scripts Disponíveis

- `setup.sh` - Script principal de configuração do cluster
- `setup-cluster-data.sh` - Configura estrutura de dados persistentes
- `apply-persistent-storage.sh` - Aplica PersistentVolumes e PVCs
- `devops/harbor/setup-harbor-secrets.sh` - Configura secrets do Harbor
