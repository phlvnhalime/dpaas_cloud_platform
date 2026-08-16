# OpenStack / DevStack kit (Week 1)

**Cloud target:** local DevStack on UTM (Ubuntu 22.04 ARM64).

## Secrets (`.env`)

| File | Commit? | Purpose |
|------|---------|---------|
| [`.env.example`](../.env.example) | yes | Template — safe placeholders |
| `.env` | **never** | Real lab URL + password |
| [`env/local.conf.example`](./env/local.conf.example) | yes | DevStack install settings for the VM (not Mac CLI secrets) |

```bash
cp .env.example .env
./openstack-devstack/scripts/health_check.sh   # auto-loads .env
# or: source openstack-devstack/scripts/load_env.sh
```

## Why this folder exists

Before Terraform (Days 3–4), prove:

1. Keystone auth works
2. Nova / Neutron / Glance answer
3. You can boot a guest VM

## Layout

| Path | Purpose |
|------|---------|
| [HEALTH_CHECKLIST.md](./HEALTH_CHECKLIST.md) | Healthy definition + sign-off |
| [FAILURE_LOG.md](./FAILURE_LOG.md) | What broke and how we fixed it |
| [docs/concepts.md](./docs/concepts.md) | Keystone / Nova / Neutron / Glance |
| [docs/local-devstack-arm-utm.md](./docs/local-devstack-arm-utm.md) | Working lab + recovery |
| [docs/what-is-devstack.md](./docs/what-is-devstack.md) | DevStack explained simply |
| [docs/devstack-rebuild-playbook.md](./docs/devstack-rebuild-playbook.md) | If you lose the lab — rebuild with protections |
| [docs/devstack-scripts-explained.md](./docs/devstack-scripts-explained.md) | Bootstrap + post_fix: every command explained |
| [env/local.conf.example](./env/local.conf.example) | VM `local.conf` that worked |
| [scripts/load_env.sh](./scripts/load_env.sh) | Load repo `.env` → `OS_*` |
| [scripts/health_check.sh](./scripts/health_check.sh) | Automated smoke (Mac) |
| [scripts/devstack_bootstrap.sh](./scripts/devstack_bootstrap.sh) | On VM: clone DevStack + write `local.conf` |
| [scripts/devstack_post_fix.sh](./scripts/devstack_post_fix.sh) | On VM: ARM/UTM fixes + restart Glance path services + smoke |

## Cloud ↔ DPaaS link

| OpenStack idea | Later DPaaS analogue |
|----------------|----------------------|
| Keystone token | API / Databricks auth |
| Nova instance | PaaS DB instance (Week 3 CRUD) |
| Neutron network | Isolation for workloads |
| Glance image | Reproducible base image |
