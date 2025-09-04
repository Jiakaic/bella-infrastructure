#!/bin/bash

# 配置检查脚本 - 检查环境变量是否正确设置

echo "🔍 检查 Bella Services 配置..."
echo

# 检查 .env 文件是否存在
if [ ! -f ".env" ]; then
    echo "❌ 未找到 .env 文件"
    echo "💡 请运行: cp .env.example .env 并修改配置"
    exit 1
fi

# 加载环境变量
source .env

echo "📋 当前配置："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "🌐 域名配置:"
echo "   Workflow 域名:  ${WORKFLOW_DOMAIN:-未设置}"
echo "   Knowledge 域名: ${KNOWLEDGE_DOMAIN:-未设置}"
echo

echo "🔒 协议配置:"
echo "   协议:           ${PROTOCOL:-未设置}"
echo "   Workflow URL:   ${WORKFLOW_URL:-未设置}"  
echo "   Knowledge URL:  ${KNOWLEDGE_URL:-未设置}"
echo

echo "🔌 OpenAPI 配置:"
echo "   OpenAPI Host:   ${BELLA_OPENAPI_HOST:-未设置}"
echo "   OpenAPI Base:   ${BELLA_OPENAPI_BASE:-未设置}"
echo "   OpenAPI URL:    ${BELLA_OPENAPI_URL:-未设置}"
echo

echo "⚙️ API 基础配置:"
echo "   Tool API:       ${BELLA_TOOL_API_BASE:-未设置}"
echo "   Dataset API:    ${BELLA_DATASET_API_BASE:-未设置}"
echo "   Backend URL:    ${BELLA_WORKFLOW_BACKEND_OUTER_URL:-未设置}"
echo

# 检查必需配置
missing_vars=()

if [ -z "$WORKFLOW_DOMAIN" ]; then missing_vars+=("WORKFLOW_DOMAIN"); fi
if [ -z "$KNOWLEDGE_DOMAIN" ]; then missing_vars+=("KNOWLEDGE_DOMAIN"); fi
if [ -z "$PROTOCOL" ]; then missing_vars+=("PROTOCOL"); fi
if [ -z "$BELLA_OPENAPI_HOST" ]; then missing_vars+=("BELLA_OPENAPI_HOST"); fi

if [ ${#missing_vars[@]} -eq 0 ]; then
    echo "✅ 所有必需配置都已设置"
    echo
    echo "🚀 可以开始部署："
    echo "   ./deploy-all-services.sh start"
else
    echo "❌ 缺少以下必需配置："
    for var in "${missing_vars[@]}"; do
        echo "   - $var"
    done
    echo
    echo "💡 请编辑 .env 文件补充缺失的配置"
    exit 1
fi