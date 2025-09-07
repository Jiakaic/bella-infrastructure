#!/bin/bash

# Bella Workflow 租户API密钥配置脚本 (Infrastructure版本)
# 用于基础设施部署MySQL数据库中的test租户设置OpenAPI密钥

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Infrastructure部署的MySQL配置
MYSQL_HOST="${MYSQL_HOST:-localhost}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_DATABASE="${MYSQL_DATABASE:-bella_workflow}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-root}"
MYSQL_CONTAINER="${MYSQL_CONTAINER:-bella-mysql}"

# 显示欢迎信息
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Bella Workflow 租户API密钥配置${NC}"
echo -e "${BLUE}      (Infrastructure部署版本)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查MySQL客户端是否可用，优先使用Docker容器
MYSQL_CMD="mysql"
DOCKER_MYSQL=""

# 优先检查Infrastructure MySQL容器是否运行
if command -v docker &> /dev/null && docker ps --format "table {{.Names}}" | grep -q "$MYSQL_CONTAINER"; then
    echo -e "${YELLOW}使用Infrastructure Docker容器执行MySQL命令${NC}"
    DOCKER_MYSQL="docker exec -i $MYSQL_CONTAINER"
    MYSQL_CMD="$DOCKER_MYSQL mysql"
elif command -v mysql &> /dev/null; then
    echo -e "${YELLOW}使用本地MySQL客户端${NC}"
    MYSQL_CMD="mysql"
else
    echo -e "${RED}错误: 未找到MySQL客户端且Infrastructure Docker容器未运行。${NC}"
    echo -e "${YELLOW}请确保已安装MySQL客户端或Infrastructure容器正在运行。${NC}"
    echo ""
    echo -e "${BLUE}请先启动Infrastructure容器：${NC}"
    echo -e "${GREEN}docker-compose -f docker-compose.infrastructure.yml up -d mysql${NC}"
    echo ""
    echo -e "${BLUE}检查容器状态：${NC}"
    echo -e "${GREEN}docker ps | grep bella-mysql${NC}"
    exit 1
fi

# 统一MySQL命令执行函数
execute_mysql_cmd() {
    local sql_query="$1"
    if [ -n "$DOCKER_MYSQL" ]; then
        # Docker方式连接
        $MYSQL_CMD -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" -e "${sql_query}"
    else
        # 直接连接方式
        $MYSQL_CMD -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" -e "${sql_query}"
    fi
}

# 显示当前配置
echo -e "${YELLOW}当前Infrastructure MySQL连接配置：${NC}"
echo -e "  主机: ${MYSQL_HOST}"
echo -e "  端口: ${MYSQL_PORT}"
echo -e "  数据库: ${MYSQL_DATABASE}"
echo -e "  用户: ${MYSQL_USER}"
echo -e "  容器: ${MYSQL_CONTAINER}"
echo ""

# 测试数据库连接
echo -e "${BLUE}正在测试Infrastructure数据库连接...${NC}"
if ! execute_mysql_cmd "SELECT 1;" 2>/dev/null >/dev/null; then
    echo -e "${RED}错误: 无法连接到Infrastructure MySQL数据库。${NC}"
    echo -e "${YELLOW}请检查：${NC}"
    echo -e "  1. Infrastructure MySQL服务是否正在运行"
    echo -e "  2. 连接参数是否正确"
    echo -e "  3. 用户权限是否足够"
    echo ""
    echo -e "${BLUE}启动Infrastructure服务：${NC}"
    echo -e "${GREEN}docker-compose --env-file .env.infrastructure -f docker-compose.infrastructure.yml up -d${NC}"
    echo ""
    echo -e "${BLUE}检查容器状态：${NC}"
    echo -e "${GREEN}docker ps | grep bella-mysql${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Infrastructure数据库连接成功${NC}"
echo ""

