#!/bin/bash

# Bella Services 统一部署脚本
# 用途: 部署所有Bella服务，包括Workflow、File API和共享Nginx

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# 显示使用说明
show_usage() {
    echo "Bella Services 部署脚本"
    echo
    echo "用法:"
    echo "  $0 [命令] [选项]"
    echo
    echo "命令:"
    echo "  start         启动所有服务 (默认)"
    echo "  stop          停止所有服务"
    echo "  restart       重启所有服务"
    echo "  status        查看服务状态"
    echo "  logs          查看服务日志"
    echo "  nginx-reload  重新加载nginx配置"
    echo
    echo "选项:"
    echo "  --workflow-only    仅操作workflow服务"
    echo "  --file-api-only    仅操作file-api服务"
    echo "  --nginx-only       仅操作nginx服务"
    echo "  --no-nginx         跳过nginx操作"
    echo "  --help, -h         显示帮助信息"
    echo
    echo "示例:"
    echo "  $0                     # 启动所有服务"
    echo "  $0 stop                # 停止所有服务"
    echo "  $0 logs --workflow-only # 查看workflow日志"
    echo "  $0 start --no-nginx    # 启动服务但跳过nginx"
}

# 检查必要条件
check_prerequisites() {
    log_step "检查部署前置条件..."
    
    # 检查 docker 和 docker-compose
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装或不在 PATH 中"
        exit 1
    fi
    
    if ! command -v docker compose &> /dev/null && ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose 未安装或不在 PATH 中"
        exit 1
    fi
    
    # 检查基础设施是否运行
    if ! docker network ls | grep -q "bella-infrastructure_bella-network"; then
        log_error "基础设施网络未找到，请先运行 './deploy-middleware.sh'"
        exit 1
    fi
    
    log_success "前置条件检查通过"
}

# 创建必要的目录
create_directories() {
    log_step "创建必要的目录..."
    
    # 创建workflow运行时目录
    mkdir -p workflow/api/{logs,cache,privdata,configuration}
    
    # 创建file-api运行时目录
    mkdir -p file-api/api/{logs,cache,privdata,configuration}
    
    log_success "目录创建完成"
}

# 检查域名解析
check_domain_resolution() {
    log_step "检查域名解析..."
    
    local domains=("${WORKFLOW_DOMAIN:-workflow.example.com}" "${KNOWLEDGE_DOMAIN:-knowledge.example.com}")
    local need_hosts_update=false
    
    for domain in "${domains[@]}"; do
        if ! nslookup "$domain" &> /dev/null; then
            log_warning "域名 $domain 无法解析，建议添加到 /etc/hosts"
            need_hosts_update=true
        fi
    done
    
    if [ "$need_hosts_update" = true ]; then
        log_info "建议在 /etc/hosts 添加以下条目:"
        echo "127.0.0.1 ${WORKFLOW_DOMAIN:-workflow.example.com}"
        echo "127.0.0.1 ${KNOWLEDGE_DOMAIN:-knowledge.example.com}"
        echo
        read -p "是否继续部署? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "部署已取消"
            exit 0
        fi
    fi
}

# 启动服务
start_services() {
    local workflow_only=${1:-false}
    local file_api_only=${2:-false}
    local nginx_only=${3:-false}
    local no_nginx=${4:-false}
    
    if [ "$nginx_only" = true ]; then
        log_step "启动共享Nginx..."
        docker compose -f docker-compose.shared-nginx.yml up -d
        return
    fi
    
    if [ "$workflow_only" != true ] && [ "$file_api_only" != true ]; then
        # 启动所有服务
        log_step "停止旧服务..."
        stop_services true true true true
        
        log_step "启动Workflow服务..."
        docker compose -f docker-compose.workflow.yml up -d
        
        log_step "启动File API服务..."
        docker compose -f docker-compose.file-api.yml up -d
        
        if [ "$no_nginx" != true ]; then
            log_step "等待应用服务启动..."
            sleep 15
            
            log_step "启动共享Nginx..."
            docker compose -f docker-compose.shared-nginx.yml up -d
        fi
    else
        if [ "$workflow_only" = true ]; then
            log_step "启动Workflow服务..."
            docker compose -f docker-compose.workflow.yml down 2>/dev/null || true
            docker compose -f docker-compose.workflow.yml up -d
        fi
        
        if [ "$file_api_only" = true ]; then
            log_step "启动File API服务..."
            docker compose -f docker-compose.file-api.yml down 2>/dev/null || true
            docker compose -f docker-compose.file-api.yml up -d
        fi
        
        if [ "$no_nginx" != true ]; then
            log_step "重启共享Nginx..."
            docker compose -f docker-compose.shared-nginx.yml restart
        fi
    fi
    
    log_success "服务启动完成"
}

