#!/usr/bin/env bash
# Fresh DevStack bootstrap for UTM Ubuntu ARM64 — run ON the Ubuntu VM.
#
# Phase A: clone DevStack + install local.conf (your known-good ARM settings)
# Phase B: optional ./stack.sh (LONG — ask before running)
# Phase C: remind you to run devstack_post_fix.sh
#
# Usage:
#   ./devstack_bootstrap.sh           # prepare only (clone + local.conf)
#   ./devstack_bootstrap.sh --stack   # prepare + FORCE=yes ./stack.sh
#
# Copy this repo onto the VM first, e.g. from Mac:
#   scp -r ~/Documents/Projects/dpaas_cloud_platform hpeh@192.168.64.4:~/
# Then on VM:
#   sudo -iu stack
#   bash ~/dpaas_cloud_platform/openstack-devstack/scripts/devstack_bootstrap.sh

set -euo pipefail

DO_STACK=0
for arg in "${@:-}"; do
  case "$arg" in
    --stack) DO_STACK=1 ;;
    -h|--help)
      sed -n '1,25p' "$0"
      exit 0
      ;;
  esac
done

STACK_HOME="${STACK_HOME:-/opt/stack}"
DEVSTACK_DIR="${DEVSTACK_DIR:-${STACK_HOME}/devstack}"
BRANCH="${TARGET_BRANCH:-stable/2025.1}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_LOCAL_CONF="${SCRIPT_DIR}/../env/local.conf.example"

log() { printf '\n==> %s\n' "$*"; }
die() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

detect_host_ip() {
  # Prefer the shared UTM NIC; fall back to first global IPv4.
  ip -4 -o addr show scope global | awk '{print $4}' | cut -d/ -f1 | head -n1
}

main() {
  [[ "$(id -un)" == "stack" ]] || die "Run as user stack (sudo -iu stack). Current: $(id -un)"
  [[ -f "${REPO_LOCAL_CONF}" ]] || die "missing ${REPO_LOCAL_CONF}"

  local host_ip
  host_ip="$(detect_host_ip)"
  [[ -n "${host_ip}" ]] || die "could not detect HOST_IP"

  log "HOST_IP detected: ${host_ip}"
  log "Branch: ${BRANCH}"

  if [[ ! -d "${DEVSTACK_DIR}/.git" ]]; then
    log "Clone DevStack ${BRANCH} → ${DEVSTACK_DIR}"
    sudo mkdir -p "${STACK_HOME}"
    sudo chown -R stack:stack "${STACK_HOME}"
    git clone https://opendev.org/openstack/devstack -b "${BRANCH}" "${DEVSTACK_DIR}"
  else
    log "DevStack already present at ${DEVSTACK_DIR}"
  fi

  log "Write local.conf from lab template (ARM/UTM protections baked in)"
  # Replace example HOST_IP with detected IP
  sed "s/^HOST_IP=.*/HOST_IP=${host_ip}/" "${REPO_LOCAL_CONF}" > "${DEVSTACK_DIR}/local.conf"
  echo "Wrote ${DEVSTACK_DIR}/local.conf"
  grep -E '^(HOST_IP|LIBVIRT_|Q_ML2_|TARGET_BRANCH|PYTHON3_VERSION)' "${DEVSTACK_DIR}/local.conf" || true

  cat <<EOF

Protections already in local.conf (so Glance/Nova/Neutron start healthier):
  - Q_ML2_TENANT_NETWORK_TYPE=local     (Neutron / OVN lab)
  - LIBVIRT_TYPE=qemu                   (no /dev/kvm)
  - LIBVIRT_CPU_MODE=none               (no host-passthrough on aarch64)
  - PYTHON3_VERSION=3.11
  - TARGET_BRANCH=${BRANCH}

EOF

  if [[ "${DO_STACK}" -eq 1 ]]; then
    log "Running FORCE=yes ./stack.sh (this can take a long time)"
    cd "${DEVSTACK_DIR}"
    FORCE=yes ./stack.sh
    log "stack.sh finished — run post-fix next:"
    echo "  bash ${SCRIPT_DIR}/devstack_post_fix.sh"
  else
    log "Prepare-only done. When ready to install OpenStack:"
    echo "  cd ${DEVSTACK_DIR}"
    echo "  FORCE=yes ./stack.sh"
    echo "Then:"
    echo "  bash ${SCRIPT_DIR}/devstack_post_fix.sh"
    echo
    echo "Or one shot:  $0 --stack"
  fi
}

main
