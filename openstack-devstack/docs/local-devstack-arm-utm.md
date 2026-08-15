# Local DevStack on UTM ARM64 (Apple Silicon)

**Status (2026-08-13):** Working lab — DevStack `stable/2025.1` + guest VM `ACTIVE`.

## Lab topology

```text
MacBook Air M4 (16 GB)
  └── UTM Virtualize (not Emulate)
        └── Ubuntu 22.04.5 Server ARM64
              HOST_IP=192.168.64.4
              user hpeh → sudo -iu stack
              /opt/stack/devstack
```

| Resource | Value used |
|----------|------------|
| VM RAM / CPU / disk | 8 GB / 4 cores / ~60 GB `/` |
| Branch | `stable/2025.1` |
| Python | 3.11 (`PYTHON3_VERSION=3.11`) |
| Virt | `LIBVIRT_TYPE=qemu` (no `/dev/kvm`) |
| CPU mode | `LIBVIRT_CPU_MODE=none` |
| Tenant nets | `Q_ML2_TENANT_NETWORK_TYPE=local` |

## Auth

**On the VM (simplest):**

```bash
sudo -iu stack
source /opt/stack/devstack/openrc admin admin
# password: secret (lab only)
```

**From the Mac repo (secrets in `.env`, never commit):**

```bash
cp .env.example .env          # once
./openstack-devstack/scripts/health_check.sh   # auto-loads .env
```

## Prove healthy

```bash
openstack token issue
openstack service list
openstack image list
openstack network list
openstack compute service list
openstack flavor list
openstack server list
```

Expected guest proof: Cirros **aarch64** image + small flavor → server `ACTIVE` on `private`.

## Do not re-run `./stack.sh` lightly

Prefer service restarts and config edits. Full re-stack is hours and fragile on ARM.

```bash
sudo systemctl restart \
  devstack@ovsdb-server \
  devstack@ovn-northd \
  devstack@ovn-controller \
  devstack@q-svc \
  devstack@placement-api \
  devstack@n-cpu
```

## Recovery cheat sheet

| Symptom | Fix |
|---------|-----|
| System `/bin/uwsgi` + wrong Python | Point Keystone/Horizon jobs at `/opt/stack/data/venv/bin/uwsgi` |
| Horizon Apache 500 (wrong Django) | `a2dissite horizon.conf`; use CLI |
| Empty networks / OVN HashRing | `tenant_network_types=local`; restart OVN + `q-svc` |
| No KVM | `LIBVIRT_TYPE=qemu` |
| `libvirtmod` import error | `pip install --ignore-installed libvirt-python` into DevStack venv |
| Empty Placement inventory | Restart `placement-api` + `n-cpu` |
| Guest fail: `host-passthrough` | `cpu_mode=none` / `LIBVIRT_CPU_MODE=none` |
| Wrong Cirros arch | Use `cirros-*-aarch64-disk` |

## Example `local.conf`

See [../env/local.conf.example](../env/local.conf.example).

## See also

[what-is-devstack.md](./what-is-devstack.md) · [local-devstack-fallback.md](./local-devstack-fallback.md)
