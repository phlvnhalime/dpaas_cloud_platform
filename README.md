# DPaaS Cloud Platform

In 30 days, the goal is full-stack ownership of a unified DPaaS product that merges cloud provisioning with data intelligence — users spin up data environments that sync with live analytics feeds.

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

## Current milestone — Week 2

Kubernetes + Operator: two-node **kind** cluster, nginx demos, and a `DatabaseInstance` CRD with a Kopf operator that creates/deletes a Pod. Next: **Go** PaaS API + Databricks Bronze.

```bash
kind create cluster --name dpaas --config k8s/kind-two-node.yaml
kubectl apply -f k8s/databaseinstance-crd.yaml
kubectl apply -f k8s/operator/deploy.yaml
kubectl apply -f k8s/databaseinstance-halime-db.yaml
kubectl get dbinst,pods
```

Operator guide: [k8s/operator/README.md](./k8s/operator/README.md)

## Strike map

| Week | Focus |
|------|--------|
| 1 | IaC — OpenStack (DevStack) + Terraform VM |
| 2 | Kubernetes + Operator |
| 3 | **Go** PaaS API + Databricks Bronze |
| 4 | **React** + JWT + Gold + CI/CD |
