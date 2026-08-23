# DPaaS Cloud Platform

In 30 days, the goal is full-stack ownership of a unified DPaaS product that merges cloud provisioning with data intelligence — users spin up data environments that sync with live analytics feeds.

**Progress — 2 of 4 weeks done**

```text
[████████████░░░░░░░░░░░░░░░░]  50%
Week 1  ████  done
Week 2  ████  done
Week 3  ░░░░  next
Week 4  ░░░░
```

## Stack (locked 2026-08-15)

| Layer | Choice |
|-------|--------|
| Cloud lab | Local DevStack (UTM Ubuntu ARM64) |
| Backend API | **Go** |
| Frontend | **React** |

## Week 1

DevStack is healthy; secrets live in **`.env`** (gitignored). Terraform targets this lab.

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

## Week 2

Kubernetes + Operator: two-node **kind** cluster, nginx demos, and a `DatabaseInstance` CRD with a Kopf operator that creates/deletes a Pod.

```bash
kind create cluster --name dpaas --config k8s/kind-two-node.yaml
kubectl apply -f k8s/databaseinstance-crd.yaml
kubectl apply -f k8s/operator/deploy.yaml
kubectl apply -f k8s/databaseinstance-halime-db.yaml
kubectl get dbinst,pods
```

Operator guide: [k8s/operator/README.md](./k8s/operator/README.md)

## Current milestone — Week 3

**Go** PaaS API + Databricks Bronze.

## Strike map

| Week | Focus | Status |
|------|--------|--------|
| 1 | IaC — OpenStack (DevStack) + Terraform VM | done |
| 2 | Kubernetes + Operator | done |
| 3 | **Go** PaaS API + Databricks Bronze | next |
| 4 | **React** + JWT + Gold + CI/CD | |
