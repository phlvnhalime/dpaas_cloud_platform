# Bootstrap & post-fix — every command explained

Teacher notes for the two VM scripts.  
Run these scripts **on the Ubuntu DevStack VM**, not on the Mac.

---

## How you start them

### Copy repo from Mac → VM

```bash
scp -r ~/Documents/Projects/dpaas_cloud_platform hpeh@192.168.64.4:~/
```

| Part | Meaning |
|------|---------|
| `scp` | Secure copy (copy files over SSH) |
| `-r` | Recursive — copy the whole folder tree |
| `~/Documents/...` | Source on your Mac |
| `hpeh@192.168.64.4:~/` | User `hpeh` on the VM; put files in their home |

### Become user `stack`

```bash
ssh hpeh@192.168.64.4
sudo -iu stack
```

| Part | Meaning |
|------|---------|
| `ssh` | Remote login |
| `sudo` | Run as another user with privilege |
| `-i` | Simulate full login (loads stack’s environment) |
| `-u stack` | Target user = `stack` |
| together `-iu stack` | “Log in as stack” |

### Run the scripts

```bash
bash ~/dpaas_cloud_platform/openstack-devstack/scripts/devstack_bootstrap.sh
bash ~/dpaas_cloud_platform/openstack-devstack/scripts/devstack_post_fix.sh
```

| Part | Meaning |
|------|---------|
| `bash` | Run the file with the Bash shell |
| path | Which script file to run |

Optional flags:

```bash
bash .../devstack_bootstrap.sh --stack
bash .../devstack_post_fix.sh --smoke
bash .../devstack_post_fix.sh --restart
```

| Flag | Script | Meaning |
|------|--------|---------|
| `--stack` | bootstrap | After prepare, also run `FORCE=yes ./stack.sh` |
| `--smoke` | post_fix | Only test Keystone/Glance/Neutron/Nova |
| `--restart` | post_fix | Only restart core services + smoke |

---

# Part A — `devstack_bootstrap.sh`

**Job:** Prepare DevStack (and optionally install it).

## Safety line at the top

```bash
set -euo pipefail
```

| Part | Meaning |
|------|---------|
| `set -e` | Exit if any command fails |
| `set -u` | Exit if you use an unset variable |
| `set -o pipefail` | If one part of a pipe fails, the whole pipe fails |

## Detect this machine’s IP

```bash
ip -4 -o addr show scope global | awk '{print $4}' | cut -d/ -f1 | head -n1
```

| Part | Meaning |
|------|---------|
| `ip` | Show network settings |
| `-4` | IPv4 only |
| `-o` | One line per address (easy to parse) |
| `addr show` | Show IP addresses |
| `scope global` | Real routable IPs (not localhost) |
| `awk '{print $4}'` | Print the 4th field (`192.168.64.4/24`) |
| `cut -d/ -f1` | Split on `/`, keep IP only |
| `head -n1` | Take the first IP |

That value becomes **`HOST_IP`** in `local.conf` (Keystone/Nova advertise this address).

## Must be user `stack`

```bash
[[ "$(id -un)" == "stack" ]] || die "..."
```

| Part | Meaning |
|------|---------|
| `id -un` | Print current username |
| `[[ ... ]]` | Test condition in Bash |
| `\|\| die` | If test fails, stop with error |

## Create `/opt/stack` and own it

```bash
sudo mkdir -p "${STACK_HOME}"
sudo chown -R stack:stack "${STACK_HOME}"
```

| Part | Meaning |
|------|---------|
| `mkdir` | Make directory |
| `-p` | Create parents; OK if it already exists |
| `chown` | Change owner |
| `-R` | Recursive — all files inside |
| `stack:stack` | User `stack`, group `stack` |

## Download DevStack

```bash
git clone https://opendev.org/openstack/devstack -b "${BRANCH}" "${DEVSTACK_DIR}"
```

| Part | Meaning |
|------|---------|
| `git clone` | Copy a git repository |
| URL | Where DevStack lives |
| `-b stable/2025.1` | Checkout this branch (your lab version) |
| last path | Put it in `/opt/stack/devstack` |

If `.git` already exists, the script **skips** clone (idempotent).

## Write `local.conf` with your protections

```bash
sed "s/^HOST_IP=.*/HOST_IP=${host_ip}/" "${REPO_LOCAL_CONF}" > "${DEVSTACK_DIR}/local.conf"
```

| Part | Meaning |
|------|---------|
| `sed` | Stream editor — change text |
| `s/old/new/` | Substitute |
| `^HOST_IP=.*` | Line starting with `HOST_IP=` |
| `>` | Write output to a new file |

Template already includes:

- `Q_ML2_TENANT_NETWORK_TYPE=local` — Neutron/OVN works on single-node ARM  
- `LIBVIRT_TYPE=qemu` — no `/dev/kvm`  
- `LIBVIRT_CPU_MODE=none` — no `host-passthrough` crash  
- `PYTHON3_VERSION=3.11`  
- `TARGET_BRANCH=...`

## Show important lines

```bash
grep -E '^(HOST_IP|LIBVIRT_|Q_ML2_|TARGET_BRANCH|PYTHON3_VERSION)' local.conf
```

