# Day 13–14 — DatabaseInstance Operator (Kopf)

Tiny operator: watches `DatabaseInstance` CRs and creates/deletes a Pod `<name>-pod`.

## What an Operator is

```text
CR (halime-db)  →  Operator watches  →  creates Pod on worker
```

You declare intent; the Operator does the busy work.

## Prerequisites

- kind cluster `dpaas` running
- CRD applied: `kubectl apply -f k8s/databaseinstance-crd.yaml`

## Build image + load into kind (Mac)

```bash
cd ~/Documents/Projects/dpaas_cloud_platform/k8s/operator
docker build -t dpaas-db-operator:dev .
kind load docker-image dpaas-db-operator:dev --name dpaas
```

| Command | Meaning |
|---------|---------|
| `docker build -t ...` | Build operator image |
| `kind load docker-image` | Put image into kind nodes (no registry needed) |

## Deploy operator

```bash
kubectl apply -f k8s/operator/deploy.yaml
kubectl get deploy,pods -l app=dpaas-db-operator
kubectl logs deploy/dpaas-db-operator -f
```

## Create a CR and see a Pod

```bash
kubectl apply -f k8s/databaseinstance-halime-db.yaml
kubectl get dbinst
kubectl get pods -l managed-by=dpaas-db-operator -o wide
```

Expect Pod: `halime-db-pod` on `dpaas-worker`.

## Day 14 — reconcile test

```bash
kubectl delete pod halime-db-pod
kubectl get pods -l managed-by=dpaas-db-operator -w
```

If the operator only acts on create/update of the CR, recreate by:

```bash
kubectl annotate databaseinstance halime-db reconcile="$(date +%s)" --overwrite
# or delete/recreate CR — see runbook below
```

Our operator ensures Pod on create/update of CR. After deleting only the Pod, bump the CR:

```bash
kubectl apply -f k8s/databaseinstance-halime-db.yaml
```

Or patch:

```bash
kubectl patch dbinst halime-db --type merge -p '{"spec":{"size":"small"}}'
```

Delete CR → Pod should go away:

```bash
kubectl delete dbinst halime-db
kubectl get pods -l managed-by=dpaas-db-operator
```
