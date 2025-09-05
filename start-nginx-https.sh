#!/bin/bash

# Bella Shared Nginx HTTPS 模式启动脚本

echo "=== Bella Shared Nginx HTTPS模式启动 ==="

# 检查docker-compose文件是否存在
if [ ! -f "docker-compose.shared-nginx.yml" ]; then
    echo "错误: docker-compose.shared-nginx.yml 文件不存在"
    exit 1
fi

# 检查SSL证书文件
echo "检查SSL证书..."
if [ ! -f "shared-nginx/ssl/fullchain.pem" ] || [ ! -f "shared-nginx/ssl/privkey.pem" ]; then
    echo "错误: SSL证书文件不存在"
    echo "需要的文件:"
    echo "  - shared-nginx/ssl/fullchain.pem"
    echo "  - shared-nginx/ssl/privkey.pem"
    echo ""
    echo "请参考 shared-nginx/SSL配置指南.md 获取证书"
    exit 1
fi

# 验证证书文件
echo "验证SSL证书..."
if ! openssl x509 -in shared-nginx/ssl/fullchain.pem -noout -checkend 86400; then
    echo "警告: SSL证书可能已过期或无效"
fi

# 恢复SSL配置（如果有备份）
if [ -f "shared-nginx/conf.d/bella-services-ssl.conf.bak" ]; then
    echo "恢复SSL配置..."
    cp shared-nginx/conf.d/bella-services-ssl.conf.bak shared-nginx/conf.d/bella-services.conf
else
    echo "使用默认SSL配置..."
    # 如果当前是HTTP配置，需要备份并恢复
    if grep -q "listen.*80" shared-nginx/conf.d/bella-services.conf && ! grep -q "listen.*443" shared-nginx/conf.d/bella-services.conf; then
        echo "检测到HTTP配置，备份并恢复SSL配置..."
        # 这里假设原始的SSL配置文件存在，实际使用时可能需要调整
        if [ -f "shared-nginx/conf.d/bella-services-http-only.conf" ]; then
            # 当前使用的是HTTP配置，我们需要找到原始的SSL配置
            echo "当前为HTTP模式，需要手动配置SSL版本"
        fi
    fi
fi

# 设置域名
export WORKFLOW_DOMAIN=${WORKFLOW_DOMAIN:-workflow.example.com}
export KNOWLEDGE_DOMAIN=${KNOWLEDGE_DOMAIN:-knowledge.example.com}

echo "域名配置:"
echo "  Workflow: https://${WORKFLOW_DOMAIN}"
echo "  Knowledge: https://${KNOWLEDGE_DOMAIN}"

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

# 测试SSL配置
echo "测试SSL配置..."
sleep 2
if docker exec bella-shared-nginx nginx -t; then
    echo "✅ Nginx配置验证通过"
else
    echo "❌ Nginx配置验证失败"
    echo "查看详细错误: docker logs bella-shared-nginx"
    exit 1
fi

echo ""
echo "=== 启动完成 ==="
echo "HTTPS访问地址:"
echo "  Workflow服务: https://${WORKFLOW_DOMAIN}"
echo "  Knowledge服务: https://${KNOWLEDGE_DOMAIN}"
echo ""
echo "注意: 请确保域名DNS解析到服务器IP"
echo ""
echo "查看日志: docker logs bella-shared-nginx"
echo "停止服务: docker-compose -f docker-compose.shared-nginx.yml down"