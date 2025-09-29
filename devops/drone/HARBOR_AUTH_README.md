# Configuração de Autenticação do Drone com Harbor

Este diretório contém os arquivos necessários para configurar a autenticação do Drone com o Harbor registry.

## Arquivos Criados

### 1. harbor-secret.yml
Secret do Kubernetes contendo as credenciais do Harbor:
- **Usuário**: deployer
- **Senha**: D3ployer
- **Registry**: harbor.appwebdiario.com.br

### 2. harbor-ca-cert.yml
ConfigMap contendo o certificado CA do Harbor. **IMPORTANTE**: Você precisa atualizar este arquivo com o certificado real do Harbor.

Para obter o certificado CA do Harbor, execute:
```bash
openssl s_client -connect harbor.appwebdiario.com.br:443 -showcerts
```

### 3. docker-daemon-config.yml
ConfigMap com a configuração do Docker daemon para permitir registries inseguros.

### 4. apply-harbor-auth.sh
Script para aplicar todas as configurações automaticamente.

## Como Usar

### Passo 1: Obter o Certificado CA do Harbor
```bash
# Execute este comando e copie o certificado para o arquivo harbor-ca-cert.yml
openssl s_client -connect harbor.appwebdiario.com.br:443 -showcerts
```

### Passo 2: Aplicar as Configurações
```bash
# Execute o script para aplicar todas as configurações
./apply-harbor-auth.sh
```

### Passo 3: Deploy do Drone
```bash
# Deploy do Drone Server
helm upgrade --install drone ./drone-helm/charts/drone -f ./drone-helm/charts/drone/values.yaml

# Deploy do Drone Runner
helm upgrade --install drone-runner-kube ./drone-helm/charts/drone-runner-kube -f ./drone-helm/charts/drone-runner-kube/values.yaml
```

## Verificação

Para verificar se tudo está funcionando:

1. **Verificar os secrets e configmaps**:
```bash
kubectl get secrets -n drone-space
kubectl get configmaps -n drone-space
```

2. **Verificar os pods do Drone**:
```bash
kubectl get pods -n drone-space
```

3. **Verificar os logs**:
```bash
kubectl logs -n drone-space deployment/drone
kubectl logs -n drone-space deployment/drone-runner-kube
```

## Configurações Aplicadas

### No Drone Server (values.yaml)
- `imagePullSecrets`: harbor-secret
- `DRONE_DOCKER_CONFIG`: Configuração para registry inseguro

### No Drone Runner (values.yaml)
- `imagePullSecrets`: harbor-secret
- `DRONE_POD_SPEC`: Configuração para usar o secret do Harbor nos pods de build
- `DRONE_DOCKER_CONFIG`: Configuração para registry inseguro
- `DRONE_DOCKER_CONFIG_PATH`: Caminho para o daemon.json

## Troubleshooting

Se houver problemas com a autenticação:

1. **Verificar se o secret foi criado corretamente**:
```bash
kubectl describe secret harbor-secret -n drone-space
```

2. **Verificar se o certificado CA está correto**:
```bash
kubectl describe configmap harbor-ca-cert -n drone-space
```

3. **Verificar os logs dos pods**:
```bash
kubectl logs -n drone-space deployment/drone-runner-kube
```

## Notas Importantes

- O secret `harbor-secret` contém as credenciais codificadas em base64
- O certificado CA do Harbor deve ser atualizado no arquivo `harbor-ca-cert.yml`
- Todos os recursos são criados no namespace `drone-space`
- O Drone Runner está configurado para usar o secret do Harbor em todos os pods de build
