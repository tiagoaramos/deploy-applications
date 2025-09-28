#!/bin/bash

minikube start

kubectl create namespace argocd

minikube addons enable ingress

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

sleep 30

docker network connect appwebdiario-network minikube

kubectl apply -f argocd-application.yml

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

kubectl create namespace drone-space

kubectl apply -f drone-application.yml

kubectl create secret docker-registry harbor-secret --docker-server=https://harbor.appwebdiario.com.br --docker-username=deployer --docker-password=D3ployer --docker-email=deployer@harbor.appwebdiario.com.br --dry-run=client -o yaml

kubectl apply -f site-application.yml
