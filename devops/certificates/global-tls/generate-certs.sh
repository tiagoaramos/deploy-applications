#!/bin/bash

# Script para gerar certificados TLS para desenvolvimento
# Uso: ./generate-certs.sh [dominio]

set -e

DOMAIN=${1:-"*.local"}
DAYS=${2:-365}

echo "🔐 Gerando certificados TLS para desenvolvimento..."
echo "   Domínio: $DOMAIN"
echo "   Validade: $DAYS dias"

# Gerar chave privada
echo "📝 Gerando chave privada..."
openssl genrsa -out tls.key 4096

# Gerar certificado auto-assinado
echo "📝 Gerando certificado auto-assinado..."
openssl req -x509 -newkey rsa:4096 -keyout tls.key -out tls.crt -days "$DAYS" -nodes \
  -subj "/C=BR/ST=SP/L=SaoPaulo/O=DevOps/OU=IT/CN=$DOMAIN"

echo "✅ Certificados gerados com sucesso!"
echo ""
echo "📁 Arquivos criados:"
echo "   - tls.crt (certificado público)"
echo "   - tls.key (chave privada)"
echo ""
echo "🔍 Verificar certificado:"
echo "   openssl x509 -in tls.crt -text -noout"
echo ""
echo "📋 Para aplicar no Kubernetes:"
echo "   ./apply-secret.sh"
echo ""
echo "⚠️  IMPORTANTE:"
echo "   - Estes são certificados auto-assinados para desenvolvimento"
echo "   - Para produção, use certificados de CAs confiáveis"
echo "   - Nunca commite chaves privadas reais no repositório"
