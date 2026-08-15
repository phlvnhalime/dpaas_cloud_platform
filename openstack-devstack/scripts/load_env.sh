#!/usr/bin/env bash
# Load repo-root .env into the current shell (OpenStack OS_* vars).
# Usage: source openstack-devstack/scripts/load_env.sh

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_FILE="${ROOT}/.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "FAIL: missing ${ENV_FILE}"
  echo "  Fix: cp .env.example .env   then set OS_PASSWORD / OS_AUTH_URL"
  return 1 2>/dev/null || exit 1
fi

set -a
# shellcheck disable=SC1090
source "${ENV_FILE}"
set +a

if [[ -z "${OS_AUTH_URL:-}" && -z "${OS_CLOUD:-}" ]]; then
  echo "FAIL: .env loaded but neither OS_AUTH_URL nor OS_CLOUD is set"
  return 1 2>/dev/null || exit 1
fi

echo "Loaded ${ENV_FILE} (OS_AUTH_URL=${OS_AUTH_URL:-unset})"
