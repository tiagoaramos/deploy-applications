#!/bin/bash

minikube start

kubectl create namespace argocd

minikube addons enable ingress

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

sleep 30

docker network connect appwebdiario-network minikube

kubectl apply -f devops/argocd/argocd-application.yml

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

kubectl create namespace drone-space

kubectl apply -f devops/drone/drone-application.yml


kubectl apply -f applications/site/site-application.yml
