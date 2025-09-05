#!/bin/bash

# prepare-mysql-init.sh - 准备MySQL初始化脚本

set -e

echo "=== 准备MySQL初始化脚本 ==="

# SQL语句规范化函数 - 确保SQL语句以分号结尾
normalize_sql() {
    local input_file="$1"
    local temp_file="${input_file}.tmp"
    
    echo "正在规范化 $(basename "$input_file")..."
    
    # 使用更强健的Python脚本来处理SQL语句
    python3 << EOF > "$temp_file"
import re

# 读取输入文件
with open('$input_file', 'r', encoding='utf-8') as f:
    content = f.read()

# 按行分割
lines = content.split('\n')
result_lines = []
current_statement_lines = []
in_multi_line_statement = False

for i, line in enumerate(lines):
    original_line = line
    line = line.rstrip()
    
    # 空行 - 保持原样
    if not line.strip():
        # 如果有未完成的多行语句，先处理它
        if current_statement_lines:
            complete_stmt = ' '.join([l.strip() for l in current_statement_lines if l.strip()])
            if complete_stmt and not complete_stmt.endswith(';'):
                complete_stmt += ';'
            if complete_stmt:
                result_lines.append(complete_stmt)
            current_statement_lines = []
            in_multi_line_statement = False
        result_lines.append(original_line)
        continue
    
    # 注释行 - 保持原样
    if line.strip().startswith('--'):
        # 如果有未完成的多行语句，先处理它
        if current_statement_lines:
            complete_stmt = ' '.join([l.strip() for l in current_statement_lines if l.strip()])
            if complete_stmt and not complete_stmt.endswith(';'):
                complete_stmt += ';'
            if complete_stmt:
                result_lines.append(complete_stmt)
            current_statement_lines = []
            in_multi_line_statement = False
        result_lines.append(original_line)
        continue
    
    # USE语句 - 保持原样
    if re.match(r'^\s*USE\s+', line, re.IGNORECASE):
        # 如果有未完成的多行语句，先处理它
        if current_statement_lines:
            complete_stmt = ' '.join([l.strip() for l in current_statement_lines if l.strip()])
            if complete_stmt and not complete_stmt.endswith(';'):
                complete_stmt += ';'
            if complete_stmt:
                result_lines.append(complete_stmt)
            current_statement_lines = []
            in_multi_line_statement = False
        
        if not line.endswith(';'):
            line += ';'
        result_lines.append(line)
        continue
    
    # SET语句 - 保持原样
    if re.match(r'^\s*SET\s+', line, re.IGNORECASE):
        # 如果有未完成的多行语句，先处理它
        if current_statement_lines:
            complete_stmt = ' '.join([l.strip() for l in current_statement_lines if l.strip()])
            if complete_stmt and not complete_stmt.endswith(';'):
                complete_stmt += ';'
            if complete_stmt:
                result_lines.append(complete_stmt)
            current_statement_lines = []
            in_multi_line_statement = False
        
        if not line.endswith(';'):
            line += ';'
        result_lines.append(line)
        continue
    
    # 检查是否是SQL语句的开始关键词
    sql_keywords = [
        r'^\s*ALTER\s+TABLE\s+',
        r'^\s*CREATE\s+(TABLE|DATABASE|INDEX|USER|VIEW)\s+',
        r'^\s*DROP\s+(TABLE|DATABASE|INDEX|USER|VIEW)\s+',
        r'^\s*INSERT\s+INTO\s+',
        r'^\s*UPDATE\s+',
        r'^\s*DELETE\s+FROM\s+',
        r'^\s*GRANT\s+',
        r'^\s*REVOKE\s+',
        r'^\s*FLUSH\s+',
        r'^\s*TRUNCATE\s+',
        r'^\s*(BEGIN|START)\s+',
        r'^\s*COMMIT\s*',
        r'^\s*ROLLBACK\s*'
    ]
    
    is_sql_start = any(re.match(pattern, line, re.IGNORECASE) for pattern in sql_keywords)
    
    if is_sql_start:
        # 如果有未完成的多行语句，先处理它
        if current_statement_lines:
            complete_stmt = ' '.join([l.strip() for l in current_statement_lines if l.strip()])
            if complete_stmt and not complete_stmt.endswith(';'):
                complete_stmt += ';'
            if complete_stmt:
                result_lines.append(complete_stmt)
        
        # 开始新的语句
        current_statement_lines = [line]
        in_multi_line_statement = True
        
        # 检查是否在同一行就结束了
        if line.endswith(';'):
            result_lines.append(line)
            current_statement_lines = []
            in_multi_line_statement = False
    elif in_multi_line_statement:
        # 继续多行语句
        current_statement_lines.append(line)
        
        # 检查是否结束
        if line.endswith(';'):
            complete_stmt = ' '.join([l.strip() for l in current_statement_lines if l.strip()])
            result_lines.append(complete_stmt)
            current_statement_lines = []
            in_multi_line_statement = False
    else:
        # 可能是其他类型的行（如表结构的一部分），或者是独立的语句
        # 先检查是否看起来像一个完整的语句但缺少分号
        stripped = line.strip()
        
        # 如果看起来像是表结构定义的一部分，保持原样
        if (stripped.startswith('\`') or stripped.startswith('(') or 
            stripped.startswith(')') or stripped.startswith('KEY ') or 
            stripped.startswith('PRIMARY KEY') or stripped.startswith('UNIQUE KEY') or
            stripped.startswith('INDEX ') or stripped.endswith(',') or
            re.match(r'^\s*\) ENGINE=', line, re.IGNORECASE)):
            result_lines.append(original_line)
        else:
            # 可能是一个独立的语句，需要添加分号
            if stripped and not stripped.endswith(';'):
                line += ';'
            result_lines.append(line)

# 处理最后未完成的多行语句
if current_statement_lines:
    complete_stmt = ' '.join([l.strip() for l in current_statement_lines if l.strip()])
    if complete_stmt and not complete_stmt.endswith(';'):
        complete_stmt += ';'
    if complete_stmt:
        result_lines.append(complete_stmt)

# 输出结果
for line in result_lines:
    print(line)
EOF
    
    if [ $? -eq 0 ]; then
        # 替换原文件
        mv "$temp_file" "$input_file"
        echo "✅ 已规范化SQL文件: $input_file"
    else
        echo "❌ 规范化失败: $input_file"
        rm -f "$temp_file"
        return 1
    fi
}

