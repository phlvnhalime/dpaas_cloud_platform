# Rebuild DevStack lab from zero (your protection playbook)

**Goal:** If you lose the UTM VM, rebuild without re-learning every ARM bug by hand.

**Remember:** `./stack.sh` **installs** the cloud. Terraform only creates VMs **inside** a cloud.

## Two scripts

| Script | When | Runs where |
|--------|------|------------|
| [`../scripts/devstack_bootstrap.sh`](../scripts/devstack_bootstrap.sh) | Fresh Ubuntu; clone DevStack + write `local.conf` (+ optional `./stack.sh`) | Ubuntu as user `stack` |
| [`../scripts/devstack_post_fix.sh`](../scripts/devstack_post_fix.sh) | After stack, after reboot, when Glance/Neutron/Nova flake | Ubuntu as `stack` (needs sudo) |

`local.conf` template with baked-in protections: [`../env/local.conf.example`](../env/local.conf.example)

**Every command explained (teacher notes):** [devstack-scripts-explained.md](./devstack-scripts-explained.md)

---

## Full rebuild path

### 1) New UTM Ubuntu (same as Day 2)

- Virtualize (not Emulate), ARM64, ~8 GB RAM, ~60 GB disk  
- User `hpeh`, create `stack` with sudo, home `/opt/stack`

### 2) Copy this repo onto the VM

From **Mac**:

```bash
scp -r ~/Documents/Projects/dpaas_cloud_platform hpeh@192.168.64.4:~/
```

| Part | Meaning |
|------|---------|
| `scp` | Copy files over SSH |
| `-r` | Recursive (whole folder) |
| `hpeh@192.168.64.4:~/` | Destination home on the VM |

### 3) Bootstrap (prepare + optional stack)

On the VM:

```bash
sudo -iu stack
bash ~/dpaas_cloud_platform/openstack-devstack/scripts/devstack_bootstrap.sh
```

Review `/opt/stack/devstack/local.conf`, then either:

```bash
cd /opt/stack/devstack
FORCE=yes ./stack.sh
```

or:

```bash
bash ~/dpaas_cloud_platform/openstack-devstack/scripts/devstack_bootstrap.sh --stack
```

| Flag / env | Meaning |
|------------|---------|
| `FORCE=yes` | Allow re-stack / force install behavior DevStack expects |
| `--stack` | Bootstrap script will run `./stack.sh` for you |

### 4) Post-fix (Glance / Neutron / Nova protections)

```bash
bash ~/dpaas_cloud_platform/openstack-devstack/scripts/devstack_post_fix.sh
```

| Flag | Meaning |
|------|---------|
| *(none)* | Horizon off if needed, libvirt-python, checks, restart core units, smoke |
| `--restart` | Only restart OVN/Neutron/Placement/n-cpu + smoke |
| `--smoke` | Only Keystone/Glance/Neutron/Nova list checks |

This is the “signal” path you meant: restart / re-check **Glance**, **Neutron (OVN)**, **Placement**, **Nova** so they answer again.

### 5) Point Mac tools at the new IP

If DHCP changed the IP, update:

- Mac `.env` → `OS_AUTH_URL`
- `terraform/terraform.tfvars` → `os_auth_url`
- `local.conf` `HOST_IP` (bootstrap auto-detects on prepare)

Then on Mac: `./openstack-devstack/scripts/health_check.sh` and `terraform plan`.

---

## What is “protection code”?

Lessons already encoded:

| Problem | Protection |
|---------|------------|
| Nested ARM, no KVM | `LIBVIRT_TYPE=qemu` in `local.conf` |
| Guest boot / passthrough | `LIBVIRT_CPU_MODE=none` |
| Empty networks / HashRing | `Q_ML2_TENANT_NETWORK_TYPE=local` + OVN/q-svc restart |
| Horizon Apache/Django mess | `a2dissite horizon.conf` — use CLI |
| `libvirtmod` missing | `pip install --ignore-installed libvirt-python` in venv |
| Placement empty | restart `placement-api` + `n-cpu` |
| Wrong image arch | Cirros **aarch64** in Glance |

---

## Do not

- Re-run `./stack.sh` every day — use `devstack_post_fix.sh --restart` or start the UTM VM  
- Expect Terraform to install DevStack  
- Commit real passwords; keep using `.env` / `terraform.tfvars` (gitignored)
