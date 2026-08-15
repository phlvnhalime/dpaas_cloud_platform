# OpenStack healthy checklist (Day 1–2)

## Environment

| Field | Value |
|-------|--------|
| Target | Local DevStack (UTM Ubuntu ARM64) |
| Region / project | `RegionOne` / `admin` |
| Auth (Mac) | Repo-root **`.env`** (gitignored) |
| Auth (VM) | `source /opt/stack/devstack/openrc admin admin` |
| Host | `192.168.64.4` |
| Date checked | 2026-08-13 |

## Smoke tests

| Check | Pass? | Notes |
|-------|-------|-------|
| Token | [x] | Keystone OK |
| Services | [x] | Catalog populated |
| Catalog | [x] | Endpoints on HOST_IP |
| Networks | [x] | `private` + public; ML2 `local` |
| Images | [x] | Cirros **aarch64** |
| Servers | [x] | `test-vm4` ACTIVE `10.0.0.36` |
| Flavors | [x] | e.g. `cirros256` |
| Compute | [x] | `n-cpu` up |

## Secrets hygiene

- [x] Real password only in `.env` (gitignored) and on the VM
- [x] `.env.example` committed with placeholders only

## Sign-off

- [x] Obsidian: `Notes/DevStack_Local_Success.md`
- [x] Repo docs point at local DevStack
