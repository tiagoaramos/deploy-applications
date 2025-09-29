#!/bin/bash

# Script para aplicar a autenticação do Harbor no Drone
# Este script cria os secrets e configmaps necessários para o Drone se autenticar no Harbor

echo "Aplicando configurações de autenticação do Harbor..."

# Aplicar o secret do Harbor
echo "Criando secret do Harbor..."
kubectl apply -f harbor-secret.yml

# Aplicar o ConfigMap do certificado CA do Harbor
echo "Criando ConfigMap do certificado CA do Harbor..."
kubectl apply -f harbor-ca-cert.yml

# Aplicar o ConfigMap da configuração do Docker daemon
echo "Criando ConfigMap da configuração do Docker daemon..."
kubectl apply -f docker-daemon-config.yml

echo "Configurações aplicadas com sucesso!"
echo ""
echo "Próximos passos:"
echo "1. Atualize o certificado CA do Harbor no arquivo harbor-ca-cert.yml"
echo "2. Aplique os charts do Helm do Drone:"
echo "   helm upgrade --install drone ./drone-helm/charts/drone -f ./drone-helm/charts/drone/values.yaml"
echo "   helm upgrade --install drone-runner-kube ./drone-helm/charts/drone-runner-kube -f ./drone-helm/charts/drone-runner-kube/values.yaml"
