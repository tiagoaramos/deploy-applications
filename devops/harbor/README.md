# Harbor Configuration

Este diretório contém os manifestos necessários para configurar o Harbor registry e seus secrets nos namespaces do projeto.

## Arquivos

### Secrets e ConfigMaps
- `harbor-image-pull-secret.yaml` - Secret para o namespace harbor
- `harbor-image-pull-secret-drone-space.yaml` - Secret para o namespace drone-space
- `harbor-image-pull-secret-site-space.yaml` - Secret para o namespace site-space
- `harbor-ca-cert-configmap.yaml` - ConfigMap para o namespace harbor
- `harbor-ca-cert-configmap-drone-space.yaml` - ConfigMap para o namespace drone-space
- `harbor-tls-secret.yaml` - Secret TLS do Harbor

### Scripts
- `setup-harbor-secrets.sh` - Script para aplicar todas as configurações automaticamente

## Configuração Automática

O script `setup-harbor-secrets.sh` é executado automaticamente pelo `setup.sh` principal e:

1. Aplica os secrets do Harbor nos namespaces necessários
2. Aplica os ConfigMaps de certificados
3. Configura os Service Accounts para usar os image pull secrets

## Namespaces Configurados

### drone-space
- `harbor-secret` - Para pull de imagens do Harbor
- `harbor-ca-cert` - Certificado CA do Harbor

### site-space
- `harbor-secret` - Para pull de imagens do Harbor

## Credenciais do Harbor

- **Registry**: `harbor.appwebdiario.com.br`
- **Username**: `deployer`
- **Password**: `D3ployer`
- **Email**: `deployer@harbor.appwebdiario.com.br`

## Uso Manual

Se precisar aplicar as configurações manualmente:

```bash
# Aplicar secrets no drone-space
kubectl apply -f devops/harbor/harbor-image-pull-secret-drone-space.yaml
kubectl apply -f devops/harbor/harbor-ca-cert-configmap-drone-space.yaml

# Aplicar secrets no site-space
kubectl apply -f devops/harbor/harbor-image-pull-secret-site-space.yaml

# Configurar service accounts
kubectl patch serviceaccount default -n drone-space -p '{"imagePullSecrets": [{"name": "harbor-secret"}]}'
kubectl patch serviceaccount default -n site-space -p '{"imagePullSecrets": [{"name": "harbor-secret"}]}'
```

## Troubleshooting

Se houver problemas com pull de imagens:

1. Verificar se os secrets existem nos namespaces:
   ```bash
   kubectl get secrets -n drone-space | grep harbor
   kubectl get secrets -n site-space | grep harbor
   ```

2. Verificar se os service accounts estão configurados:
   ```bash
   kubectl get serviceaccount default -n drone-space -o yaml
   kubectl get serviceaccount default -n site-space -o yaml
   ```

3. Verificar logs dos pods:
   ```bash
   kubectl describe pod <pod-name> -n <namespace>
   ```
