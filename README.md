# DPaaS Cloud Platform

In 30 days, the goal is full-stack ownership of a unified DPaaS product that merges cloud provisioning with data intelligence — users spin up data environments that sync with live analytics feeds.

## Stack (locked 2026-08-15)

| Layer | Choice |
|-------|--------|
| Cloud lab | Local DevStack (UTM Ubuntu ARM64) |
| Backend API | **Go** |
| Frontend | **React** |
| .NET | Parallel learning only (not the main API this month) |

## Current milestone — Week 1

DevStack is healthy; secrets live in **`.env`** (gitignored). Next: Terraform against this lab.

```bash
# One-time CLI setup on the Mac
python3 -m venv .venv
source .venv/bin/activate
pip install -r openstack-devstack/requirements.txt

cp .env.example .env
./openstack-devstack/scripts/health_check.sh
```

On the VM:

```bash
ssh hpeh@192.168.64.4
sudo -iu stack
source /opt/stack/devstack/openrc admin admin
openstack server list
```

Lab guide: [openstack-devstack/docs/local-devstack-arm-utm.md](./openstack-devstack/docs/local-devstack-arm-utm.md)

## Strike map

| Week | Focus |
|------|--------|
| 1 | IaC — OpenStack (DevStack) + Terraform VM |
| 2 | Kubernetes + Operator |
| 3 | **Go** PaaS API + Databricks Bronze |
| 4 | **React** + JWT + Gold + CI/CD |
