#!/bin/bash
echo "🔍 Checking Hive..."

#Optional: Start HiveServer2 in background if needed
echo "[ℹ️] Starting HiveServer2..."
nohup $HIVE_HOME/bin/hive --service hiveserver2 > /tmp/hiveserver2.log 2>&1 &
sleep 5  # Give some time for the server to initialize

# Hive CLI Check
echo "[✔] Running Hive shell test:"
echo "SHOW DATABASES;" | hive -S
if [ $? -eq 0 ]; then
  echo "✅ Hive shell executed successfully"
else
  echo "❌ Hive shell failed"
fi

# Web UI info
echo "[ℹ️] Hive does not provide a standalone Web UI. Use Hue for visual interaction."
