#!/usr/bin/env bash
#
# Task 4. Шаг 0. Создание локального кластера Kubernetes (Minikube).
#
# Скрипт поднимает пустой однонодовый кластер, к которому далее применяются
# пользователи, роли и привязки (скрипты 01–03).
#
# Требования: minikube, kubectl, установленный и запущенный Docker.
# Запуск:      bash 00-create-cluster.sh
#
# Можно переопределить параметры через переменные окружения:
#   MINIKUBE_DRIVER   — драйвер (по умолчанию docker)
#   K8S_VERSION       — версия Kubernetes (по умолчанию v1.35.0)
#   MINIKUBE_CPUS     — число CPU
#   MINIKUBE_MEMORY   — объём памяти (например, 4096mb)

set -euo pipefail

MINIKUBE_DRIVER="${MINIKUBE_DRIVER:-docker}"
K8S_VERSION="${K8S_VERSION:-v1.35.0}"

if ! command -v minikube >/dev/null 2>&1; then
  echo "Ошибка: minikube не найден в PATH. Установите Minikube и повторите запуск." >&2
  exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
  echo "Ошибка: kubectl не найден в PATH. Установите kubectl и повторите запуск." >&2
  exit 1
fi

if minikube status --format='{{.Host}}' 2>/dev/null | grep -q Running; then
  echo "--- Кластер Minikube уже запущен, повторное создание не требуется ---"
else
  echo "--- Создание кластера Minikube (driver=${MINIKUBE_DRIVER}, k8s=${K8S_VERSION}) ---"
  minikube start \
    --driver="${MINIKUBE_DRIVER}" \
    --kubernetes-version="${K8S_VERSION}" \
    ${MINIKUBE_CPUS:+--cpus="${MINIKUBE_CPUS}"} \
    ${MINIKUBE_MEMORY:+--memory="${MINIKUBE_MEMORY}"}
fi

echo "--- Кластер готов:"
kubectl get nodes