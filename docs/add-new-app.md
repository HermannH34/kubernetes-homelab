# Adding a New App to the Cluster

This guide walks through deploying a new app following the same pattern as `saas-starter`. The cluster uses FluxCD with a GitOps workflow — every change goes through Git.

## Prerequisites

- App image pushed to GHCR (`ghcr.io/<owner>/<app-name>`)
- Image tagged with the format `YYYYMMDD-HHmmss` (e.g. `20260430-083000`) — FluxCD uses this to detect and select the latest version
- SOPS/Age configured locally for secret encryption

---

## Directory structure to create

```
apps/
  base/<app-name>/
    namespace.yaml
    deployment.yaml
    service.yaml
    imagerepository.yaml
    imagepolicy.yaml
    kustomization.yaml
  staging/<app-name>/
    app-secrets.yaml      # SOPS-encrypted
    database.yaml         # if using CNPG Postgres
    kustomization.yaml
```

---

## Step 1 — Base manifests

**`apps/base/<app-name>/namespace.yaml`**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: <app-name>
```

**`apps/base/<app-name>/service.yaml`**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: <app-name>
  namespace: <app-name>
spec:
  selector:
    app: <app-name>
  ports:
    - protocol: TCP
      port: <port>
      targetPort: <port>
```

**`apps/base/<app-name>/deployment.yaml`**

Two important details:
- The `# {"$imagepolicy": "flux-system:<app-name>"}` marker tells FluxCD which images to auto-update
- Add a `/api/health` endpoint in your app and use it for probes (avoids triggering full SSR on each probe)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: <app-name>
  namespace: <app-name>
spec:
  replicas: 1
  selector:
    matchLabels:
      app: <app-name>
  template:
    metadata:
      labels:
        app: <app-name>
    spec:
      initContainers:
        - name: migrate                          # remove if no DB migrations
          # {"$imagepolicy": "flux-system:<app-name>"}
          image: ghcr.io/<owner>/<app-name>:latest
          command: ["node", "node_modules/.bin/drizzle-kit", "migrate"]
          env:
            - name: POSTGRES_URL
              valueFrom:
                secretKeyRef:
                  name: <app-name>-db-app
                  key: uri
      containers:
        - name: <app-name>
          # {"$imagepolicy": "flux-system:<app-name>"}
          image: ghcr.io/<owner>/<app-name>:latest
          ports:
            - containerPort: <port>
          envFrom:
            - secretRef:
                name: <app-name>-env
          readinessProbe:
            httpGet:
              path: /api/health
              port: <port>
            initialDelaySeconds: 15
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /api/health
              port: <port>
            initialDelaySeconds: 30
            periodSeconds: 30
          resources:
            requests:
              memory: "256Mi"
              cpu: "100m"
            limits:
              memory: "512Mi"
              cpu: "500m"
```

> **Resources:** Start with these defaults and tune after observing real usage in Grafana (`container_memory_working_set_bytes`, `container_cpu_usage_seconds_total`).

**`apps/base/<app-name>/imagerepository.yaml`**
```yaml
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImageRepository
metadata:
  name: <app-name>
  namespace: flux-system
spec:
  image: ghcr.io/<owner>/<app-name>
  interval: 1m
```

**`apps/base/<app-name>/imagepolicy.yaml`**
```yaml
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImagePolicy
metadata:
  name: <app-name>
  namespace: flux-system
spec:
  imageRepositoryRef:
    name: <app-name>
  filterTags:
    pattern: '^[0-9]{8}-[0-9]{6}$'
    extract: '$0'
  policy:
    alphabetical:
      order: asc
```

**`apps/base/<app-name>/kustomization.yaml`**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - namespace.yaml
  - deployment.yaml
  - service.yaml
  - imagerepository.yaml
  - imagepolicy.yaml
```

---

## Step 2 — Staging overlay

**`apps/staging/<app-name>/database.yaml`** *(skip if no Postgres)*
```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: <app-name>-db
  namespace: <app-name>
spec:
  instances: 3
  storage:
    size: 5Gi
  bootstrap:
    initdb:
      database: <db-name>
      owner: <db-owner>
```

**`apps/staging/<app-name>/app-secrets.yaml`** — fill in values, then encrypt
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: <app-name>-env
  namespace: <app-name>
type: Opaque
stringData:
  KEY: value
  OTHER_KEY: value
```

Encrypt before committing:
```bash
sops --encrypt --in-place apps/staging/<app-name>/app-secrets.yaml
```

**`apps/staging/<app-name>/kustomization.yaml`**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - app-secrets.yaml
  - database.yaml    # remove if no DB
```

---

## Step 3 — Register the app

Add the new app to both kustomizations:

**`apps/base/kustomization.yaml`**
```yaml
resources:
  - ./saas-starter
  - ./<app-name>      # add this
```

**`apps/staging/kustomization.yaml`**
```yaml
resources:
  - ../base
  - ./saas-starter
  - ./<app-name>      # add this
```

---

## Step 4 — Verify

```bash
# Force FluxCD to reconcile immediately
flux reconcile source git flux-system
flux reconcile kustomization apps

# Check everything is running
flux get all
kubectl get pods -n <app-name>

# Check image automation picked up the new policy
flux get image policy <app-name>
flux get image repository <app-name>
```

---

## How image auto-update works

Once deployed, FluxCD monitors GHCR every minute. When a new image with a `YYYYMMDD-HHmmss` tag is pushed:

1. `ImageRepository` detects the new tag
2. `ImagePolicy` selects it as the latest (alphabetical sort = chronological)
3. `ImageUpdateAutomation` (global, in `infrastructure/base/flux-image-automation/`) commits the new tag into `deployment.yaml` and pushes to `main`
4. FluxCD reconciles → Kubernetes rolls out the new image

The `# {"$imagepolicy": "flux-system:<app-name>"}` marker in `deployment.yaml` is what tells the automation which lines to update.
