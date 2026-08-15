# OpenStack target — failure & recovery log

## Entry 1 — Day 1: health check without auth

| Field | Value |
|-------|--------|
| Date | 2026-08-12 |
| Result | Health check failed — no `OS_*` auth in the shell yet |

We had installed the OpenStack CLI and the smoke script, but the cloud was not running on this laptop yet. Next step was to build local DevStack.

## Entry 2 — Day 2: local DevStack success

| Field | Value |
|-------|--------|
| Date | 2026-08-13 |
| Path | UTM → Ubuntu 22.04.5 ARM64 → DevStack `stable/2025.1` |
| HOST_IP | `192.168.64.4` |
| Result | Smoke green + guest `test-vm4` **ACTIVE** |

### Fixes that mattered

| Area | Fix |
|------|-----|
| uwsgi | Use `/opt/stack/data/venv/bin/uwsgi` |
| Horizon | Disable site; use CLI |
| Neutron | `tenant_network_types=local`; restart OVN |
| Nova | `LIBVIRT_TYPE=qemu` |
| libvirt | Reinstall `libvirt-python` in venv |
| Placement | Restart placement + n-cpu |
| Guest boot | `LIBVIRT_CPU_MODE=none` |

Full guide: [docs/local-devstack-arm-utm.md](./docs/local-devstack-arm-utm.md)

### Secrets

Lab auth for the Mac CLI lives in **repo-root `.env`** (gitignored). Template: `.env.example`.
