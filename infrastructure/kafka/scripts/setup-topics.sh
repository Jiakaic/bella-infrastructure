#!/bin/bash

echo "=== Bella Unified Kafka Topics Setup ==="

# 等待Kafka完全启动
echo "Waiting for Kafka to fully start..."
sleep 30

# 创建Kafka Connect相关topics (workflow需要)
echo "Creating Kafka Connect topics..."
/opt/bitnami/kafka/bin/kafka-topics.sh --create --if-not-exists --bootstrap-server kafka:9092 --replication-factor 1 --partitions 1 --topic connect-configs
/opt/bitnami/kafka/bin/kafka-topics.sh --create --if-not-exists --bootstrap-server kafka:9092 --replication-factor 1 --partitions 1 --topic connect-offsets  
/opt/bitnami/kafka/bin/kafka-topics.sh --create --if-not-exists --bootstrap-server kafka:9092 --replication-factor 1 --partitions 1 --topic connect-status

# 创建Workflow运行日志topic
echo "Creating Workflow run log topic..."
/opt/bitnami/kafka/bin/kafka-topics.sh --create --if-not-exists --bootstrap-server kafka:9092 --replication-factor 1 --partitions 1 --topic ${WORKFLOW_RUN_LOG_TOPIC:-workflow_run_log}

# 创建File API通信topic  
echo "Creating File API topic..."
/opt/bitnami/kafka/bin/kafka-topics.sh --create --if-not-exists --bootstrap-server kafka:9092 --replication-factor 1 --partitions 3 --topic ${FILE_API_TOPIC:-bella_file_api}

# 设置Workflow的Kafka Connect日志收集
if [ -d "/workflow-logs" ]; then
    echo "Setting up Workflow log collection..."
    
    # 确保日志文件存在
    touch /workflow-logs/workflow-run.log
    chmod 666 /workflow-logs/workflow-run.log
    
    # 创建Kafka Connect配置
    mkdir -p /tmp/kafka-connect-logs
    chmod 777 /tmp/kafka-connect-logs

    cat > /opt/bitnami/kafka/config/connect-standalone.properties << EOF
bootstrap.servers=kafka:9092
key.converter=org.apache.kafka.connect.storage.StringConverter
value.converter=org.apache.kafka.connect.storage.StringConverter
key.converter.schemas.enable=false
value.converter.schemas.enable=false
offset.storage.file.filename=/tmp/kafka-connect-logs/connect.offsets
offset.flush.interval.ms=10000
plugin.path=/opt/bitnami/kafka/libs
EOF

    cat > /opt/bitnami/kafka/config/connect-file-source.properties << EOF
name=workflow-log-connector
connector.class=org.apache.kafka.connect.file.FileStreamSourceConnector
tasks.max=1
file=/workflow-logs/workflow-run.log
topic=${WORKFLOW_RUN_LOG_TOPIC:-workflow_run_log}
key.converter=org.apache.kafka.connect.storage.StringConverter
value.converter=org.apache.kafka.connect.storage.StringConverter
key.converter.schemas.enable=false
value.converter.schemas.enable=false
EOF

    # 启动Kafka Connect
    echo "Starting Kafka Connect for log collection..."
    nohup /opt/bitnami/kafka/bin/connect-standalone.sh /opt/bitnami/kafka/config/connect-standalone.properties /opt/bitnami/kafka/config/connect-file-source.properties > /tmp/kafka-connect-logs/kafka-connect.log 2>&1 &
fi

# 列出所有topics进行验证
echo "Listing all topics:"
/opt/bitnami/kafka/bin/kafka-topics.sh --bootstrap-server kafka:9092 --list

echo "Kafka setup completed!"
echo "================================"

# 保持容器运行
tail -f /dev/null