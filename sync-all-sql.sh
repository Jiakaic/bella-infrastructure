#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 日志函数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${CYAN}[STEP]${NC} $1"; }

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo ""
    echo "同步所有bella项目的SQL文件到infrastructure项目的统一脚本"
    echo ""
    echo "选项:"
    echo "  -h, --help          显示此帮助信息"
    echo "  --file-api-only     仅同步bella-knowledge的SQL文件"
    echo "  --workflow-only     仅同步bella-workflow的SQL文件"
    echo "  --mysql-host HOST   MySQL主机地址 (默认: localhost)"
    echo "  --mysql-port PORT   MySQL端口 (默认: 3306)"
    echo "  --mysql-user USER   MySQL用户名 (默认: root)"
    echo "  --mysql-pass PASS   MySQL密码"
    echo ""
    echo "环境变量:"
    echo "  MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD"
    echo ""
    echo "说明:"
    echo "  此脚本会调用以下子脚本:"
    echo "  - sync-sql-files.sh     (bella-knowledge SQL文件)"
    echo "  - sync-workflow-sql.sh  (bella-workflow SQL文件)"
    echo ""
    echo "  脚本会自动:"
    echo "  1. 拷贝并修复两个项目的SQL文件"
    echo "  2. 通过Docker容器创建对应的MySQL数据库 (bella_file_api, bella_workflow)"
    echo "  3. 在Docker容器内执行所有SQL文件"
    echo "  4. 验证数据库和表的创建结果"
    echo ""
    echo "  注意: 此脚本仅支持Docker方式，请确保MySQL容器正在运行:"
    echo "    docker-compose -f docker-compose.infrastructure.yml up -d mysql"
}

# 执行子脚本
run_subscript() {
    local script_name="$1"
    local description="$2"
    
    if [ ! -f "$script_name" ]; then
        log_error "脚本 $script_name 不存在"
        return 1
    fi
    
    if [ ! -x "$script_name" ]; then
        log_error "脚本 $script_name 不可执行"
        return 1
    fi
    
    log_step "开始执行: $description"
    echo "----------------------------------------"
    
    # 传递环境变量给子脚本
    local env_vars=""
    [ -n "$MYSQL_HOST" ] && env_vars="$env_vars MYSQL_HOST=$MYSQL_HOST"
    [ -n "$MYSQL_PORT" ] && env_vars="$env_vars MYSQL_PORT=$MYSQL_PORT" 
    [ -n "$MYSQL_USER" ] && env_vars="$env_vars MYSQL_USER=$MYSQL_USER"
    [ -n "$MYSQL_PASSWORD" ] && env_vars="$env_vars MYSQL_PASSWORD=$MYSQL_PASSWORD"
    
    if eval "$env_vars ./$script_name"; then
        log_success "$description 完成"
    else
        log_error "$description 失败"
        return 1
    fi
    
    echo "----------------------------------------"
    echo
}

# 检查MySQL连接状态（仅使用Docker）
check_overall_mysql_status() {
    log_info "检查MySQL总体状态..."
    
    local mysql_container="${MYSQL_CONTAINER:-bella-mysql}"
    local mysql_user="${MYSQL_USER:-root}"
    local mysql_pass="${MYSQL_PASSWORD:-root}"
    
    if ! command -v docker &> /dev/null; then
        log_warning "Docker未安装"
        return 1
    fi
    
    if ! docker ps | grep -q "$mysql_container"; then
        log_warning "MySQL容器 $mysql_container 未运行"
        return 1
    fi
    
    # 测试连接（忽略密码警告）
    if ! docker exec "$mysql_container" mysql -u"$mysql_user" -p"$mysql_pass" -e "SELECT 1;" >/dev/null 2>&1; then
        log_warning "无法通过Docker连接到MySQL数据库"
        return 1
    fi
    
    # 检查两个数据库是否存在
    local file_api_exists=$(docker exec "$mysql_container" mysql -u"$mysql_user" -p"$mysql_pass" -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'bella_file_api';" 2>/dev/null | grep -c "bella_file_api" || true)
    local workflow_exists=$(docker exec "$mysql_container" mysql -u"$mysql_user" -p"$mysql_pass" -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'bella_workflow';" 2>/dev/null | grep -c "bella_workflow" || true)
    
    log_success "MySQL连接正常"
    
    if [ "$file_api_exists" -gt 0 ]; then
        local file_api_tables=$(docker exec "$mysql_container" mysql -u"$mysql_user" -p"$mysql_pass" bella_file_api -e "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'bella_file_api';" 2>/dev/null | tail -n 1)
        log_success "bella_file_api 数据库: ✓ ($file_api_tables 个表)"
    else
        log_warning "bella_file_api 数据库: ✗"
    fi
    
    if [ "$workflow_exists" -gt 0 ]; then
        local workflow_tables=$(docker exec "$mysql_container" mysql -u"$mysql_user" -p"$mysql_pass" bella_workflow -e "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'bella_workflow';" 2>/dev/null | tail -n 1)
        log_success "bella_workflow 数据库: ✓ ($workflow_tables 个表)"
    else
        log_warning "bella_workflow 数据库: ✗"
    fi
    
    return 0
}

# 主函数
main() {
    log_info "开始同步所有bella项目的SQL文件..."
    echo
    
    local file_api_only=false
    local workflow_only=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help) show_help; exit 0 ;;
            --file-api-only) file_api_only=true; shift ;;
            --workflow-only) workflow_only=true; shift ;;
            --mysql-host) export MYSQL_HOST="$2"; shift 2 ;;
            --mysql-port) export MYSQL_PORT="$2"; shift 2 ;;
            --mysql-user) export MYSQL_USER="$2"; shift 2 ;;
            --mysql-pass) export MYSQL_PASSWORD="$2"; shift 2 ;;
            *) log_error "未知参数: $1"; show_help; exit 1 ;;
        esac
    done
    
    # 设置默认值
    export MYSQL_HOST="${MYSQL_HOST:-localhost}"
    export MYSQL_PORT="${MYSQL_PORT:-3306}"
    export MYSQL_USER="${MYSQL_USER:-root}"
    export MYSQL_PASSWORD="${MYSQL_PASSWORD:-root}"
    export MYSQL_CONTAINER="${MYSQL_CONTAINER:-bella-mysql}"
    
    local success_count=0
    local total_count=0
    
    # 执行bella-knowledge脚本
    if [ "$workflow_only" = false ]; then
        ((total_count++))
        if run_subscript "sync-sql-files.sh" "bella-knowledge SQL文件同步"; then
            ((success_count++))
        fi
    fi
    
    # 执行bella-workflow脚本
    if [ "$file_api_only" = false ]; then
        ((total_count++))
        if run_subscript "sync-workflow-sql.sh" "bella-workflow SQL文件同步"; then
            ((success_count++))
        fi
    fi
    
    # 显示总体结果
    echo "========================================"
    log_info "同步结果汇总"
    
    if [ "$success_count" -eq "$total_count" ]; then
        log_success "所有任务完成 ($success_count/$total_count)"
    else
        log_warning "部分任务完成 ($success_count/$total_count)"
    fi
    
    # 检查MySQL总体状态
    if check_overall_mysql_status; then
        log_success "数据库状态检查完成"
    else
        log_info "跳过了数据库状态检查"
    fi
    
    echo "========================================"
    log_success "全部同步任务结束！"
}

# 执行主函数
main "$@"