#!/usr/bin/env bash
# OpenStack health check — local DevStack (UTM) via repo .env
# Usage:
#   ./openstack-devstack/scripts/health_check.sh
#   # or after: source openstack-devstack/scripts/load_env.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
OPENSTACK_BIN="${OPENSTACK_BIN:-}"

# Auto-load secrets from repo-root .env if auth is not already in the shell
if [[ -z "${OS_CLOUD:-}" && -z "${OS_AUTH_URL:-}" ]]; then
  # shellcheck disable=SC1091
  source "${ROOT}/openstack-devstack/scripts/load_env.sh"
fi

if [[ -z "${OPENSTACK_BIN}" ]]; then
  if [[ -x "${ROOT}/.venv/bin/openstack" ]]; then
    OPENSTACK_BIN="${ROOT}/.venv/bin/openstack"
  elif command -v openstack >/dev/null 2>&1; then
    OPENSTACK_BIN="$(command -v openstack)"
  else
    echo "FAIL: openstack CLI not found."
    echo "  Fix: python3 -m venv .venv && .venv/bin/pip install -r openstack-devstack/requirements.txt"
    exit 1
  fi
fi

echo "== OpenStack health check =="
echo "CLI: ${OPENSTACK_BIN}"
"${OPENSTACK_BIN}" --version || true
echo

require_auth_env() {
  if [[ -n "${OS_CLOUD:-}" ]]; then
    echo "Auth: OS_CLOUD=${OS_CLOUD}"
    return 0
  fi
  if [[ -n "${OS_AUTH_URL:-}" ]]; then
    echo "Auth: OS_AUTH_URL=${OS_AUTH_URL}"
    return 0
  fi
  echo "FAIL: No authentication configured."
  echo "  Root cause: neither OS_CLOUD nor OS_AUTH_URL is set."
  echo "  Unblock:"
  echo "    1) cp .env.example .env"
  echo "    2) Set OS_AUTH_URL / OS_PASSWORD for your DevStack VM"
  echo "    3) Re-run this script (it auto-loads .env)"
  echo "  On the VM you can also: source /opt/stack/devstack/openrc admin admin"
  exit 1
}

run_step() {
  local name="$1"
  shift
  echo "--- ${name} ---"
  if "$@"; then
    echo "PASS: ${name}"
  else
    echo "FAIL: ${name}"
    echo "  Hint: if token works but this fails, check region/catalog/endpoints."
    exit 1
  fi
  echo
}

require_auth_env

run_step "token issue" "${OPENSTACK_BIN}" token issue
run_step "service list" "${OPENSTACK_BIN}" service list
run_step "catalog list" "${OPENSTACK_BIN}" catalog list
run_step "network list" "${OPENSTACK_BIN}" network list
run_step "image list" "${OPENSTACK_BIN}" image list
run_step "server list" "${OPENSTACK_BIN}" server list
run_step "flavor list" "${OPENSTACK_BIN}" flavor list

echo "== ALL CHECKS PASSED =="
echo "Record results in openstack-devstack/HEALTH_CHECKLIST.md and Obsidian Notes."
