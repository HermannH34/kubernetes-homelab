#!/bin/bash
# Script de setup pour le secret Longhorn backup S3
# Ce script crée le secret avec les vraies valeurs et le chiffre avec SOPS

set -e

echo "=== Setup Longhorn backup S3 secret ==="
echo ""
echo "Ce script va créer le secret longhorn-backup-s3 avec les credentials R2."
echo "Les mêmes credentials que forgejo-backup-s3 et iterato-backup-s3."
echo ""

# Demander les credentials
read -p "AWS_ACCESS_KEY_ID: " AWS_ACCESS_KEY_ID
read -sp "AWS_SECRET_ACCESS_KEY: " AWS_SECRET_ACCESS_KEY
echo ""
read -p "AWS_ENDPOINTS (ex: https://b73c406dcde1daffd850e59e7121516f.r2.cloudflarestorage.com): " AWS_ENDPOINTS

# Créer le secret en clair
cat > operator/staging/longhorn/backup-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: longhorn-backup-s3
  namespace: longhorn-system
type: Opaque
stringData:
  AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
  AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
  AWS_ENDPOINTS: ${AWS_ENDPOINTS}
EOF

echo ""
echo "Secret créé en clair. Chiffrement avec SOPS..."

# Chiffrer avec SOPS
sops --encrypt --in-place operator/staging/longhorn/backup-secret.yaml

echo "✓ Secret chiffré avec succès"
echo ""
echo "Vous pouvez maintenant commiter le fichier."
