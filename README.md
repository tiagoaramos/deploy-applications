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

## Aplicação dos Manifests

```bash
# Aplicar configurações de ingress
kubectl apply -f argocd-application.yml

# Aplicar aplicações do ArgoCD
kubectl apply -f drone-application.yml
```
