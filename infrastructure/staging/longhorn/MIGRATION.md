# Migration des PVCs vers Longhorn

## Vue d'ensemble

Ce guide explique comment migrer les PVCs existants de `local-path` vers `longhorn`.

### PVCs à migrer

| App | Namespace | PVC | Taille | Type |
|-----|-----------|-----|--------|------|
| Forgejo | forgejo | forgejo-data | 10Gi | Données applicatives |
| Forgejo Runner | forgejo-runner | forgejo-runner-data | 5Gi | Données applicatives |
| pgAdmin | pgadmin | pgadmin-data | 1Gi | Données applicatives |
| Grafana | monitoring | grafana-data | 5Gi | Données applicatives |
| CNPG (Forgejo) | forgejo | forgejo-db-* | 3×1Gi | PostgreSQL (via Barman) |

## Méthode 1 : Migration des PVCs applicatifs (Forgejo, Runner, pgAdmin, Grafana)

### Script de migration

```bash
#!/bin/bash
# migrate-pvc.sh
# Usage: ./migrate-pvc.sh <namespace> <deployment> <pvc-name> <storage-class>

set -e

NAMESPACE=$1
DEPLOYMENT=$2
PVC_NAME=$3
NEW_SC=${4:-longhorn}

echo "=== Migration PVC $PVC_NAME vers $NEW_SC ==="

# 1. Récupérer la taille du PVC
SIZE=$(kubectl get pvc $PVC_NAME -n $NAMESPACE -o jsonpath='{.spec.resources.requests.storage}')
echo "Taille du PVC: $SIZE"

# 2. Scale down le déploiement
echo "Scale down $DEPLOYMENT..."
kubectl scale deployment $DEPLOYMENT -n $NAMESPACE --replicas=0
kubectl rollout status deployment $DEPLOYMENT -n $NAMESPACE --timeout=120s

# 3. Créer un pod temporaire de migration
cat <<EOF | kubectl apply -n $NAMESPACE -f -
apiVersion: v1
kind: Pod
metadata:
  name: pvc-migrate-$PVC_NAME
spec:
  containers:
  - name: migrate
    image: alpine:latest
    command: ['sh', '-c', 'sleep 3600']
    volumeMounts:
    - name: old-data
      mountPath: /old
    - name: new-data
      mountPath: /new
  volumes:
  - name: old-data
    persistentVolumeClaim:
      claimName: $PVC_NAME
  - name: new-data
    persistentVolumeClaim:
      claimName: ${PVC_NAME}-new
EOF

# 4. Créer le nouveau PVC
kubectl get pvc $PVC_NAME -n $NAMESPACE -o yaml | \
  sed "s/name: $PVC_NAME/name: ${PVC_NAME}-new/" | \
  sed "s/storageClassName: local-path/storageClassName: $NEW_SC/" | \
  kubectl apply -n $NAMESPACE -f -

# 5. Attendre que le pod soit prêt
echo "Attente du pod de migration..."
kubectl wait --for=condition=Ready pod/pvc-migrate-$PVC_NAME -n $NAMESPACE --timeout=120s

# 6. Copier les données
echo "Copie des données..."
kubectl exec -n $NAMESPACE pvc-migrate-$PVC_NAME -- sh -c "cp -a /old/* /new/ 2>/dev/null || true"

# 7. Supprimer le pod de migration
kubectl delete pod pvc-migrate-$PVC_NAME -n $NAMESPACE

# 8. Supprimer l'ancien PVC
echo "Suppression de l'ancien PVC..."
kubectl delete pvc $PVC_NAME -n $NAMESPACE

# 9. Renommer le nouveau PVC
# Note: Kubernetes ne permet pas de renommer un PVC directement
# Il faut mettre à jour le déploiement pour utiliser le nouveau nom
kubectl patch deployment $DEPLOYMENT -n $NAMESPACE -p "{\"spec\":{\"template\":{\"spec\":{\"volumes\":[{\"name\":\"data\",\"persistentVolumeClaim\":{\"claimName\":\"${PVC_NAME}-new\"}}]}}}}"

# 10. Scale up
kubectl scale deployment $DEPLOYMENT -n $NAMESPACE --replicas=1

echo "✓ Migration terminée"
echo "Note: Le PVC s'appelle maintenant ${PVC_NAME}-new. Pensez à mettre à jour vos manifests."
```

