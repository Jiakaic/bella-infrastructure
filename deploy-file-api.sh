#!/bin/bash

# Bella File API 部署脚本
# 用途: 部署 Bella File API 和 Web 服务，包括 Nginx 反向代理

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# 检查必要条件
check_prerequisites() {
    log_info "检查部署前置条件..."
    
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
    log_info "创建必要的目录..."
    
    # 创建运行时目录
    mkdir -p file-api/api/{logs,cache,privdata,configuration}
    
    log_success "目录创建完成"
}

# 部署服务
deploy_services() {
    log_info "部署 Bella File API 服务..."
    
    # 停止可能存在的旧服务
    log_info "停止旧服务..."
    docker compose -f docker-compose.file-api.yml down 2>/dev/null || true
    docker compose -f docker-compose.file-api-nginx.yml down 2>/dev/null || true
    
    # 启动 File API 服务
    log_info "启动 File API 和 Web 服务..."
    docker compose -f docker-compose.file-api.yml up -d
    
    # 等待服务启动
    log_info "等待服务启动..."
    sleep 10
    
    # 启动 Nginx
    log_info "启动 File API Nginx..."
    docker compose -f docker-compose.file-api-nginx.yml up -d
    
    log_success "File API 服务部署完成"
}

# 检查服务状态
check_services() {
    log_info "检查服务状态..."
    
    # 检查容器状态
    log_info "容器状态:"
    docker compose -f docker-compose.file-api.yml ps
    docker compose -f docker-compose.file-api-nginx.yml ps
    
    # 检查健康状态
    sleep 5
    log_info "检查服务健康状态..."
    
    # 检查 API 健康状态
    if curl -f http://localhost:8081/health &> /dev/null; then
        log_success "File API 服务健康检查通过"
    else
        log_warning "File API 服务健康检查失败，请检查日志"
    fi
    
    # 检查 Web 服务
    if curl -f http://localhost:3001/ &> /dev/null; then
        log_success "File Web 服务健康检查通过"
    else
        log_warning "File Web 服务健康检查失败，请检查日志"
    fi
    
    # 检查 Nginx
    if curl -f http://localhost:81/health &> /dev/null; then
        log_success "File API Nginx 健康检查通过"
    else
        log_warning "File API Nginx 健康检查失败，请检查日志"
    fi
}

# 显示访问信息
show_access_info() {
    log_success "🎉 Bella File API 部署完成!"
    echo
    echo "📋 服务访问信息:"
    echo "   File API (直接访问):  http://localhost:8081"
    echo "   File Web (直接访问):  http://localhost:3001"
    echo "   File 服务 (Nginx):   http://localhost:81"
    echo
    echo "🔧 管理命令:"
    echo "   查看日志: docker compose -f docker-compose.file-api.yml logs -f"
    echo "   停止服务: docker compose -f docker-compose.file-api.yml down"
    echo "   重启服务: docker compose -f docker-compose.file-api.yml restart"
    echo
    echo "📁 重要目录:"
    echo "   API 日志: ./file-api/api/logs/"
    echo "   API 配置: ./file-api/api/configuration/"
    echo "   私有数据: ./file-api/api/privdata/"
}

# 主函数
main() {
    echo "🚀 开始部署 Bella File API..."
    echo
    
    check_prerequisites
    create_directories
    deploy_services
    check_services
    show_access_info
    
    log_success "部署完成! 🎉"
}

# 处理脚本参数
case "$1" in
    "stop")
        log_info "停止 Bella File API 服务..."
        docker compose -f docker-compose.file-api.yml down
        docker compose -f docker-compose.file-api-nginx.yml down
        log_success "服务已停止"
        ;;
    "restart")
        log_info "重启 Bella File API 服务..."
        docker compose -f docker-compose.file-api.yml down
        docker compose -f docker-compose.file-api-nginx.yml down
        sleep 2
        main
        ;;
    "logs")
        docker compose -f docker-compose.file-api.yml logs -f
        ;;
    "status")
        check_services
        ;;
    *)
        main
        ;;
esac