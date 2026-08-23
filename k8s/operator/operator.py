"""
Day 13 — tiny Operator (Kopf).

Watches DatabaseInstance CRs (dpaas.example.com/v1).
On create/update: ensures a Pod named <cr-name>-pod exists.
On delete: deletes that Pod.

Run inside the cluster (see k8s/operator/).
"""
import kopf
import kubernetes
from kubernetes.client.rest import ApiException


GROUP = "dpaas.example.com"
VERSION = "v1"
PLURAL = "databaseinstances"


def pod_name(cr_name: str) -> str:
    return f"{cr_name}-pod"


def ensure_pod(name: str, namespace: str, size: str, owner: str) -> None:
    api = kubernetes.client.CoreV1Api()
    body = {
        "apiVersion": "v1",
        "kind": "Pod",
        "metadata": {
            "name": pod_name(name),
            "namespace": namespace,
            "labels": {
                "app": "databaseinstance",
                "instance": name,
                "managed-by": "dpaas-db-operator",
            },
        },
        "spec": {
            "containers": [
                {
                    "name": "db",
                    # Lightweight stand-in for a DB process (lab only)
                    "image": "busybox:1.36",
                    "command": ["sh", "-c", "echo owner=%s size=%s; sleep infinity" % (owner, size)],
                }
            ]
        },
    }
    try:
        api.read_namespaced_pod(pod_name(name), namespace)
        kopf.info({}, reason="PodExists", message=f"Pod {pod_name(name)} already exists")
    except ApiException as e:
        if e.status == 404:
            api.create_namespaced_pod(namespace, body)
            kopf.info({}, reason="PodCreated", message=f"Created Pod {pod_name(name)}")
        else:
            raise


def delete_pod(name: str, namespace: str) -> None:
    api = kubernetes.client.CoreV1Api()
    try:
        api.delete_namespaced_pod(pod_name(name), namespace)
        kopf.info({}, reason="PodDeleted", message=f"Deleted Pod {pod_name(name)}")
    except ApiException as e:
        if e.status != 404:
            raise

"""
    kopt is a library that allows you to write operators for Kubernetes.
    It is a Python library that provides a framework for writing operators for Kubernetes.
        - on startup, it configures the operator settings
        - on create, it ensures a Pod named <cr-name>-pod exists.
        - on update, it ensures a Pod named <cr-name>-pod exists.
        - on resume, it ensures a Pod named <cr-name>-pod exists.
        - on delete, it deletes the Pod named <cr-name>-pod.
"""

@kopf.on.startup()
def configure(settings: kopf.OperatorSettings, **_):
    settings.networking.request_timeout = 60


@kopf.on.create(GROUP, VERSION, PLURAL)
@kopf.on.update(GROUP, VERSION, PLURAL)
@kopf.on.resume(GROUP, VERSION, PLURAL)
def reconcile(spec, name, namespace, **_):
    size = spec.get("size", "small")
    owner = spec.get("owner", "unknown")
    ensure_pod(name, namespace, size, owner)
    return {"phase": "Running", "podName": pod_name(name)}


@kopf.on.delete(GROUP, VERSION, PLURAL)
def cleanup(name, namespace, **_):
    delete_pod(name, namespace)
