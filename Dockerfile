# Yacinoxe Med H. 


# On part d’une image Ubuntu "propre" comme base.
FROM ubuntu:14.04

# Le répertoire de travail par défaut sera /root. Toutes les commandes RUN, COPY, etc. s’exécutent à partir d’ici.
WORKDIR /root

# install requisites  
# OpenJDK 8 requis pour Hadoop, Spark, HBase
# OpenSSH : permet de lancer Hadoop en pseudo-cluster (Hadoop utilise SSH pour communiquer)
# wget curl pour télécharger
# vim python3 pour éditer et exécuter des scripts

RUN apt-get update && apt-get install -y openssh-server openjdk-8-jdk ssh wget curl vim python3 && \
    rm -rf /var/lib/apt/lists/*

  #  Ajoute pip, met à jour, puis installe pyspark (interface Python pour Spark)
  
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3 get-pip.py && \
    rm get-pip.py && \
    python3 -m pip install --upgrade pip setuptools

# Install Hadoop Télécharge Hadoop 3.3.6, le décompresse, et l’installe dans /usr/local/hadoop
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz && \
    tar -xzf hadoop-3.3.6.tar.gz && \
    mv hadoop-3.3.6 /usr/local/hadoop && \
    rm hadoop-3.3.6.tar.gz

# Install Spark Télécharge Spark 3.5.0 compatible avec Hadoop 3, et l’installe.
RUN wget https://mirror.lyrahosting.com/apache/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz && \
    tar -xzf spark-3.5.0-bin-hadoop3.tgz && \
    mv spark-3.5.0-bin-hadoop3 /usr/local/spark && \
    rm spark-3.5.0-bin-hadoop3.tgz


# Install pyspark
RUN pip install pyspark 

# Install Kafka Télécharge et installe Kafka 3.6.1 (version Scala 2.13).
RUN wget https://archive.apache.org/dist/kafka/3.6.1/kafka_2.13-3.6.1.tgz && \
    tar -xzf kafka_2.13-3.6.1.tgz && \
    mv kafka_2.13-3.6.1 /usr/local/kafka && \
    rm kafka_2.13-3.6.1.tgz

# Install HBase
RUN wget https://archive.apache.org/dist/hbase/2.5.8/hbase-2.5.8-hadoop3-bin.tar.gz && \ 
    tar -xzf hbase-2.5.8-hadoop3-bin.tar.gz && \
    mv hbase-2.5.8-hadoop3 /usr/local/hbase && \
    rm hbase-2.5.8-hadoop3-bin.tar.gz


# set environment variables Définit toutes les variables nécessaires pour que Hadoop, Spark, Kafka et HBase soient trouvés dans le PATH
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 
ENV HADOOP_HOME=/usr/local/hadoop
ENV YARN_HOME=/usr/local/hadoop
ENV SPARK_HOME=/usr/local/spark
ENV KAFKA_HOME=/usr/local/kafka
ENV HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop
ENV YARN_CONF_DIR=/usr/local/hadoop/etc/hadoop 
ENV LD_LIBRARY_PATH=/usr/local/hadoop/lib/native:$LD_LIBRARY_PATH
ENV HBASE_HOME=/usr/local/hbase
ENV CLASSPATH=$CLASSPATH:/usr/local/hbase/lib/*
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:/usr/local/spark/bin:/usr/local/kafka/bin:/usr/local/hbase/bin 

# ssh without key Hadoop a besoin de SSH sans mot de passe pour lancer ses démons , donc génération de clés, ajout dans authorized_keys
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys


# Crée les répertoires pour stocker les données NameNode/DataNode, plus un dossier de logs. 
RUN mkdir -p ~/hdfs/namenode && \
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

# Copie tes fichiers de config (déjà préparés) dans les bons emplacements (hdfs-site.xml, core-site.xml, etc.), ainsi que quelques scripts pratiques (start-hadoop.sh, run-wordcount.sh, …).

COPY config/* /tmp/

RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/workers $HADOOP_HOME/etc/hadoop/workers && \
    mv /tmp/start-kafka-zookeeper.sh ~/start-kafka-zookeeper.sh && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh && \
    mv /tmp/spark-defaults.conf $SPARK_HOME/conf/spark-defaults.conf && \
    mv /tmp/hbase-env.sh $HBASE_HOME/conf/hbase-env.sh && \
    mv /tmp/hbase-site.xml $HBASE_HOME/conf/hbase-site.xml &&\
    mv /tmp/purchases.txt /root/purchases.txt && \
    mv /tmp/purchases2.txt /root/purchases2.txt 
    
# Rend exécutables les scripts et binaires nécessaires.

RUN chmod +x ~/start-hadoop.sh && \
    chmod +x ~/start-kafka-zookeeper.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

# format namenode Initialise HDFS la première fois (attention : si on le fait dans un container déjà en cours, ça efface HDFS).
RUN /usr/local/hadoop/bin/hdfs namenode -format

# Lance le service SSH  Ouvre un shell interactif bash
CMD [ "sh", "-c", "service ssh start; bash"]

