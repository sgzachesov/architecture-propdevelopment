#!/usr/bin/env bash
#
# Task 5. Автоматическая проверка сетевых политик.
#
# Запускает временные поды alpine с нужными метками (role=...) и проверяет,
# что разрешённые пары видят друг друга, а запрещённые — нет.
#
# Требования: kubectl, доступ к кластеру, применённый non-admin-api-allow.yaml,
#             поды и сервисы Task 5 уже развёрнуты.
# Запуск:      bash verify.sh

set -uo pipefail

PASS=0
FAIL=0

check() {
  local title="$1" labels="$2" url="$3" expected="$4"
  local pod="test-$$-$RANDOM"
  local args=(run "$pod" --rm -i --restart=Never --image=alpine)

  if [ -n "${labels}" ]; then
    args+=(--labels "${labels}")
  fi

  local rc
  rc=$(kubectl "${args[@]}" -- sh -c \
        "wget -qO- -T 2 '${url}' >/dev/null 2>&1; echo RC=\$?" 2>/dev/null \
       | tr -d '\r' | sed -n 's/^RC=\([0-9][0-9]*\)$/\1/p' | tail -n 1)

  [ -z "${rc}" ] && rc="?"

  local ok=0
  if [ "${expected}" = "allow" ] && [ "${rc}" = "0" ]; then ok=1; fi
  if [ "${expected}" = "deny" ]  && [ "${rc}" != "0" ]; then ok=1; fi

  if [ "${ok}" = "1" ]; then
    PASS=$((PASS + 1))
    printf '  OK   %-46s ожидалось: %-5s RC=%s\n' "${title}" "${expected}" "${rc}"
  else
    FAIL=$((FAIL + 1))
    printf '  FAIL %-46s ожидалось: %-5s RC=%s\n' "${title}" "${expected}" "${rc}"
  fi
}

echo "== Проверка изоляции трафика (Task 5) =="

# Разрешённые пары (в обе стороны)
check "front-end -> back-end-api"               "role=front-end"           "http://back-end-api-app"       allow
check "back-end-api -> front-end"               "role=back-end-api"        "http://front-end-app"          allow
check "admin-front-end -> admin-back-end-api"   "role=admin-front-end"     "http://admin-back-end-api-app" allow
check "admin-back-end-api -> admin-front-end"   "role=admin-back-end-api"  "http://admin-front-end-app"    allow

# Запрещённые направления
check "front-end -> admin-back-end-api"         "role=front-end"           "http://admin-back-end-api-app" deny
check "admin-front-end -> back-end-api"         "role=admin-front-end"     "http://back-end-api-app"       deny
check "под без метки -> back-end-api"           ""                         "http://back-end-api-app"       deny
check "под без метки -> admin-back-end-api"     ""                         "http://admin-back-end-api-app" deny

echo
echo "Итого: успешно ${PASS}, провалено ${FAIL}"
[ "${FAIL}" -eq 0 ]