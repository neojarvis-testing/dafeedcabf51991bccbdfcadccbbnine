#!/bin/bash
# Load environment variables
source /etc/profile.d/bigdata_env.sh

# Format HDFS if not done (optional safety)
if [ ! -d "$HADOOP_HOME/data" ]; then
  $HADOOP_HOME/bin/hdfs namenode -format -force
fi

# Start HDFS
$HADOOP_HOME/sbin/start-dfs.sh

# Start YARN
$HADOOP_HOME/sbin/start-yarn.sh

# Initialize Hive Metastore (Derby)
if [ ! -f $HIVE_HOME/metastore_db/dbex.lck ]; then
  schematool -initSchema -dbType derby
fi

# Start Hive Services
nohup hive --service metastore > /var/log/hive-metastore.log 2>&1 &
nohup hive --service hiveserver2 > /var/log/hive-server2.log 2>&1 &

# Start Spark History Server
nohup $SPARK_HOME/sbin/start-history-server.sh > /var/log/spark-history.log 2>&1 &

# Prepare Zookeeper Config for Kafka
cat <<EOF > $KAFKA_HOME/config/zookeeper.properties
dataDir=/tmp/zookeeper
clientPort=2181
maxClientCnxns=0
EOF

# Start Zookeeper and Kafka
nohup $KAFKA_HOME/bin/zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties > /var/log/zookeeper.log 2>&1 &
sleep 5
nohup $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties > /var/log/kafka.log 2>&1 &

# Initialize Airflow
airflow db init
nohup airflow scheduler > /var/log/airflow-scheduler.log 2>&1 &
nohup airflow webserver -p 8080 > /var/log/airflow-webserver.log 2>&1 &

# Optional: Start Hue if installed
if [ -d "/opt/hue" ]; then
  cd /opt/hue && build/env/bin/supervisor &
fi

# Keep container running
tail -f /dev/null