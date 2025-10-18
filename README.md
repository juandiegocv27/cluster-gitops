# cluster-gitops

A GitOps repository for managing Kubernetes cluster configurations using Flux CD.

## Repository Structure

```
cluster-gitops/
├── apps/                      # Application definitions
│   ├── base/                  # Base application configurations
│   │   └── example-app/       # Example application
│   ├── dev/                   # Development environment overlays
│   ├── staging/               # Staging environment overlays
│   └── production/            # Production environment overlays
├── infrastructure/            # Infrastructure components
│   ├── base/                  # Base infrastructure
│   ├── controllers/           # Flux controllers
│   └── sources/              # Git repository sources
└── clusters/                  # Cluster-specific configurations
    ├── dev/                   # Development cluster
    ├── staging/               # Staging cluster
    └── production/            # Production cluster
```

## Getting Started

### Prerequisites

- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- [kustomize](https://kustomize.io/) installed (optional, kubectl has built-in support)
- [flux CLI](https://fluxcd.io/flux/cmd/) installed
- Access to a Kubernetes cluster

### Initial Setup

1. **Bootstrap Flux on your cluster:**

```bash
flux bootstrap github \
  --owner=juandiegocv27 \
  --repository=cluster-gitops \
  --branch=main \
  --path=./clusters/production \
  --personal
```

2. **Verify Flux installation:**

```bash
flux check
```

3. **Monitor reconciliation:**

```bash
flux get kustomizations
flux get sources git
```

## Usage

### Adding a New Application

1. Create base manifests in `apps/base/<app-name>/`
2. Create a `kustomization.yaml` file in the app directory
3. Add overlays for each environment in `apps/{dev,staging,production}/`
4. Commit and push changes - Flux will automatically sync

### Deploying to Different Environments

The repository uses Kustomize overlays to manage environment-specific configurations:

- **Development**: Lower replica counts, development-specific settings
- **Staging**: Similar to production but with fewer resources
- **Production**: Full production configuration with high availability

### Managing Secrets

**Warning**: Never commit secrets directly to this repository!

Use Flux's built-in secret management or external secret operators:

- [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
- [SOPS](https://fluxcd.io/flux/guides/mozilla-sops/)
- [External Secrets Operator](https://external-secrets.io/)

## Flux Commands

```bash
# Check Flux components
flux check

# Get all Flux resources
flux get all

# Reconcile a specific kustomization
flux reconcile kustomization flux-system --with-source

# Suspend reconciliation
flux suspend kustomization flux-system

# Resume reconciliation
flux resume kustomization flux-system

# View logs
flux logs --follow --all-namespaces
```

## Best Practices

1. **Never commit secrets** - Use secret management solutions
2. **Use environment-specific overlays** - Keep base configurations DRY
3. **Test changes locally** - Use `kubectl kustomize` before committing
4. **Keep infrastructure separate** - Separate apps from infrastructure configs
5. **Version control everything** - All cluster state should be in Git
6. **Review PRs carefully** - Changes auto-deploy via GitOps

## Testing Changes Locally

Before pushing changes, test your Kustomize configurations:

```bash
# Test dev environment
kubectl kustomize apps/dev

# Test staging environment
kubectl kustomize apps/staging

# Test production environment
kubectl kustomize apps/production

# Test full cluster configuration
kubectl kustomize clusters/production
```

## Troubleshooting

### Flux not syncing

```bash
# Check Flux status
flux check

# View reconciliation status
flux get kustomizations

# Force reconciliation
flux reconcile kustomization flux-system --with-source
```

### Application not deploying

```bash
# Check kustomization status
kubectl get kustomizations -n flux-system

# View events
kubectl describe kustomization <name> -n flux-system

# Check logs
flux logs --kind=Kustomization --name=<name>
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Test locally with `kubectl kustomize`
4. Create a pull request
5. After merge, Flux will automatically deploy changes

## Resources

- [Flux Documentation](https://fluxcd.io/flux/)
- [Kustomize Documentation](https://kustomize.io/)
- [GitOps Principles](https://opengitops.dev/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)

## License

MIT