# Cluster Health Check

Script de diagnostic du cluster Kubernetes.

## Usage

```bash
./cluster-health.sh
```

## Ce que ça vérifie

| # | Check | Commande |
|---|-------|----------|
| 1 | État des nœuds | `kubectl get nodes` |
| 2 | Disponibilité de l'API server | `/readyz` endpoint |
| 3 | Pods en échec | `kubectl get pods -A` |
| 4 | Utilisation des ressources | `kubectl top nodes` |
| 5 | Évènements Warning récents | `kubectl get events` |



## Checklist opérationnelle

Ce tableau récapitule les vérifications à effectuer selon leur fréquence pour maintenir le cluster en bonne santé et anticiper les problèmes avant qu'ils impactent les workloads.


| Fréquence | Vérification | Commande clé | Action si problème |
|-----------|-------------|--------------|-------------------|
| Quotidienne | Nœuds Ready | `kubectl get nodes` | Investiguer nœud NotReady |
| Quotidienne | API server sain | `kubectl get --raw='/readyz?verbose'` | Vérifier logs composant `[-]` |
| Quotidienne | Pods en échec | `kubectl get pods -A --field-selector=status.phase!=Running,...` | Investiguer ou redémarrer |
| Quotidienne | Consommation ressources | `kubectl top nodes` | Investiguer si repères opérationnels dépassés |
| Quotidienne | Événements Warning | `kubectl get events -A --field-selector type=Warning` | Identifier patterns récurrents |
| Hebdomadaire | Pods/Jobs terminés | `kubectl get pods --field-selector=status.phase==Succeeded` | Configurer TTL, nettoyer si nécessaire |
| Hebdomadaire | ReplicaSets orphelins | `kubectl get rs -A` | Ajuster `revisionHistoryLimit` |
| Hebdomadaire | Quotas namespace | `kubectl get resourcequota -A` | Ajuster si proche limite |
| Hebdomadaire | Pression disque | `kubectl describe node` (DiskPressure) | Nettoyage ciblé si confirmé |
| Mensuelle | Certificats control plane | `kubeadm certs check-expiration` | Renouveler si < 30 jours |
| Mensuelle | Certificats Ingress | `kubectl get certificates -A` | Vérifier cert-manager |
| Mensuelle | Tendances capacité | `kubectl top nodes` (historique) | Planifier ajustements |


