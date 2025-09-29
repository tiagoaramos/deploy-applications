# Certificados TLS Global

Esta pasta contém os certificados TLS globais que podem ser utilizados em todos os projetos quando necessário.

## Certificado Atual

- **Domínio**: appwebdiario.com.br
- **Tipo**: CloudFlare Origin Certificate
- **Válido até**: 15 de setembro de 2040
- **Algoritmo**: RSA 2048-bit
- **Emissor**: CloudFlare, Inc.

## Estrutura

```
global-tls/
├── README.md           # Esta documentação
├── tls.crt            # Certificado público (appwebdiario.com.br)
├── tls.key            # Chave privada (appwebdiario.com.br)
├── ca.crt.example     # Certificado da CA (exemplo)
├── config.yaml        # Configurações do certificado
├── apply-secret.sh    # Script para aplicar no Kubernetes
└── generate-certs.sh  # Script para gerar novos certificados
```

## Como usar

### 1. Certificados já configurados

Os certificados para `appwebdiario.com.br` já estão configurados e prontos para uso:
- `tls.crt` - Certificado público CloudFlare Origin
- `tls.key` - Chave privada correspondente

### 2. Gerar novos certificados (se necessário)

Para gerar um certificado auto-assinado para desenvolvimento:

```bash
# Usar o script fornecido
./generate-certs.sh "*.appwebdiario.com.br"

# Ou manualmente
openssl req -x509 -newkey rsa:4096 -keyout tls.key -out tls.crt -days 365 -nodes \
  -subj "/C=BR/ST=SP/L=SaoPaulo/O=DevOps/OU=IT/CN=*.appwebdiario.com.br"
```

### 3. Usar em Kubernetes

Criar um Secret com os certificados:

```bash
kubectl create secret tls global-tls-secret \
  --cert=tls.crt \
  --key=tls.key \
  --namespace=default
```

### 3. Usar em Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: appwebdiario-ingress
spec:
  tls:
  - hosts:
    - appwebdiario.com.br
    - www.appwebdiario.com.br
    secretName: global-tls-secret
  rules:
  - host: appwebdiario.com.br
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: appwebdiario-service
            port:
              number: 80
  - host: www.appwebdiario.com.br
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: appwebdiario-service
            port:
              number: 80
```

### 4. Usar em Helm Charts

No `values.yaml`:

```yaml
ingress:
  enabled: true
  tls:
    enabled: true
    secretName: global-tls-secret
```

## Segurança

⚠️ **IMPORTANTE**:
- Nunca commite chaves privadas reais no repositório
- Use variáveis de ambiente ou secrets do Kubernetes para produção
- Para produção, use certificados de CAs confiáveis (Let's Encrypt, etc.)

## Renovação

Para renovar certificados:

1. Gere novos certificados
2. Atualize o Secret no Kubernetes
3. Reinicie os pods que usam o certificado

```bash
kubectl create secret tls global-tls-secret \
  --cert=new-tls.crt \
  --key=new-tls.key \
  --namespace=default \
  --dry-run=client -o yaml | kubectl apply -f -
```
