#!/bin/bash

echo "=== Starting MinIO Server ==="

# 后台启动MinIO服务器
minio server /data --console-address ':9001' &
MINIO_PID=$!

# 等待MinIO启动
sleep 30

echo "=== Setting up MinIO Buckets ==="

# 下载并配置mc客户端
echo "Downloading MinIO client..."

# 首先安装curl如果不存在
if ! command -v curl &> /dev/null; then
    echo "Installing curl..."
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y curl
    elif command -v apk &> /dev/null; then
        apk add --no-cache curl
    elif command -v yum &> /dev/null; then
        yum install -y curl
    else
        echo "Cannot install curl, package manager not found"
        exit 1
    fi
fi

# 尝试下载mc客户端
if ! curl -s https://dl.min.io/client/mc/release/linux-amd64/mc -o /tmp/mc; then
    echo "Failed to download mc client"
    exit 1
fi

chmod +x /tmp/mc

# 等待MinIO完全准备好
echo "Waiting for MinIO to be ready..."
until /tmp/mc alias set local http://localhost:9000 ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD} 2>/dev/null; do
    echo "MinIO not ready yet, waiting..."
    sleep 5
done

echo "MinIO is ready!"

# 创建buckets
echo "创建 workflow bucket: ${WORKFLOW_S3_BUCKET}"
/tmp/mc mb local/${WORKFLOW_S3_BUCKET} 2>/dev/null || echo "Workflow bucket already exists"

echo "创建 file-api bucket: ${FILE_API_S3_BUCKET}"
/tmp/mc mb local/${FILE_API_S3_BUCKET} 2>/dev/null || echo "File-API bucket already exists"

# 设置公共访问策略
echo "Setting bucket policies..."
/tmp/mc anonymous set public local/${WORKFLOW_S3_BUCKET} 2>/dev/null || echo "Policy for workflow bucket already set"
/tmp/mc anonymous set public local/${FILE_API_S3_BUCKET} 2>/dev/null || echo "Policy for file-api bucket already set"

echo "MinIO setup completed!"
/tmp/mc ls local/

# 等待MinIO进程
wait $MINIO_PID