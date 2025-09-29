# Setup Completo com Integração Harbor

## ✅ Alterações Realizadas nos Scripts de Setup

### 1. **setup.sh (Principal)**
- ✅ Adicionada configuração automática do Harbor
- ✅ Deploy completo do Drone Server e Runner
- ✅ Verificação final da configuração
- ✅ Informações de acesso e credenciais

### 2. **devops/setup.sh**
- ✅ Mesmas funcionalidades do setup principal
- ✅ Deploy completo com Harbor integrado

### 3. **setup-complete-with-harbor.sh (Novo)**
- ✅ Script de setup completo com verificação adicional
- ✅ Teste de conectividade com Harbor
- ✅ Comandos úteis para troubleshooting

## 🚀 Como Usar

### Opção 1: Setup Completo (Recomendado)
```bash
./setup-complete-with-harbor.sh
```

### Opção 2: Setup Manual
```bash
./setup.sh
```

### Opção 3: Setup Devops
```bash
./devops/setup.sh
```

## 📋 O que o Setup Faz Agora

### 1. **Configuração Inicial**
- Inicia minikube
- Habilita addons necessários
- Cria namespaces (argocd, drone-space, harbor)

### 2. **ArgoCD**
- Instala ArgoCD via Helm
- Aplica certificados TLS
- Configura aplicações

### 3. **Drone CI com Harbor**
- Aplica configurações de autenticação do Harbor
- Deploy do Drone Server com Harbor integrado
- Deploy do Drone Runner com Harbor integrado
- Verificação da configuração

### 4. **Harbor**
- Instala Harbor via Helm
- Configura TLS e persistência

### 5. **Verificação Final**
- Verifica todos os pods
- Confirma configuração do Harbor
- Mostra informações de acesso

## 🔐 Configuração Harbor

- **Usuário**: `deployer`
- **Senha**: `D3ployer`
- **Registry**: `harbor.appwebdiario.com.br`
- **Certificado CA**: Configurado automaticamente

## 📊 Recursos Criados

### Secrets
- `harbor-secret` - Credenciais do Harbor

### ConfigMaps
- `harbor-ca-cert` - Certificado CA do Harbor
- `docker-daemon-config` - Configuração do Docker daemon

### Deployments
- `drone` - Drone Server
- `drone-runner-kube` - Drone Runner

## 🔍 Verificação

### Comandos de Verificação
```bash
# Ver todos os pods
kubectl get pods --all-namespaces

# Ver recursos do Harbor
kubectl get secrets,configmaps -n drone-space | grep harbor

# Ver logs do Drone
kubectl logs -n drone-space deployment/drone
kubectl logs -n drone-space deployment/drone-runner-kube
```

### Scripts de Verificação
```bash
# Verificação completa
cd devops/drone
./verify-harbor-auth.sh
```

## 🎯 Teste de Funcionamento

1. **Acesse o Drone**:
   ```bash
   kubectl port-forward svc/drone -n drone-space 8081:80
   ```

2. **Crie um pipeline** que faça pull de uma imagem do Harbor

3. **Verifique se o build executa** com sucesso usando as credenciais `deployer/D3ployer`

## 🚨 Troubleshooting

### Se o Drone não conseguir fazer pull do Harbor:
1. Verifique se os secrets foram criados:
   ```bash
   kubectl get secrets -n drone-space | grep harbor
   ```

2. Verifique se o certificado CA está correto:
   ```bash
   kubectl describe configmap harbor-ca-cert -n drone-space
   ```

3. Verifique os logs do Drone Runner:
   ```bash
   kubectl logs -n drone-space deployment/drone-runner-kube
   ```

## 📝 Notas Importantes

- Todas as configurações são aplicadas automaticamente
- O certificado CA do Harbor é obtido automaticamente
- As credenciais são configuradas automaticamente
- O setup é idempotente (pode ser executado múltiplas vezes)
- Todos os recursos são criados no namespace `drone-space`