# 停止服务
stop_services() {
    local workflow=${1:-true}
    local file_api=${2:-true}
    local nginx=${3:-true}
    local quiet=${4:-false}
    
    if [ "$quiet" != true ]; then
        log_step "停止Bella服务..."
    fi
    
    if [ "$nginx" = true ]; then
        docker compose -f docker-compose.shared-nginx.yml down 2>/dev/null || true
    fi
    
    if [ "$workflow" = true ]; then
        docker compose -f docker-compose.workflow.yml down 2>/dev/null || true
    fi
    
    if [ "$file_api" = true ]; then
        docker compose -f docker-compose.file-api.yml down 2>/dev/null || true
    fi
    
    if [ "$quiet" != true ]; then
        log_success "服务已停止"
    fi
}

# 检查服务状态
check_services_status() {
    local workflow_only=${1:-false}
    local file_api_only=${2:-false}
    local nginx_only=${3:-false}
    
    log_step "检查服务状态..."
    
    if [ "$nginx_only" = true ]; then
        log_info "共享Nginx状态:"
        docker compose -f docker-compose.shared-nginx.yml ps
        return
    fi
    
    if [ "$workflow_only" != true ] && [ "$file_api_only" != true ]; then
        log_info "Workflow服务状态:"
        docker compose -f docker-compose.workflow.yml ps
        echo
        
        log_info "File API服务状态:"
        docker compose -f docker-compose.file-api.yml ps
        echo
        
        log_info "共享Nginx状态:"
        docker compose -f docker-compose.shared-nginx.yml ps
        echo
    else
        if [ "$workflow_only" = true ]; then
            log_info "Workflow服务状态:"
            docker compose -f docker-compose.workflow.yml ps
        fi
        
        if [ "$file_api_only" = true ]; then
            log_info "File API服务状态:"
            docker compose -f docker-compose.file-api.yml ps
        fi
    fi
    
    # 健康检查
    log_step "检查服务健康状态..."
    sleep 2
    
    # 检查nginx
    if curl -f http://localhost/health &> /dev/null; then
        log_success "共享Nginx健康检查通过"
    else
        log_warning "共享Nginx健康检查失败"
    fi
    
    # 检查域名访问
    if curl -H "Host: ${WORKFLOW_DOMAIN:-workflow.example.com}" http://localhost/health &> /dev/null; then
        log_success "Workflow域名路由正常"
    else
        log_warning "Workflow域名路由异常"
    fi
    
    if curl -H "Host: ${KNOWLEDGE_DOMAIN:-knowledge.example.com}" http://localhost/health &> /dev/null; then
        log_success "Knowledge域名路由正常"  
    else
        log_warning "Knowledge域名路由异常"
    fi
}

# 查看日志
show_logs() {
    local workflow_only=${1:-false}
    local file_api_only=${2:-false}
    local nginx_only=${3:-false}
    
    if [ "$nginx_only" = true ]; then
        docker compose -f docker-compose.shared-nginx.yml logs -f
    elif [ "$workflow_only" = true ]; then
        docker compose -f docker-compose.workflow.yml logs -f
    elif [ "$file_api_only" = true ]; then
        docker compose -f docker-compose.file-api.yml logs -f
    else
        # 显示所有日志（并行）
        docker compose -f docker-compose.workflow.yml logs -f &
        docker compose -f docker-compose.file-api.yml logs -f &
        docker compose -f docker-compose.shared-nginx.yml logs -f &
        wait
    fi
}

