#!/bin/bash
echo "🔍 Checking Kafka..."

# Start ZooKeeper (runs in background with nohup)
nohup /opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties > /tmp/zookeeper.log 2>&1 &

# Give ZooKeeper time to start
sleep 5

# Start Kafka broker
nohup /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties > /tmp/kafka.log 2>&1 &

# Give Kafka time to start
sleep 5

# Create a test topic (if not already exists)
if ! /opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092 | grep -q test-topic; then
  /opt/kafka/bin/kafka-topics.sh --create \
    --topic test-topic \
    --bootstrap-server localhost:9092 \
    --partitions 1 \
    --replication-factor 1
else
  echo "⚠️ Topic 'test-topic' already exists"
fi

# List all topics
/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092

# Kafka UI info
echo "[ℹ️] Kafka has no default Web UI. Use Kafka Manager or AKHQ if needed."