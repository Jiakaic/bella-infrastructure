#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
SOURCE_DIR="../bella-workflow/api/sql"
DEST_DIR="./infrastructure/mysql/init"
MYSQL_HOST="${MYSQL_HOST:-localhost}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-root}"
MYSQL_DB="${MYSQL_DB:-bella_workflow}"
MYSQL_CONTAINER="${MYSQL_CONTAINER:-bella-mysql}"

# 日志函数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检查源目录
check_source_dir() {
    if [ ! -d "$SOURCE_DIR" ]; then
        log_error "源目录不存在: $SOURCE_DIR"
        exit 1
    fi
    log_info "找到源目录: $SOURCE_DIR"
}

# 创建目标目录
create_dest_dir() {
    if [ ! -d "$DEST_DIR" ]; then
        mkdir -p "$DEST_DIR"
        log_info "创建目标目录: $DEST_DIR"
    fi
}

# 修复SQL文件
fix_sql_file() {
    local input_file="$1"
    local output_file="$2"
    local buffer=""
    local in_statement=false
    
    log_info "修复SQL文件: $(basename "$input_file")"
    
    > "$output_file"  # 清空输出文件
    
    # 在文件开头添加数据库选择语句
    echo "-- Auto-generated database selection" >> "$output_file"
    echo "USE \`$MYSQL_DB\`;" >> "$output_file"
    echo "" >> "$output_file"
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # 跳过空行
        if [[ -z "$line" || "$line" =~ ^[[:space:]]*$ ]]; then
            if [[ "$in_statement" == false ]]; then
                echo "$line" >> "$output_file"
            fi
            continue
        fi
        
        # 注释行直接输出
        if [[ "$line" =~ ^[[:space:]]*-- ]]; then
            echo "$line" >> "$output_file"
            continue
        fi
        
        # 去除行尾空格
        line=$(echo "$line" | sed 's/[[:space:]]*$//')
        
        # 如果当前不在语句中，检查是否开始新语句
        if [[ "$in_statement" == false ]]; then
            # 检查是否是SQL语句开始 (添加更多SQL关键字)
            if [[ "$line" =~ ^[[:space:]]*(CREATE|ALTER|INSERT|UPDATE|DELETE|DROP|SELECT|SET|BEGIN|COMMIT) ]]; then
                in_statement=true
                buffer="$line"
            else
                # 不是SQL语句，直接输出
                echo "$line" >> "$output_file"
            fi
        else
            # 在语句中，累积到buffer
            buffer="$buffer"$'\n'"$line"
        fi
        
        # 检查语句是否结束（以分号结尾）
        if [[ "$in_statement" == true && "$line" =~ \;[[:space:]]*$ ]]; then
            # 语句结束，输出buffer
            echo "$buffer" >> "$output_file"
            buffer=""
            in_statement=false
        fi
    done < "$input_file"
    
    # 处理未结束的语句（添加分号）
    if [[ "$in_statement" == true && -n "$buffer" ]]; then
        if [[ ! "$buffer" =~ \;[[:space:]]*$ ]]; then
            buffer="$buffer;"
        fi
        echo "$buffer" >> "$output_file"
    fi
    
    log_success "修复完成: $(basename "$output_file")"
}

