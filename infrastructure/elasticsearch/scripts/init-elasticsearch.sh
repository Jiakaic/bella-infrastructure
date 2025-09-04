#!/bin/bash

echo "=== Elasticsearch Setup ==="

# 等待启动
until curl -s http://localhost:9200/_cluster/health; do
    echo "等待 Elasticsearch 启动..."
    sleep 10
done

echo "Elasticsearch is ready!"

# 创建索引模板
echo "Creating workflow run log index template..."
curl -X PUT "localhost:9200/_index_template/workflow_run_log_template" -H 'Content-Type: application/json' -d'
{
  "index_patterns": ["workflow_run_log_*"],
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0
    },
    "mappings": {
      "properties": {
        "timestamp": {"type": "date"},
        "level": {"type": "keyword"},
        "message": {"type": "text", "analyzer": "standard"},
        "workflow_id": {"type": "keyword"},
        "node_id": {"type": "keyword"},
        "execution_id": {"type": "keyword"},
        "tenant_id": {"type": "keyword"},
        "user_id": {"type": "keyword"},
        "run_id": {"type": "keyword"},
        "step_id": {"type": "keyword"},
        "error_code": {"type": "keyword"},
        "duration_ms": {"type": "long"},
        "input_tokens": {"type": "long"},
        "output_tokens": {"type": "long"}
      }
    }
  }
}'

# 创建今天的索引
CURRENT_DATE=$(date +"%Y.%m.%d")
INDEX_NAME="workflow_run_log_${CURRENT_DATE}"

echo "Creating index: ${INDEX_NAME}"
curl -X PUT "localhost:9200/${INDEX_NAME}" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}'

echo "Elasticsearch setup completed!"

# 验证设置
echo "Verifying setup:"
curl -s "localhost:9200/_cluster/health?pretty"
curl -s "localhost:9200/_cat/indices?v"

# 保持容器运行
tail -f /dev/null