| Part | Meaning |
|------|---------|
| `grep` | Find lines matching a pattern |
| `-E` | Extended regex |
| `^(A\|B\|…)` | Line starts with one of these names |

## Optional install

```bash
cd "${DEVSTACK_DIR}"
FORCE=yes ./stack.sh
```

| Part | Meaning |
|------|---------|
| `cd` | Change directory into DevStack |
| `FORCE=yes` | Environment variable DevStack honors to force install/reinstall behavior |
| `./stack.sh` | The DevStack installer (downloads OpenStack, configures, starts services) — **long** |

After that, run **post_fix** (Part B).

---

# Part B — `devstack_post_fix.sh`

**Job:** Apply lab protections + wake Glance/Neutron/Nova path + smoke test.  
Does **not** run `./stack.sh`.

## 1) Disable broken Horizon (web UI)

```bash
sudo a2dissite horizon.conf
sudo systemctl reload apache2
```

| Part | Meaning |
|------|---------|
| `a2dissite` | Apache: disable a site config |
| `horizon.conf` | Horizon dashboard site |
| `systemctl reload apache2` | Reload web server config without full reboot |

**Why:** On this lab, Horizon often breaks Apache/Django. CLI (`openstack`) is enough.

## 2) Check uwsgi

```bash
# script checks these paths exist / warns
 /opt/stack/data/venv/bin/uwsgi   # good (venv)
 /bin/uwsgi                       # dangerous if Keystone uses it
```

| Idea | Meaning |
|------|---------|
| venv uwsgi | Matches DevStack Python — Keystone happy |
| system `/bin/uwsgi` | Wrong Python → ELF / `encutils` errors |

The script **warns**; it does not blindly `sed` (that burned us once).

## 3) Fix libvirt Python binding

```bash
 /opt/stack/data/venv/bin/pip install --ignore-installed libvirt-python
```

| Part | Meaning |
|------|---------|
| `pip install` | Install a Python package |
| `--ignore-installed` | Reinstall even if system thinks it’s there |
| `libvirt-python` | Python module Nova needs to talk to libvirt (`libvirtmod`) |

**Why:** Nova compute failed without this on our ARM lab.

## 4) Check Nova `cpu_mode`

```bash
sudo grep -Eq '^\s*cpu_mode\s*=\s*host-passthrough' nova.conf
```

| Part | Meaning |
|------|---------|
| `grep` | Search file |
| `-E` | Extended regex |
| `-q` | Quiet (only exit code) |
| pattern | Look for `cpu_mode = host-passthrough` |

**Why:** That mode breaks guest boot on aarch64 QEMU. We want `none` (from `local.conf`).

## 5) Restart the “signal” services (your main ask)

```bash
sudo systemctl restart \
  devstack@ovsdb-server \
  devstack@ovn-northd \
  devstack@ovn-controller \
  devstack@q-svc \
  devstack@placement-api \
  devstack@n-cpu
```

| Part | Meaning |
|------|---------|
| `systemctl restart` | Stop then start a service now |
| `devstack@…` | DevStack’s systemd unit for that component |

| Unit | What it wakes | Why we restart it |
|------|----------------|-------------------|
| `ovsdb-server` | OVN/OVS database | Network brain storage |
| `ovn-northd` | OVN northd | Translates Neutron intent |
| `ovn-controller` | OVN on the host | Applies flows locally |
| `q-svc` | Neutron server | API for networks (fixes empty HashRing / empty nets) |
| `placement-api` | Placement | CPU/RAM inventory for scheduling |
| `n-cpu` | Nova compute | Actually starts VMs (QEMU) |

```bash
sleep 3
```

| Part | Meaning |
|------|---------|
| `sleep 3` | Wait 3 seconds so services finish starting before smoke tests |

## 6) Smoke tests (prove Glance & friends answer)

```bash
source /opt/stack/devstack/openrc admin admin
```

| Part | Meaning |
|------|---------|
| `source` | Load file into current shell |
| `openrc` | Sets `OS_*` login vars |
| `admin admin` | Project/user style args DevStack openrc expects |

```bash
openstack token issue          # Keystone — can we log in?
openstack image list           # Glance — images?
openstack network list         # Neutron — networks?
openstack compute service list # Nova — compute up?
openstack flavor list          # sizes
openstack server list          # VMs
```

| Command | Service you are poking |
|---------|------------------------|
| `token issue` | Keystone |
| `image list` | **Glance** |
| `network list` | Neutron |
| `compute service list` | Nova |
| `flavor list` | Nova flavors |
| `server list` | Nova instances |

```bash
openstack token issue >/dev/null
```

| Part | Meaning |
|------|---------|
| `>/dev/null` | Hide normal output; we only care if it succeeds |

---

## Mental order

```text
bootstrap.sh
  → clone DevStack + local.conf (protections)
  → optional ./stack.sh          # build the cloud

post_fix.sh
  → Horizon off, libvirt-python, checks
  → restart OVN / Neutron / Placement / Nova
  → openstack … list             # Glance & friends signal OK
```

---

## Related

- Scripts: `../scripts/devstack_bootstrap.sh`, `../scripts/devstack_post_fix.sh`  
- Rebuild path: [devstack-rebuild-playbook.md](./devstack-rebuild-playbook.md)  
- Lab facts: [local-devstack-arm-utm.md](./local-devstack-arm-utm.md)
