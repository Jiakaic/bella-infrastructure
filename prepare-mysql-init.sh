#!/bin/bash

# prepare-mysql-init.sh - 准备MySQL初始化脚本

set -e

echo "=== 准备MySQL初始化脚本 ==="

# 检查源文件是否存在
WORKFLOW_SQL_DIR="bella-workflow/api/sql"
FILE_API_SQL_DIR="bella-file-api/api/sql"

if [ ! -f "$WORKFLOW_SQL_DIR/init.sql" ]; then
    echo "错误: 找不到 $WORKFLOW_SQL_DIR/init.sql"
    echo "请确保在项目根目录执行此脚本"
    exit 1
fi

if [ ! -f "$FILE_API_SQL_DIR/01-init.sql" ]; then
    echo "错误: 找不到 $FILE_API_SQL_DIR/01-init.sql"
    echo "请确保在项目根目录执行此脚本"
    exit 1
fi

# 创建目录
mkdir -p infrastructure/mysql/init

# 1. 创建数据库和用户脚本
echo "创建 01-create-databases.sql..."
cat > infrastructure/mysql/init/01-create-databases.sql << 'EOF'
-- 创建数据库和用户
CREATE DATABASE IF NOT EXISTS bella_workflow CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS bella_file_api CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

-- 创建用户
CREATE USER IF NOT EXISTS 'bella_workflow'@'%' IDENTIFIED BY 'bella123';
CREATE USER IF NOT EXISTS 'bella_user'@'%' IDENTIFIED BY '123456';

-- 授权
GRANT ALL PRIVILEGES ON bella_workflow.* TO 'bella_workflow'@'%';
GRANT ALL PRIVILEGES ON bella_file_api.* TO 'bella_user'@'%';

FLUSH PRIVILEGES;
EOF

# 2. 准备Workflow表结构
echo "准备 02-workflow-schema.sql..."
echo "USE bella_workflow;" > infrastructure/mysql/init/02-workflow-schema.sql
cat "$WORKFLOW_SQL_DIR/init.sql" >> infrastructure/mysql/init/02-workflow-schema.sql

# 3. 准备Workflow更新脚本
echo "准备 03-workflow-updates.sql..."
echo "USE bella_workflow;" > infrastructure/mysql/init/03-workflow-updates.sql
for update_file in "$WORKFLOW_SQL_DIR"/update*.sql; do
    if [ -f "$update_file" ]; then
        echo "" >> infrastructure/mysql/init/03-workflow-updates.sql
        echo "-- $(basename "$update_file")" >> infrastructure/mysql/init/03-workflow-updates.sql
        cat "$update_file" >> infrastructure/mysql/init/03-workflow-updates.sql
    fi
done

# 4. 准备File API表结构
echo "准备 04-file-api-schema.sql..."
echo "USE bella_file_api;" > infrastructure/mysql/init/04-file-api-schema.sql
cat "$FILE_API_SQL_DIR/01-init.sql" >> infrastructure/mysql/init/04-file-api-schema.sql

# 5. 准备File API更新脚本
echo "准备 05-file-api-updates.sql..."
echo "USE bella_file_api;" > infrastructure/mysql/init/05-file-api-updates.sql
for update_file in "$FILE_API_SQL_DIR"/*update*.sql; do
    if [ -f "$update_file" ]; then
        echo "" >> infrastructure/mysql/init/05-file-api-updates.sql
        echo "-- $(basename "$update_file")" >> infrastructure/mysql/init/05-file-api-updates.sql
        cat "$update_file" >> infrastructure/mysql/init/05-file-api-updates.sql
    fi
done

echo "MySQL初始化脚本准备完成!"
echo "文件列表:"
ls -la infrastructure/mysql/init/

echo ""
echo "注意: 请检查生成的SQL文件，确保没有语法错误"
echo "建议执行: head -20 infrastructure/mysql/init/*.sql"