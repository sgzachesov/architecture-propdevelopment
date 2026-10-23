#!/usr/bin/env bash
#
# Task 4. Шаг 1. Создание пользователей кластера Kubernetes (Service Accounts).
#
# Пользователи соответствуют ролевой модели (см. RBAC_роли_и_пользователи.md):
#   admin-devops  — привилегированная группа (cluster-admin, доступ к секретам)
#   dev-sales     — разработчик домена «Продажи»   (developer, namespace sales)
#   dev-zhu       — разработчик домена «ЖКУ»        (developer, namespace zhu)
#   viewer-ops    — менеджер/бизнес-аналитик        (viewer, только чтение)
#
# Требования: kubectl, настроенный на кластер (пустой Minikube).
# Запуск:      bash 01-create-users.sh

set -euo pipefail

kubectl create serviceaccount admin-devops
kubectl create serviceaccount dev-sales
kubectl create serviceaccount dev-zhu
kubectl create serviceaccount viewer-ops

echo "--- Созданные пользователи (Service Accounts):"
kubectl get serviceaccounts