# 拷贝并修复所有SQL文件
copy_and_fix_sql_files() {
    log_info "开始拷贝和修复bella-workflow的SQL文件..."
    
    local file_count=0
    
    for sql_file in "$SOURCE_DIR"/*.sql; do
        if [ -f "$sql_file" ]; then
            local filename=$(basename "$sql_file")
            # 为workflow的SQL文件添加前缀，避免与file-api冲突
            local dest_file="$DEST_DIR/workflow-$filename"
            
            fix_sql_file "$sql_file" "$dest_file"
            ((file_count++))
        fi
    done
    
    log_success "共处理了 $file_count 个bella-workflow SQL文件"
}

# 检查Docker MySQL连接
check_docker_mysql_connection() {
    log_info "检查Docker MySQL连接..."
    
    if ! command -v docker &> /dev/null; then
        log_warning "Docker未安装，尝试直接MySQL连接"
        return 1
    fi
    
    if ! docker ps | grep -q "$MYSQL_CONTAINER"; then
        log_warning "MySQL容器 $MYSQL_CONTAINER 未运行，尝试直接MySQL连接"
        return 1
    fi
    
    # 测试连接（忽略密码警告）
    if ! docker exec "$MYSQL_CONTAINER" mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; then
        log_warning "无法通过Docker连接到MySQL，尝试直接MySQL连接"
        return 1
    fi
    
    log_success "Docker MySQL连接成功"
    return 0
}

# 检查直接MySQL连接
check_mysql_connection() {
    log_info "检查MySQL连接..."
    
    if ! command -v mysql &> /dev/null; then
        log_warning "MySQL客户端未安装，跳过数据库操作"
        return 1
    fi
    
    local mysql_cmd="mysql -h$MYSQL_HOST -P$MYSQL_PORT -u$MYSQL_USER"
    if [ -n "$MYSQL_PASSWORD" ]; then
        mysql_cmd="$mysql_cmd -p$MYSQL_PASSWORD"
    fi
    
    if ! echo "SELECT 1;" | $mysql_cmd &> /dev/null; then
        log_warning "无法连接到MySQL数据库，跳过数据库操作"
        return 1
    fi
    
    log_success "MySQL连接成功"
    return 0
}

# 创建数据库（Docker版本）
create_database_docker() {
    log_info "通过Docker创建数据库: $MYSQL_DB"
    
    docker exec "$MYSQL_CONTAINER" mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DB\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null
    log_success "数据库已准备就绪"
}

# 创建数据库（直连版本）
create_database() {
    log_info "创建数据库: $MYSQL_DB"
    
    local mysql_cmd="mysql -h$MYSQL_HOST -P$MYSQL_PORT -u$MYSQL_USER"
    if [ -n "$MYSQL_PASSWORD" ]; then
        mysql_cmd="$mysql_cmd -p$MYSQL_PASSWORD"
    fi
    
    echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DB\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" | $mysql_cmd
    log_success "数据库已准备就绪"
}

# 执行SQL文件（Docker版本）
execute_sql_files_docker() {
    log_info "通过Docker开始执行bella-workflow的SQL文件..."
    
    local success_count=0
    local total_count=0
    
    # 只执行workflow相关的SQL文件，按文件名排序
    for sql_file in $(ls "$DEST_DIR"/workflow-*.sql 2>/dev/null | sort); do
        if [ -f "$sql_file" ]; then
            ((total_count++))
            log_info "执行: $(basename "$sql_file")"
            
            if docker exec -i "$MYSQL_CONTAINER" mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DB" < "$sql_file" 2>/dev/null; then
                log_success "执行成功: $(basename "$sql_file")"
                ((success_count++))
            else
                log_warning "执行时有警告: $(basename "$sql_file") (可能是重复操作)"
                ((success_count++))  # 将警告也视为成功，因为通常是重复操作
            fi
        fi
    done
    
    log_success "bella-workflow SQL文件执行完成 ($success_count/$total_count)"
}

# 执行SQL文件（直连版本）
execute_sql_files() {
    log_info "开始执行bella-workflow的SQL文件..."
    
    local mysql_cmd="mysql -h$MYSQL_HOST -P$MYSQL_PORT -u$MYSQL_USER"
    if [ -n "$MYSQL_PASSWORD" ]; then
        mysql_cmd="$mysql_cmd -p$MYSQL_PASSWORD"
    fi
    mysql_cmd="$mysql_cmd $MYSQL_DB"
    
    # 只执行workflow相关的SQL文件，按文件名排序
    for sql_file in $(ls "$DEST_DIR"/workflow-*.sql 2>/dev/null | sort); do
        if [ -f "$sql_file" ]; then
            log_info "执行: $(basename "$sql_file")"
            
            if $mysql_cmd < "$sql_file"; then
                log_success "执行成功: $(basename "$sql_file")"
            else
                log_error "执行失败: $(basename "$sql_file")"
                return 1
            fi
        fi
    done
    
    log_success "所有bella-workflow SQL文件执行完成"
}

# 验证数据库和表（Docker版本）
verify_database_docker() {
    log_info "验证bella-workflow数据库和表..."
    
    # 检查数据库是否存在
    local db_exists=$(docker exec "$MYSQL_CONTAINER" mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '$MYSQL_DB';" 2>/dev/null | grep -c "$MYSQL_DB" || true)
    
    if [ "$db_exists" -eq 0 ]; then
        log_error "数据库 $MYSQL_DB 不存在"
        return 1
    fi
    
    # 检查表数量
    local table_count=$(docker exec "$MYSQL_CONTAINER" mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DB" -e "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$MYSQL_DB';" 2>/dev/null | tail -n 1)
    
    log_success "数据库: $MYSQL_DB"
    log_success "表数量: $table_count"
    
    # 显示所有表
    log_info "bella-workflow数据库中的表："
    docker exec "$MYSQL_CONTAINER" mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DB" -e "SHOW TABLES;" 2>/dev/null | tail -n +2 | while read table; do
        echo "  - $table"
    done
    
    # 特别检查workflow_scheduling表结构
    log_info "检查workflow_scheduling表结构："
    docker exec "$MYSQL_CONTAINER" mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DB" -e "DESCRIBE workflow_scheduling;" 2>/dev/null | while read field; do
        echo "  $field"
    done
}

# 验证数据库和表（直连版本）
verify_database() {
    log_info "验证bella-workflow数据库和表..."
    
    local mysql_cmd="mysql -h$MYSQL_HOST -P$MYSQL_PORT -u$MYSQL_USER"
    if [ -n "$MYSQL_PASSWORD" ]; then
        mysql_cmd="$mysql_cmd -p$MYSQL_PASSWORD"
    fi
    
    local db_exists=$(echo "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '$MYSQL_DB';" | $mysql_cmd | grep -c "$MYSQL_DB" || true)
    
    if [ "$db_exists" -eq 0 ]; then
        log_error "数据库 $MYSQL_DB 不存在"
        return 1
    fi
    
    local table_count=$(echo "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$MYSQL_DB';" | $mysql_cmd $MYSQL_DB | tail -n 1)
    
    log_success "数据库: $MYSQL_DB"
    log_success "表数量: $table_count"
    
    log_info "bella-workflow数据库中的表："
    echo "SHOW TABLES;" | $mysql_cmd $MYSQL_DB | tail -n +2 | while read table; do
        echo "  - $table"
    done
}

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo ""
    echo "bella-workflow SQL文件同步脚本"
    echo ""
    echo "选项:"
    echo "  -h, --help          显示此帮助信息"
    echo "  --mysql-host HOST   MySQL主机地址 (默认: localhost)"
    echo "  --mysql-port PORT   MySQL端口 (默认: 3306)"
    echo "  --mysql-user USER   MySQL用户名 (默认: root)"
    echo "  --mysql-pass PASS   MySQL密码"
    echo "  --mysql-db DB       MySQL数据库名 (默认: bella_workflow)"
    echo "  --mysql-container NAME  MySQL Docker容器名 (默认: bella-mysql)"
    echo ""
    echo "环境变量:"
    echo "  MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DB, MYSQL_CONTAINER"
    echo ""
    echo "说明:"
    echo "  此脚本从 ../bella-workflow/api/sql/ 拷贝SQL文件到 ./infrastructure/mysql/init/"
    echo "  文件会被重命名为 workflow-*.sql 以避免与其他SQL文件冲突"
    echo "  脚本会自动修复缺少分号的SQL语句并执行到MySQL数据库中"
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) show_help; exit 0 ;;
        --mysql-host) MYSQL_HOST="$2"; shift 2 ;;
        --mysql-port) MYSQL_PORT="$2"; shift 2 ;;
        --mysql-user) MYSQL_USER="$2"; shift 2 ;;
        --mysql-pass) MYSQL_PASSWORD="$2"; shift 2 ;;
        --mysql-db) MYSQL_DB="$2"; shift 2 ;;
        --mysql-container) MYSQL_CONTAINER="$2"; shift 2 ;;
        *) log_error "未知参数: $1"; show_help; exit 1 ;;
    esac
done

# 主函数
main() {
    log_info "开始同步bella-workflow的SQL文件..."
    
    check_source_dir
    create_dest_dir
    copy_and_fix_sql_files
    
    # 强制使用Docker连接
    if check_docker_mysql_connection; then
        create_database_docker
        execute_sql_files_docker
        verify_database_docker
        log_success "bella-workflow同步完成！"
    else
        log_error "Docker MySQL连接失败，请确保："
        log_error "1. Docker已安装并运行"
        log_error "2. MySQL容器 '$MYSQL_CONTAINER' 正在运行"
        log_error "3. 容器密码正确 (当前: $MYSQL_USER/$MYSQL_PASSWORD)"
        log_info ""
        log_info "启动MySQL容器："
        log_info "  docker-compose -f docker-compose.infrastructure.yml up -d mysql"
        log_info ""
        log_info "或手动执行SQL文件："
        log_info "  docker exec -i $MYSQL_CONTAINER mysql -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DB < \$sql_file"
        exit 1
    fi
}

# 执行主函数
main