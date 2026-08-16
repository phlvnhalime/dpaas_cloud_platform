#!/usr/bin/env bash
# DevStack ARM/UTM recovery — run ON the Ubuntu VM (not on the Mac).
#
# Encodes the lab fixes we learned (Glance/Neutron/Nova/Placement/Horizon/libvirt).
# Use when:
#   - ./stack.sh just finished and something is broken
#   - VM rebooted and services are unhappy
#   - You rebuilt Ubuntu and re-stacked, then need the same protections again
#
# Usage (as user with sudo, ideally after: sudo -iu stack):
#   ./devstack_post_fix.sh           # apply fixes + restart + smoke
#   ./devstack_post_fix.sh --smoke   # smoke only
#   ./devstack_post_fix.sh --restart # restart services only
#
# This does NOT run ./stack.sh (that is install — hours). See docs/devstack-rebuild-playbook.md

set -euo pipefail

SMOKE_ONLY=0
RESTART_ONLY=0
for arg in "${@:-}"; do
  case "$arg" in
    --smoke) SMOKE_ONLY=1 ;;
    --restart) RESTART_ONLY=1 ;;
    -h|--help)
      sed -n '1,20p' "$0"
      exit 0
      ;;
  esac
done

DEVSTACK_DIR="${DEVSTACK_DIR:-/opt/stack/devstack}"
VENV="${VENV:-/opt/stack/data/venv}"
OPENRC="${DEVSTACK_DIR}/openrc"
UWSGI_VENV="${VENV}/bin/uwsgi"

log() { printf '\n==> %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
die() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

need_cmd() { command -v "$1" >/dev/null 2>&1 || die "missing command: $1"; }

restart_core() {
  log "Restart OVN / Neutron / Placement / Nova compute"
  # These are the units that fixed empty HashRing, empty inventory, and guest boot issues.
  sudo systemctl restart \
    devstack@ovsdb-server \
    devstack@ovn-northd \
    devstack@ovn-controller \
    devstack@q-svc \
    devstack@placement-api \
    devstack@n-cpu || warn "some units failed to restart — check: systemctl list-units 'devstack@*'"
  sleep 3
}

disable_broken_horizon() {
  log "Disable Horizon Apache site if present (CLI is source of truth on this lab)"
  if [[ -e /etc/apache2/sites-enabled/horizon.conf ]]; then
    sudo a2dissite horizon.conf || true
    sudo systemctl reload apache2 || warn "apache2 reload failed"
  else
    echo "horizon.conf not enabled — OK"
  fi
}

ensure_libvirt_python() {
  log "Ensure libvirt-python inside DevStack venv (fixes libvirtmod import errors)"
  if [[ ! -x "${VENV}/bin/pip" ]]; then
    warn "venv pip not found at ${VENV}/bin/pip — skip"
    return 0
  fi
  # --ignore-installed avoids fighting distro packages
  "${VENV}/bin/pip" install --ignore-installed 'libvirt-python' || warn "libvirt-python install failed"
}

check_uwsgi() {
  log "Check uwsgi binary (Keystone must not use broken system /bin/uwsgi)"
  if [[ -x "${UWSGI_VENV}" ]]; then
    echo "Good: ${UWSGI_VENV} exists"
  else
    warn "Missing ${UWSGI_VENV} — Keystone may fail. Re-stack or reinstall uwsgi into the venv."
  fi
  if [[ -x /bin/uwsgi ]]; then
    warn "System /bin/uwsgi exists — if Keystone fails with ELF/encutils errors, point units at ${UWSGI_VENV}"
  fi
}

check_nova_cpu_mode() {
  log "Check Nova libvirt cpu_mode (host-passthrough breaks aarch64 QEMU here)"
  local nova_conf="/etc/nova/nova.conf"
  if [[ ! -f "${nova_conf}" ]]; then
    # DevStack sometimes keeps config under /etc/nova or via generated files
    nova_conf="$(sudo find /etc/nova /opt/stack -name 'nova.conf' 2>/dev/null | head -n1 || true)"
  fi
  if [[ -z "${nova_conf}" || ! -f "${nova_conf}" ]]; then
    warn "nova.conf not found — rely on local.conf LIBVIRT_CPU_MODE=none before stack"
    return 0
  fi
  if sudo grep -Eq '^\s*cpu_mode\s*=\s*host-passthrough' "${nova_conf}"; then
    warn "cpu_mode=host-passthrough found in ${nova_conf}"
    warn "Set cpu_mode=none (or LIBVIRT_CPU_MODE=none in local.conf) then restart n-cpu"
  else
    echo "cpu_mode does not look like host-passthrough — OK (or unset)"
  fi
}

smoke() {
  log "Smoke: source openrc and poke Glance / Neutron / Nova"
  [[ -f "${OPENRC}" ]] || die "missing ${OPENRC} — has ./stack.sh completed?"
  # shellcheck disable=SC1090
  source "${OPENRC}" admin admin

  need_cmd openstack
  openstack token issue >/dev/null
  echo "PASS: Keystone token"

  openstack image list
  echo "PASS: Glance list (if empty, upload Cirros aarch64)"

  openstack network list
  echo "PASS: Neutron list"

  openstack compute service list
  echo "PASS: Nova compute services"

  openstack flavor list
  openstack server list
  echo "PASS: smoke finished"
}

hint_cirros() {
  log "Glance tip"
  cat <<'EOF'
If image list has no aarch64 Cirros, upload one (names vary by version):
  # example — adjust URL/name to a known Cirros aarch64 image
  openstack image create "cirros-aarch64" \
    --disk-format qcow2 --container-format bare --public \
    --file /path/to/cirros-*-aarch64-disk.img

Terraform data.tf name= must match: openstack image list
EOF
}

main() {
  echo "DevStack post-fix (ARM/UTM lab protections)"
  echo "DEVSTACK_DIR=${DEVSTACK_DIR}"

  if [[ "${SMOKE_ONLY}" -eq 1 ]]; then
    smoke
    hint_cirros
    exit 0
  fi

  if [[ "${RESTART_ONLY}" -eq 1 ]]; then
    restart_core
    smoke
    exit 0
  fi

  disable_broken_horizon
  check_uwsgi
  ensure_libvirt_python
  check_nova_cpu_mode
  restart_core
  smoke
  hint_cirros
  log "Done. Prefer this script over re-running ./stack.sh when services flake."
}

main
