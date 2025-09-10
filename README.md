## Présentation

Ce projet déploie un environnement Big Data complet sous Docker, basé sur Ubuntu.
Il inclut les plateformes suivantes :

  * [Apache Hadoop](http://hadoop.apache.org/) Version: 3.3.6
  * [Apache Spark](https://spark.apache.org/) Version: 3.5.0
  * [Apache Kafka](https://kafka.apache.org/) Version 3.6.1 (Scala 2.13)
  * [Apache HBase](https://hbase.apache.org/) Version 2.5.8


## Lancement des contenaires

- Vous pouvez soit utiliser les scripts dans le répertoire `scripts`.

```python
scripts/
        |- build-image.sh # la créarion de l'image docker
        |- resize-cluser.sh # pour définir le nombre d'esclaves
        |- start-container.sh # lancer les contenaires
```
- Vous pouvez utiliser docker compose pour lancer les services déclaré dans le ficher `docker_compose/docker-compose.yml` 

```sh
cd docker_compose
docker compose up
```

##  Automatisation du lancement d’un mini cluster
- Le docker-compose.yml
Automatise le lancement d’un mini cluster Big Data complet (Hadoop + Spark + Kafka + HBase), où : /

  * Le master gère les métadonnées, Spark master, Kafka broker et HBase master.
  * Les workers exécutent les tâches (HDFS Datanodes + YARN NodeManagers).
  * Tous sont reliés via le réseau hadoop.

** Ces contenaires ont été initialement issus de kiwenlau/hadoop-cluster-docker , Un grand merci @ kiwenlau & Lilia
