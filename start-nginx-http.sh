#!/bin/bash

# Bella Shared Nginx HTTP 模式启动脚本

echo "=== Bella Shared Nginx HTTP模式启动 ==="

# 检查docker-compose文件是否存在
if [ ! -f "docker-compose.shared-nginx.yml" ]; then
    echo "错误: docker-compose.shared-nginx.yml 文件不存在"
    exit 1
fi

# 备份原配置（如果存在）
if [ -f "shared-nginx/conf.d/bella-services.conf" ]; then
    echo "备份原SSL配置..."
    cp shared-nginx/conf.d/bella-services.conf shared-nginx/conf.d/bella-services-ssl.conf.bak
fi

# 使用HTTP配置
echo "切换到HTTP配置..."
cp shared-nginx/conf.d/bella-services-http-only.conf shared-nginx/conf.d/bella-services.conf

# 设置默认域名（如果环境变量未设置）
export WORKFLOW_DOMAIN=${WORKFLOW_DOMAIN:-localhost:80}
export KNOWLEDGE_DOMAIN=${KNOWLEDGE_DOMAIN:-localhost:80}

echo "域名配置:"
echo "  Workflow: http://${WORKFLOW_DOMAIN}"
echo "  Knowledge: http://${KNOWLEDGE_DOMAIN}"

# 检查网络是否存在
if ! docker network ls | grep -q "bella-infrastructure_bella-network"; then
    echo "警告: bella-infrastructure_bella-network 网络不存在"
    echo "请先启动基础设施服务: docker-compose -f docker-compose.infrastructure.yml up -d"
fi

# 启动nginx
echo "启动Nginx服务..."
docker-compose -f docker-compose.shared-nginx.yml up -d

# 检查服务状态
echo "检查服务状态..."
sleep 3
docker-compose -f docker-compose.shared-nginx.yml ps

echo ""
echo "=== 启动完成 ==="
echo "HTTP访问地址:"
echo "  Workflow服务: http://${WORKFLOW_DOMAIN}"
echo "  Knowledge服务: http://${KNOWLEDGE_DOMAIN}"
echo ""
echo "查看日志: docker logs bella-shared-nginx"
echo "停止服务: docker-compose -f docker-compose.shared-nginx.yml down"