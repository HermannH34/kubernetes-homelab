gérer les secret
le DNS
le https

------------
Monitoring:
-stockage des conversations via VPC, mettre des alertes si dépassement et supprimer les données dans le pod via un CronJob.

-------

argocd

------
PSQL:

Ajouter CloudNativePSQL pour gérer la DB. Utiliser un barmanObjectStore couplé d'un S3 pour stocker les snapshots.

Utiliser Grafana pour monitorer PSQL.

-----
k9s