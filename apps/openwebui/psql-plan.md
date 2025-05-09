# Plan d'implémentation de CloudnativePG (Approche ConfigMap local)

## 1. Structure de répertoires

```
kubernetes-homelab/
├── app/
│   └── openwebui/
│       ├── kustomization.yaml
│       ├── litellm-deployment.yaml
│       ├── litellm-service.yaml
│       ├── openwebui-deployment.yaml
│       ├── openwebui-service.yaml
│       ├── postgres-statefulset.yaml (à supprimer)
│       ├── db-connection-config.yaml   # <--- Nouveau ConfigMap local
│       └── roadmap.md
└── databases/
    └── openwebui/
        ├── kustomization.yaml
        ├── cnpg-cluster.yaml
        └── cnpg-backups.yaml
```

## 2. Fichiers à créer

### databases/openwebui/kustomization.yaml
```yaml
resources:
  - cnpg-cluster.yaml
  - cnpg-backups.yaml

namespace: openwebui
```

### databases/openwebui/cnpg-cluster.yaml
```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: openwebui-cluster
  namespace: openwebui
spec:
  instances: 2
  primaryUpdateStrategy: unsupervised
  storage:
    size: 1Gi
  bootstrap:
    initdb:
      database: openwebui
      secret:
        name: openwebui-db-credentials
  superuserSecret:
    name: openwebui-superuser
  monitoring:
    enablePodMonitor: true
  backup:
    barmanObjectStore:
      destinationPath: s3://mon-bucket-backup-postgres/
      endpointURL: https://s3.fr-par.linodeobjects.com   # Adapter selon ton provider S3
      s3Credentials:
        accessKeyId:
          name: openwebui-s3-secret
          key: ACCESS_KEY_ID
        secretAccessKey:
          name: openwebui-s3-secret
          key: SECRET_ACCESS_KEY
      wal:
        compression: gzip
      data:
        compression: gzip
    retentionPolicy: 7d
```

### databases/openwebui/cnpg-backups.yaml
```yaml
apiVersion: postgresql.cnpg.io/v1
kind: ScheduledBackup
metadata:
  name: openwebui-backup
  namespace: openwebui
spec:
  cluster:
    name: openwebui-cluster
  schedule: "0 0 * * *"
  backupOwnerReference: self
  target:
    serverName: openwebui-cluster
  immediate: true
```

### app/openwebui/db-connection-config.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: db-connection-config
  namespace: openwebui
  labels:
    app: openwebui
    tier: backend
    environment: production
    managed-by: cloudnativepg

data:
  DB_HOST: "openwebui-cluster-rw.openwebui.svc.cluster.local"
  DB_PORT: "5432"
  DB_NAME: "openwebui"
  DB_USER: "openwebui"
  CONNECTION_STRING: "postgresql://openwebui:$(DB_PASSWORD)@openwebui-cluster-rw.openwebui.svc.cluster.local:5432/openwebui"
```

### app/openwebui/openwebui-s3-secret.yaml
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: openwebui-s3-secret
  namespace: openwebui
type: Opaque
stringData:
  ACCESS_KEY_ID: <ta-access-key-id>
  SECRET_ACCESS_KEY: <ta-secret-access-key>
```

## 3. Modifications des secrets

Ajouter dans le kustomization.yaml du namespace openwebui :
```yaml
secretGenerator:
  - name: openwebui-db-credentials
    literals:
      - password=changeme
  - name: openwebui-superuser
    literals:
      - username=postgres
      - password=postgrespassword
  - name: litellm-secrets
    literals:
      - OPENAI_API_KEY=sk-xxxx
  # Le secret S3 peut aussi être ajouté ici si tu utilises secretGenerator
```

## 4. Modifier litellm-deployment.yaml

```yaml
env:
  - name: OPENAI_API_KEY
    valueFrom:
      secretKeyRef:
        name: litellm-secrets
        key: OPENAI_API_KEY
  - name: DATABASE_URL
    valueFrom:
      configMapKeyRef:
        name: db-connection-config
        key: CONNECTION_STRING
  - name: LITELLM_MASTER_KEY
    value: "sk-1234-very-secret-key"
  - name: LITELLM_SALT_KEY
    value: "sk-very-secure-salt-key"
  - name: STORE_MODEL_IN_DB
    value: "true"
```

## 5. Modifier openwebui-deployment.yaml

```yaml
env:
  - name: HOST
    value: "0.0.0.0"
  - name: WEBUI_SECRET_KEY
    value: "changeme"
  - name: DB_ENABLED
    value: "true"
  - name: DB_TYPE
    value: "postgres"
  - name: DATABASE_URL
    valueFrom:
      configMapKeyRef:
        name: db-connection-config
        key: CONNECTION_STRING
```

## 6. Étapes d'installation

1. Installer l'opérateur CloudnativePG sur le cluster:
```bash
kubectl apply -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.21/releases/cnpg-1.21.0.yaml
```

2. Créer le dossier databases/openwebui :
```bash
mkdir -p databases/openwebui
```

3. Créer les fichiers YAML dans le dossier databases/openwebui/, le ConfigMap et le Secret S3 dans app/openwebui/

4. Appliquer la configuration:
```bash
kubectl apply -k databases/openwebui/
kubectl apply -f app/openwebui/db-connection-config.yaml
kubectl apply -f app/openwebui/openwebui-s3-secret.yaml
kubectl delete -f app/openwebui/postgres-statefulset.yaml
kubectl apply -k app/openwebui/
```

5. Vérifier le déploiement:
```bash
kubectl get clusters -n openwebui
kubectl get pods -n openwebui
kubectl get configmap -n openwebui
kubectl get secret -n openwebui
```

---

**Remarque** : Les snapshots (backups) sont stockés dans un bucket S3 grâce à la configuration du champ `barmanObjectStore` dans la ressource Cluster CloudNativePG. Les credentials sont fournis via un Secret Kubernetes.**
