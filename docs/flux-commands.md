# Essential Flux Commands

## Key commands to know

| Command | Description |
|---------|-------------|
| `flux check` | Checks the status of Flux components |
| `flux get all` | Lists all Flux resources and their status |
| `flux get sources git` | Displays GitRepositories |
| `flux get kustomizations` | Displays Kustomizations |
| `flux reconcile source git <name>` | Forces resync of a repository |
| `flux reconcile kustomization <name>` | Forces reconciliation of a Kustomization |
| `flux events` | Displays recent events |
| `flux logs` | Displays controller logs |
| `flux suspend kustomization <name>` | Pauses a Kustomization |
| `flux resume kustomization <name>` | Resumes a suspended Kustomization |