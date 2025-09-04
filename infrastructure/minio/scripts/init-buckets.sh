#!/bin/bash

echo "=== MinIO Buckets Setup ==="

sleep 20

# 等待MinIO启动
until curl -f http://localhost:9000/minio/health/live; do
    echo "等待 MinIO 启动..."
    sleep 5
done

# 下载mc客户端
if [ ! -f "/usr/local/bin/mc" ]; then
    curl -o /usr/local/bin/mc https://dl.min.io/client/mc/release/linux-amd64/mc
    chmod +x /usr/local/bin/mc
fi

# 配置mc
/usr/local/bin/mc alias set minio http://localhost:9000 ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}

# 创建buckets
echo "创建 workflow bucket: ${WORKFLOW_S3_BUCKET}"
/usr/local/bin/mc mb minio/${WORKFLOW_S3_BUCKET} || echo "Workflow bucket exists"

echo "创建 file-api bucket: ${FILE_API_S3_BUCKET}"  
/usr/local/bin/mc mb minio/${FILE_API_S3_BUCKET} || echo "File-API bucket exists"

# 设置策略
/usr/local/bin/mc anonymous set public minio/${WORKFLOW_S3_BUCKET}
/usr/local/bin/mc anonymous set public minio/${FILE_API_S3_BUCKET}

echo "MinIO setup completed!"
echo "Listing buckets:"
/usr/local/bin/mc ls minio/

# 保持容器运行
tail -f /dev/null