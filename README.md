# cluster-gitops — ShopStack GitOps Configuration

> Kubernetes GitOps source of truth for the ShopStack SRE portfolio project. Argo CD watches this repository and continuously reconciles the cluster state to match what is declared here. Nothing is applied to the cluster manually.

Part of the [ShopStack](https://github.com/juandiegocv27/shopstack) portfolio project.

---

## What This Repo Does

This repository is the **single source of truth for cluster state**. It contains:

- Argo CD Application manifests (App-of-Apps pattern)
- Kustomize base manifests for each service
- Environment-specific overlays (dev / staging / prod)
- Infrastructure and monitoring application definitions

The CI pipeline in `apps-sre` opens automated PRs to this repo when a new image is built. Merging the PR is the deployment action.

---

## App-of-Apps Structure

```
apps/
├── root/                        # Root Applications — managed by Argo CD bootstrap
│   ├── apps-business.yaml       # Parent app → apps/business/*
│   ├── apps-infra.yaml          # Parent app → apps/infra/*
│   └── apps-monitoring.yaml     # Parent app → apps/monitoring/*
│
├── business/                    # Business-tier Application manifests
│   └── catalog-dev.yaml         # catalog service → overlays/dev
│
├── catalog/                     # Catalog service manifests
│   ├── base/
│   │   ├── deployment.yaml      # Base Deployment (no hardcoded namespace/tag)
│   │   ├── service.yaml         # ClusterIP Service
│   │   └── kustomization.yaml
│   └── overlays/
│       └── dev/
│           ├── kustomization.yaml           # Image tag + namespace override
│           └── patch-image-pull-secret.yaml # ECR pull secret patch
│
├── infra/                       # Infrastructure-tier apps (local-path-provisioner, etc.)
├── monitoring/                  # Monitoring-tier apps (Prometheus + Grafana — in progress)
└── local-path-provisioner/      # Storage provisioner for local cluster
```

---

## How Deployment Works

### Automated (via CI)

```
apps-sre CI builds new image
        │
        ▼
CI opens PR: bump newTag in overlays/dev/kustomization.yaml
        │
        ▼
PR merged to main
        │
        ▼
Argo CD detects diff (polls every 3 min or webhook)
        │
        ▼
Argo CD syncs → kubectl applies new Deployment
        │
        ▼
Rolling update → new pod Running → health check passes
```

### Manual sync (when needed)

```bash
argocd app sync catalog-dev
argocd app sync apps-business
```

---

## Branch Strategy

| Branch | Purpose |
|---|---|
| `main` | Stable — what Argo CD applications targeting `main` track |
| `dev` | Active development — App-of-Apps parent apps target this branch |

CI-generated image bump PRs merge into `main`. Changes to `dev` are promoted by merging `main → dev`.

---

## Cluster

| Node | Role | IP |
|---|---|---|
| `talos-43f-se5` | control-plane | `192.168.100.183` |
| `talos-che-x98` | worker | `192.168.100.104` |

Kubernetes v1.34.1 on Talos Linux v1.11.3. Managed via `talosctl` and `kubectl` — no SSH access.

---

## Namespaces

| Namespace | Contents |
|---|---|
| `argocd` | Argo CD control plane |
| `catalog` | Catalog service |
| `monitoring` | Prometheus + Grafana (in progress) |
| `shopstack` | Shared infrastructure resources |

---

## Argo CD Applications

| Application | Sync Status | Tracks |
|---|---|---|
| `infra-base` | Synced | `apps/infra/infra-base` |
| `apps-infra` | Synced | `apps/infra` |
| `apps-business` | Synced | `apps/business` (branch: dev) |
| `apps-monitoring` | Synced | `apps/monitoring` (branch: dev) |
| `catalog-dev` | Synced | `apps/catalog/overlays/dev` (branch: main) |

---

## Adding a New Service

1. Create `apps/catalog-equivalent/base/` with Deployment + Service + kustomization.yaml
2. Create `apps/catalog-equivalent/overlays/dev/kustomization.yaml` with image and namespace override
3. Add `apps/business/new-service-dev.yaml` — an Argo CD Application pointing to the overlay
4. Commit and push to `dev` — `apps-business` auto-syncs and spawns the new Application

---

## ECR Pull Secret

The cluster pulls images from private AWS ECR. The pull secret is managed as a `docker-registry` Secret in each service namespace. The Kustomize overlay patches `imagePullSecrets` onto the Deployment.

```bash
# Refresh the secret (expires every 12 hours)
kubectl create secret docker-registry ecr-pull-secret \
  --docker-server=770132776547.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-east-1) \
  --namespace catalog \
  --dry-run=client -o yaml | kubectl apply -f -
```

> Automated token refresh via CronJob or External Secrets Operator is planned.

---

## Related Repositories

| Repo | Role |
|---|---|
| [`shopstack`](https://github.com/juandiegocv27/infra-terraform) | Provisions AWS resources (ECR, IAM, Secrets Manager) |
| [`apps-sre`](https://github.com/juandiegocv27/apps-sre) | Application code and CI pipeline — opens PRs to this repo |