### Utilisation

```bash
# Migrer Forgejo
./migrate-pvc.sh forgejo forgejo forgejo-data longhorn

# Migrer Forgejo Runner
./migrate-pvc.sh forgejo-runner forgejo-runner forgejo-runner-data longhorn

# Migrer pgAdmin
./migrate-pvc.sh pgadmin pgadmin pgadmin-data longhorn

# Migrer Grafana
./migrate-pvc.sh monitoring grafana grafana-data longhorn
```

## Méthode 2 : Migration CNPG (PostgreSQL)

Pour CNPG, la migration est différente car les données sont des bases PostgreSQL. Il faut utiliser Barman pour restaurer les bases sur des volumes Longhorn.

### Étapes

1. **Créer un nouveau cluster CNPG avec le StorageClass Longhorn**

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: forgejo-db-new
  namespace: forgejo
spec:
  instances: 3
  storage:
    size: 1Gi
    storageClass: longhorn  # <-- Changement ici
  bootstrap:
    recovery:
      source: forgejo-db-backup
  externalClusters:
    - name: forgejo-db-backup
      barmanObjectStore:
        destinationPath: s3://homelab-backup/forgejo
        endpointURL: https://b73c406dcde1daffd850e59e7121516f.r2.cloudflarestorage.com
        s3Credentials:
          accessKeyId:
            name: forgejo-backup-s3
            key: ACCESS_KEY_ID
          secretAccessKey:
            name: forgejo-backup-s3
            key: ACCESS_SECRET_KEY
```

2. **Vérifier que la restauration est complète**

```bash
kubectl logs -n forgejo forgejo-db-new-1 | grep "database system is ready to accept connections"
```

3. **Basculer l'application vers le nouveau cluster**

Mettre à jour le HelmRelease Forgejo pour pointer vers `forgejo-db-new-rw` au lieu de `forgejo-db-rw`.

4. **Supprimer l'ancien cluster**

```bash
kubectl delete cluster forgejo-db -n forgejo
```

5. **Renommer le nouveau cluster** (optionnel)

```bash
kubectl patch cluster forgejo-db-new -n forgejo -p '{"metadata":{"name":"forgejo-db"}}'
```

## Mise à jour des manifests

Après la migration, mettre à jour les manifests pour utiliser `storageClassName: longhorn` :

- `apps/base/forgejo/helm-release.yaml` : `persistence.storageClass: longhorn`
- `apps/base/forgejo-runner/pvc.yaml` : `storageClassName: longhorn`
- `apps/base/pgadmin/pvc.yaml` : `storageClassName: longhorn`
- `monitoring/base/kube-prometheus-stack/grafana-storage.yaml` : `storageClassName: longhorn`
- `apps/staging/forgejo/database.yaml` : `storage.storageClass: longhorn`

## Vérification post-migration

```bash
# Vérifier que tous les PVCs sont en statut Bound
kubectl get pvc -A | grep -E "forgejo|pgadmin|monitoring"

# Vérifier que Longhorn a bien les volumes
kubectl get volumes.longhorn.io -n longhorn-system

# Vérifier les métriques dans Grafana
# Dashboard "Longhorn Storage" doit afficher les volumes migrés
```

## Rollback

Si la migration échoue, vous pouvez restaurer depuis le backup S3 :

```bash
# Via l'UI Longhorn (si activée) ou via kubectl
kubectl apply -f - <<EOF
apiVersion: longhorn.io/v1beta2
kind: Volume
metadata:
  name: <volume-name>
  namespace: longhorn-system
spec:
  fromBackup: "s3://homelab-backup/longhorn/<backup-name>"
EOF
```
