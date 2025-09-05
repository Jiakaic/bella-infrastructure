#!/bin/bash

echo "=== Starting MinIO Server ==="

# 后台启动MinIO服务器
minio server /data --console-address ':9001' &
MINIO_PID=$!

# 等待MinIO启动
sleep 30

echo "=== Setting up MinIO Buckets ==="

# 下载并配置mc客户端
wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /tmp/mc
chmod +x /tmp/mc

# 配置mc
/tmp/mc alias set local http://localhost:9000 ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}

# 创建buckets
echo "创建 workflow bucket: ${WORKFLOW_S3_BUCKET}"
/tmp/mc mb local/${WORKFLOW_S3_BUCKET} || echo "Workflow bucket already exists"

echo "创建 file-api bucket: ${FILE_API_S3_BUCKET}"
/tmp/mc mb local/${FILE_API_S3_BUCKET} || echo "File-API bucket already exists"

# 设置公共访问策略
/tmp/mc anonymous set public local/${WORKFLOW_S3_BUCKET}
/tmp/mc anonymous set public local/${FILE_API_S3_BUCKET}

echo "MinIO setup completed!"
/tmp/mc ls local/

# 等待MinIO进程
wait $MINIO_PID