# 检查tenant表是否存在
echo -e "${BLUE}检查tenant表是否存在...${NC}"
if ! execute_mysql_cmd "SHOW TABLES LIKE 'tenant';" | grep -q "tenant"; then
    echo -e "${RED}错误: tenant表不存在${NC}"
    echo -e "${YELLOW}请确保workflow数据库架构已正确初始化。${NC}"
    echo ""
    echo -e "${BLUE}检查初始化SQL文件：${NC}"
    echo -e "${GREEN}ls -la infrastructure/mysql/init/${NC}"
    exit 1
fi
echo -e "${GREEN}✓ tenant表存在${NC}"

# 显示当前API密钥（如果存在）
current_key=$(execute_mysql_cmd "SELECT openapi_key FROM tenant WHERE tenant_id = 'test';" | tail -n 1 || echo "")

if [ -n "$current_key" ] && [ "$current_key" != "NULL" ]; then
    echo -e "${YELLOW}当前API密钥: ${current_key}${NC}"
else
    echo -e "${YELLOW}当前没有设置API密钥或test租户不存在${NC}"
    
    # 检查是否存在test租户
    tenant_count=$(execute_mysql_cmd "SELECT COUNT(*) FROM tenant WHERE tenant_id = 'test';" | tail -n 1 || echo "0")
    
    if [ "$tenant_count" = "0" ]; then
        echo -e "${YELLOW}⚠ test租户不存在，将自动创建${NC}"
        
        # 创建test租户
        create_tenant_sql="INSERT INTO tenant (tenant_id, tenant_name, openapi_key, parent_id, cu_name, mu_name) VALUES ('test', 'Test Tenant', '', '', 'system', 'system') ON DUPLICATE KEY UPDATE mtime = NOW();"
        
        if execute_mysql_cmd "${create_tenant_sql}" >/dev/null; then
            echo -e "${GREEN}✓ test租户创建成功${NC}"
        else
            echo -e "${RED}✗ test租户创建失败${NC}"
            exit 1
        fi
    fi
fi
echo ""

# 获取API密钥（优先使用命令行参数）
if [ -n "$1" ]; then
    api_key="$1"
    echo -e "${BLUE}使用命令行参数提供的API密钥${NC}"
else
    echo -e "${BLUE}请输入新的API密钥: ${NC}"
    read -r api_key
fi

# 验证API密钥不为空
if [ -z "$api_key" ]; then
    echo -e "${RED}错误: API密钥不能为空${NC}"
    exit 1
fi

# 执行更新操作
echo ""
echo -e "${BLUE}正在更新API密钥...${NC}"

# 构建并执行SQL命令
sql_command="UPDATE tenant SET openapi_key = '${api_key}', mtime = NOW() WHERE tenant_id = 'test';"

if execute_mysql_cmd "${sql_command}" >/dev/null; then
    echo -e "${GREEN}✓ API密钥设置成功！${NC}"
    
    # 验证更新结果 - 重新查询确认
    updated_key=$(execute_mysql_cmd "SELECT openapi_key FROM tenant WHERE tenant_id = 'test';" | tail -n 1)
    
    if [ -n "$updated_key" ] && [ "$updated_key" = "$api_key" ]; then
        echo -e "${GREEN}✓ 验证成功：API密钥已正确设置${NC}"
        echo -e "${GREEN}✓ 新API密钥: ${updated_key}${NC}"
    else
        echo -e "${YELLOW}⚠ 警告：设置后验证发现密钥不匹配${NC}"
        echo -e "${YELLOW}  预期: ${api_key}${NC}"
        echo -e "${YELLOW}  实际: ${updated_key}${NC}"
    fi
else
    echo -e "${RED}✗ API密钥设置失败${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}           操作完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}使用说明：${NC}"
echo -e "  • 该脚本专门用于Infrastructure部署的MySQL"
echo -e "  • 连接到容器: ${MYSQL_CONTAINER}"
echo -e "  • 数据库: ${MYSQL_DATABASE}"
echo -e "  • 可通过环境变量覆盖默认配置"
echo ""
echo -e "${YELLOW}环境变量示例：${NC}"
echo -e "${GREEN}MYSQL_HOST=localhost MYSQL_PORT=3306 ./set-tenant-apikey-infrastructure.sh <api_key>${NC}"