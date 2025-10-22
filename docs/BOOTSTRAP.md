
# 🚀 **Cluster Bootstrap Guide — ShopStack**

A complete guide to create, verify, and test repeatability for the **ShopStack Kubernetes cluster** using Kind.

---

## 🧩 **Prerequisites**

Before running any command, ensure your environment includes:

| Requirement | Description | Verify Command |
|--------------|--------------|----------------|
| **Docker** | Container runtime for Kind nodes. | `docker run --rm hello-world` |
| **Kind** | Tool for running Kubernetes in Docker. | `kind version` |
| **Kubectl** | CLI for interacting with the cluster. | `kubectl version --client` |
| **Make** | Automates cluster lifecycle commands. | `make -v` |

Ensure your user is added to the Docker group:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

## 🧱 **Cluster Creation**

Create the cluster using Kind and the provided configuration file:

kind create cluster --name shopstack --config kind-config.yaml

## 🧠 **What Happens**
```
	•	One control-plane node and two worker nodes are created.
	•	The CNI (KindNet) and default StorageClass are installed automatically.
	•	The context kind-shopstack is set in your kubeconfig.
```
Verify the context:
```
kubectl config current-context
```
Expected output:
```
kind-shopstack
```

---

## 🔍 **Verification Steps**

After the cluster is created, verify node and CoreDNS readiness:
```
kubectl get nodes
kubectl get pods -n kube-system | grep coredns
```
Expected:
```
NAME                        STATUS   ROLES           AGE   VERSION
shopstack-control-plane     Ready    control-plane   1m    v1.34.0
shopstack-worker            Ready    <none>          1m    v1.34.0
shopstack-worker2           Ready    <none>          1m    v1.34.0
```
CoreDNS pods should appear as Running.

---

## 🔁 **Repeatability Test**

The Makefile automates cluster creation, destruction, and validation to ensure reproducibility.

Run the automated test:

make repeat-test

## 🧠 **What It Does**
```
	1.	Deletes any existing Kind cluster.
	2.	Recreates it twice, verifying readiness each time.
	3.	Logs all outputs to repeat.log.
```
Example output:
```
=== Run 1 ===
Deleting kind cluster...
Creating kind cluster...
Verifying nodes and CoreDNS...

=== Run 2 ===
Deleting kind cluster...
Creating kind cluster...
Verifying nodes and CoreDNS...
```
---

## 🧰 **Common Make Targets**

Command	Description
```
make cluster-up	Creates the cluster using Kind.
make cluster-down	Deletes the cluster.
make verify	Checks node and CoreDNS readiness.
make repeat-test	Runs the repeatability test and logs output.
```
---

## 🔒 **Security Notes**

	•	The cluster API is bound only to 127.0.0.1 (not externally accessible).
	•	Docker runs locally; your user has non-root access to the Docker socket.
	•	The kubeconfig file is stored at ~/.kube/config. Secure it with:
```
chmod 600 ~/.kube/config
```
No exposed NodePorts or ingress controllers are created by default.
---

## 🗂️ **Project Structure**
```
cluster-gitops/
├── Makefile
├── kind-config.yaml
├── repeat.log
└── docs/
    └── BOOTSTRAP.md
```
---

## 🧭 **Next Steps**

	1.	✅ Confirm cluster readiness with make verify.
	2.	✅ Commit logs and documentation to GitHub.
	3.	🔜 Continue with the apps-sre repository to deploy sample applications.
	4.	🔐 Optionally integrate GitOps tools such as ArgoCD or Flux.
---

## 🧩 **Related Documentation**

	•	infra-terraform → Infrastructure and backend configuration.
	•	cluster-gitops → Cluster provisioning and validation.
	•	apps-sre → Application and SRE layer deployment.

Together, these repositories form a consistent, reproducible workflow for ShopStack infrastructure and application environments.

