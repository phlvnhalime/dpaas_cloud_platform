# Env files in this kit

## Mac repo secrets → `.env` (preferred)

| File | Where | Commit? |
|------|-------|---------|
| `../../.env.example` | repo root | yes |
| `../../.env` | repo root | **no** |

Holds `OS_AUTH_URL`, `OS_USERNAME`, `OS_PASSWORD`, … for the OpenStack CLI from your Mac.

## DevStack install config on the VM → `local.conf`

| File | Where | Commit? |
|------|-------|---------|
| `local.conf.example` | this folder | yes (template) |
| `/opt/stack/devstack/local.conf` | Ubuntu VM | lives only on the VM |

That file configures **how DevStack is installed** (HOST_IP, qemu, passwords). It is not the same as Mac `.env`, but the password should match what you put in `.env`.