# 检查源文件是否存在
WORKFLOW_SQL_DIR="../bella-workflow/api/sql"
FILE_API_SQL_DIR="../bella-knowledge/api/sql"

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
normalize_sql "infrastructure/mysql/init/02-workflow-schema.sql"

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
normalize_sql "infrastructure/mysql/init/03-workflow-updates.sql"

# 4. 准备File API表结构
echo "准备 04-file-api-schema.sql..."
echo "USE bella_file_api;" > infrastructure/mysql/init/04-file-api-schema.sql
cat "$FILE_API_SQL_DIR/01-init.sql" >> infrastructure/mysql/init/04-file-api-schema.sql
normalize_sql "infrastructure/mysql/init/04-file-api-schema.sql"

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
normalize_sql "infrastructure/mysql/init/05-file-api-updates.sql"

echo "=== MySQL初始化脚本准备完成! ==="
echo ""
echo "生成的文件列表:"
ls -la infrastructure/mysql/init/

echo ""
echo "=== SQL文件验证 ==="
# 检查每个SQL文件的语法
for sql_file in infrastructure/mysql/init/*.sql; do
    if [ -f "$sql_file" ]; then
        echo "验证 $(basename "$sql_file")..."
        # 检查是否有未结束的语句（不以分号结尾的非注释、非空行）
        lines_without_semicolon=$(grep -v '^--' "$sql_file" | grep -v '^[[:space:]]*$' | grep -v ';[[:space:]]*$' | wc -l)
        if [ "$lines_without_semicolon" -gt 0 ]; then
            echo "  ⚠️  警告: 发现 $lines_without_semicolon 行可能缺少分号的语句"
        else
            echo "  ✅ 语法检查通过"
        fi
    fi
done

echo ""
echo "=== 使用说明 ==="
echo "1. 现在可以启动MySQL容器:"
echo "   docker-compose -f docker-compose.infrastructure.yml up -d bella-mysql"
echo ""
echo "2. 如果遇到问题，可以查看日志:"
echo "   docker logs bella-mysql"
echo ""
echo "3. 连接MySQL验证:"
echo "   docker exec -it bella-mysql mysql -u root -p"
echo ""
echo "所有SQL文件已经过规范化处理，确保语句正确结束。"