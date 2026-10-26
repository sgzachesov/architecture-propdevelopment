#!/usr/bin/env bash
#
# Task 4. Шаг 3. Привязка пользователей к ролям (RoleBinding).
#
# Привилегированная группа: admin-devops -> cluster-admin (весь кластер, включая секреты)
# Просмотр:                 viewer-ops  -> viewer        (весь кластер, только чтение)
# Разработчики:             dev-sales   -> developer     (namespace sales)
#                           dev-zhu     -> developer     (namespace zhu)
#
# Namespace-scoped привязки создаются применением манифеста в нужном namespace
# (опция kubectl apply -n <namespace>).
#
# Запуск:      bash 03-bind-users-to-roles.sh

set -euo pipefail

echo "--- admin-devops -> cluster-admin (весь кластер) ---"
kubectl apply -f - <<'EOF'
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: rbac-admin-devops
subjects:
  - kind: ServiceAccount
    name: admin-devops
    namespace: default
roleRef:
  kind: ClusterRole
  name: cluster-admin
EOF

echo "--- viewer-ops -> viewer (весь кластер, только чтение) ---"
kubectl apply -f - <<'EOF'
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: rbac-viewer-ops
subjects:
  - kind: ServiceAccount
    name: viewer-ops
    namespace: default
roleRef:
  kind: ClusterRole
  name: viewer
EOF

echo "--- dev-sales -> developer (namespace sales) ---"
kubectl apply -f - -n sales <<'EOF'
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: rbac-dev-sales
subjects:
  - kind: ServiceAccount
    name: dev-sales
    namespace: default
roleRef:
  kind: ClusterRole
  name: developer
EOF

echo "--- dev-zhu -> developer (namespace zhu) ---"
kubectl apply -f - -n zhu <<'EOF'
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: rbac-dev-zhu
subjects:
  - kind: ServiceAccount
    name: dev-zhu
    namespace: default
roleRef:
  kind: ClusterRole
  name: developer
EOF

echo "--- Созданные привязки (кластер):"
kubectl get rolebindings
echo "--- Созданные привязки (namespace sales):"
kubectl get rolebindings -n sales
echo "--- Созданные привязки (namespace zhu):"
kubectl get rolebindings -n zhu