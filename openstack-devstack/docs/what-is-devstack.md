# What is DevStack?

## Short answer

**DevStack** is an official OpenStack installer script for **developers**.  
It turns one Linux machine into a **complete mini OpenStack cloud** (identity, compute, network, images, …) so you can learn and test without a big production cluster.

It is **not** production. It is a **lab cloud**.

## OpenStack vs DevStack

| Word | Meaning |
|------|---------|
| **OpenStack** | The cloud software (many services that talk over APIs) |
| **DevStack** | A script (`stack.sh`) + config (`local.conf`) that installs OpenStack on one box for learning |
| **Your UTM Ubuntu VM** | The Linux machine where DevStack runs |
| **Guest VM (`test-vm4`)** | A tiny VM *inside* OpenStack (Nova), like a customer instance |

```text
Mac
 └─ UTM Virtualize
     └─ Ubuntu VM  ← DevStack installs OpenStack HERE
         └─ OpenStack Nova creates guest VMs (Cirros) HERE
```

## Main OpenStack services you are using

| Service | Job | Everyday analogy |
|---------|-----|------------------|
| **Keystone** | Login / tokens / “who are you?” | ID badge office |
| **Glance** | Store OS disk images | ISO / image library |
| **Neutron** | Networks, IPs, routers | Virtual cables + switches |
| **Nova** | Create / start / stop VMs | The computer factory |
| **Placement** | Track CPU/RAM inventory | Warehouse stock list |
| **Horizon** | Web UI (optional; ours is flaky) | Browser dashboard |

## What `./stack.sh` did

1. Read `local.conf` (passwords, `HOST_IP`, qemu, network type, …)
2. Clone/pull OpenStack project code under `/opt/stack`
3. Create a Python venv, install packages, configure services
4. Start systemd units like `devstack@n-cpu`, `devstack@q-svc`, …
5. Register endpoints in Keystone so CLI/API know where each service lives

## How you talk to it

1. **On the VM:** `source /opt/stack/devstack/openrc admin admin`
2. **From the Mac repo:** put the same facts in **`.env`** (secret) → `health_check.sh` loads them → `openstack …` commands

`OS_*` environment variables are how the OpenStack CLI finds Keystone and logs in.