# 重新加载nginx配置
reload_nginx() {
    log_step "重新加载Nginx配置..."
    
    if docker ps | grep -q "bella-shared-nginx"; then
        docker exec bella-shared-nginx nginx -s reload
        log_success "Nginx配置已重新加载"
    else
        log_warning "Nginx容器未运行，重启nginx服务..."
        docker compose -f docker-compose.shared-nginx.yml restart
    fi
}

# 显示访问信息
show_access_info() {
    log_success "🎉 Bella Services 部署完成!"
    echo
    echo "📋 服务访问信息:"
    echo "   Workflow 服务:  ${PROTOCOL:-https}://${WORKFLOW_DOMAIN:-workflow.example.com}"
    echo "   Knowledge 服务: ${PROTOCOL:-https}://${KNOWLEDGE_DOMAIN:-knowledge.example.com}"
    echo
    echo "🔧 管理命令:"
    echo "   查看所有日志: $0 logs"
    echo "   查看状态:     $0 status"
    echo "   重启服务:     $0 restart"
    echo "   停止服务:     $0 stop"
    echo "   重载nginx:    $0 nginx-reload"
    echo
    echo "📁 重要目录:"
    echo "   Workflow 日志: ./workflow/api/logs/"
    echo "   File API 日志: ./file-api/api/logs/"
    echo "   Nginx 配置:    ./shared-nginx/conf.d/"
    echo
    echo "💡 提示:"
    echo "   - 确保域名已添加到 /etc/hosts 或DNS解析正确"
    echo "   - 调试端口: Workflow(9008), File API(9009)"
}

# 解析命令行参数
COMMAND="start"
WORKFLOW_ONLY=false
FILE_API_ONLY=false
NGINX_ONLY=false
NO_NGINX=false

while [[ $# -gt 0 ]]; do
    case $1 in
        start|stop|restart|status|logs|nginx-reload)
            COMMAND="$1"
            shift
            ;;
        --workflow-only)
            WORKFLOW_ONLY=true
            shift
            ;;
        --file-api-only)
            FILE_API_ONLY=true
            shift
            ;;
        --nginx-only)
            NGINX_ONLY=true
            shift
            ;;
        --no-nginx)
            NO_NGINX=true
            shift
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            log_error "未知参数: $1"
            show_usage
            exit 1
            ;;
    esac
done

# 执行相应命令
case "$COMMAND" in
    "start")
        echo "🚀 开始部署 Bella Services..."
        echo
        check_prerequisites
        create_directories
        check_domain_resolution
        start_services "$WORKFLOW_ONLY" "$FILE_API_ONLY" "$NGINX_ONLY" "$NO_NGINX"
        sleep 5
        check_services_status "$WORKFLOW_ONLY" "$FILE_API_ONLY" "$NGINX_ONLY"
        show_access_info
        ;;
    "stop")
        stop_services "$(!$FILE_API_ONLY)" "$(!$WORKFLOW_ONLY)" "$(!$NO_NGINX && !$NGINX_ONLY)"
        ;;
    "restart")
        log_info "重启 Bella Services..."
        stop_services "$(!$FILE_API_ONLY)" "$(!$WORKFLOW_ONLY)" "$(!$NO_NGINX && !$NGINX_ONLY)"
        sleep 2
        start_services "$WORKFLOW_ONLY" "$FILE_API_ONLY" "$NGINX_ONLY" "$NO_NGINX"
        ;;
    "status")
        check_services_status "$WORKFLOW_ONLY" "$FILE_API_ONLY" "$NGINX_ONLY"
        ;;
    "logs")
        show_logs "$WORKFLOW_ONLY" "$FILE_API_ONLY" "$NGINX_ONLY"
        ;;
    "nginx-reload")
        reload_nginx
        ;;
esac