#!/usr/bin/env bash
#
# Task 4. Шаг 2. Создание ролей Kubernetes (ClusterRole) и namespace по доменам.
#
# Роли:
#   developer     — развертывание и настройка сервисов в namespace своего домена (без секретов)
#   viewer        — только чтение ресурсов кластера (без секретов)
#   cluster-admin — встроенная роль Kubernetes, создавать не требуется
#
# Пространства имён соответствуют доменам организационной структуры:
#   sales (продажи), zhu (ЖКУ), finance (финансы), data (данные)
#
# Запуск:      bash 02-create-roles.sh

set -euo pipefail

echo "--- Пространства имён по доменам ---"
for ns in sales zhu finance data; do
  kubectl create namespace "$ns" 2>/dev/null || echo "namespace '$ns' уже существует"
done

echo "--- Роль: developer ---"
kubectl apply -f - <<'EOF'
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: developer
rules:
  - apiGroups: ["*"]
    resources: ["deployments", "pods", "services", "configmaps", "statefulsets",
                "persistentvolumes", "volumeclaims", "volumeclaimtemplates"]
    verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
  - apiGroups: ["*"]
    resources: ["namespaces"]
    verbs: ["create", "get", "list", "watch"]
EOF

echo "--- Роль: viewer ---"
kubectl apply -f - <<'EOF'
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: viewer
rules:
  - apiGroups: ["*"]
    resources: ["deployments", "pods", "services", "configmaps", "statefulsets",
                "persistentvolumes", "namespaces", "nodes", "cluster", "events", "replicasets"]
    verbs: ["get", "list", "watch"]
EOF

echo "--- Созданные роли (developer, viewer) и встроенная cluster-admin:"
kubectl get clusterroles developer viewer cluster-admin