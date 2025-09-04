#!/bin/bash

# deploy-middleware.sh - Bella中间件一键部署脚本

set -e

echo "=== Bella中间件一键部署脚本 ==="

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查依赖
check_dependencies() {
    log_info "检查系统依赖..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装或未在PATH中"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose 未安装或未在PATH中"
        exit 1
    fi
    
    log_info "依赖检查通过"
}

# 检查环境变量文件
check_env_files() {
    log_info "检查环境变量文件..."
    
    if [ ! -f ".env" ]; then
        log_error ".env 文件不存在！"
        log_error "请运行: cp .env.example .env 并编辑配置"
        exit 1
    fi
    
    log_info "使用统一的 .env 配置文件"
}

# 准备初始化脚本
prepare_init_scripts() {
    log_info "准备初始化脚本..."
    
    # 准备MySQL脚本
    if [ ! -f "prepare-mysql-init.sh" ]; then
        log_error "prepare-mysql-init.sh 脚本不存在"
        exit 1
    fi
    
    chmod +x prepare-mysql-init.sh
    ./prepare-mysql-init.sh
    
    # 创建其他必要目录和脚本
    mkdir -p infrastructure/{kafka/scripts,minio/scripts,elasticsearch/scripts}
    
    # 确保bella-workflow日志目录存在
    mkdir -p ../bella-workflow/api/logs
    touch ../bella-workflow/api/logs/workflow-run.log
    chmod 666 ../bella-workflow/api/logs/workflow-run.log
    
    log_info "日志文件路径: $(pwd)/../bella-workflow/api/logs/workflow-run.log"
    
    # Kafka setup脚本
    cat > infrastructure/kafka/scripts/setup-topics.sh << 'EOF'
#!/bin/bash

echo "=== Kafka Topics Setup ==="

# 等待Kafka启动
sleep 30

# 创建Connect相关topics
/opt/bitnami/kafka/bin/kafka-topics.sh --create --if-not-exists --bootstrap-server kafka:9092 --replication-factor 1 --partitions 1 --topic connect-configs
/opt/bitnami/kafka/bin/kafka-topics.sh --create --if-not-exists --bootstrap-server kafka:9092 --replication-factor 1 --partitions 1 --topic connect-offsets
/opt/bitnami/kafka/bin/kafka-topics.sh --create --if-not-exists --bootstrap-server kafka:9092 --replication-factor 1 --partitions 1 --topic connect-status

# 创建业务topics
/opt/bitnami/kafka/bin/kafka-topics.sh --create --if-not-exists --bootstrap-server kafka:9092 --replication-factor 1 --partitions 1 --topic ${WORKFLOW_RUN_LOG_TOPIC:-workflow_run_log}
/opt/bitnami/kafka/bin/kafka-topics.sh --create --if-not-exists --bootstrap-server kafka:9092 --replication-factor 1 --partitions 3 --topic ${FILE_API_TOPIC:-bella_file_api}

# 设置Workflow日志收集 - 使用tail方式实时采集
mkdir -p /tmp/kafka-logs
chmod 777 /tmp/kafka-logs

# 创建日志采集脚本
cat > /opt/bitnami/kafka/bin/log-collector.sh << 'LOG_EOF'
#!/bin/bash

LOG_FILE="/bella-workflow/api/logs/workflow-run.log"
TOPIC="${WORKFLOW_RUN_LOG_TOPIC:-workflow_run_log}"

echo "Starting log collector for: $LOG_FILE -> $TOPIC"

# 检查日志文件是否存在
if [ ! -f "$LOG_FILE" ]; then
    echo "Warning: Log file $LOG_FILE not found, creating it..."
    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE"
fi

# 使用tail -f实时监控日志文件，发送到Kafka
tail -F "$LOG_FILE" 2>/dev/null | while IFS= read -r line; do
    if [ ! -z "$line" ]; then
        echo "$line" | /opt/bitnami/kafka/bin/kafka-console-producer.sh \
            --bootstrap-server localhost:9092 \
            --topic "$TOPIC" >/dev/null 2>&1
    fi
done
LOG_EOF

chmod +x /opt/bitnami/kafka/bin/log-collector.sh

# 启动日志采集器
nohup /opt/bitnami/kafka/bin/log-collector.sh > /tmp/kafka-logs/collector.log 2>&1 &

# 列出topics
echo "Created topics:"
/opt/bitnami/kafka/bin/kafka-topics.sh --bootstrap-server kafka:9092 --list

tail -f /dev/null
EOF

    # MinIO setup脚本
    cat > infrastructure/minio/scripts/init-buckets.sh << 'EOF'
#!/bin/bash

echo "=== MinIO Buckets Setup ==="

sleep 20

# 等待MinIO启动
until curl -f http://minio:9000/minio/health/live; do
    echo "等待 MinIO 启动..."
    sleep 5
done

# 配置mc (mc已经预装在minio/mc镜像中)
mc alias set minio http://minio:9000 ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}

# 创建buckets
echo "创建 workflow bucket: ${WORKFLOW_S3_BUCKET}"
mc mb minio/${WORKFLOW_S3_BUCKET} || echo "Workflow bucket exists"

echo "创建 file-api bucket: ${FILE_API_S3_BUCKET}"  
mc mb minio/${FILE_API_S3_BUCKET} || echo "File-API bucket exists"

# 设置策略
mc anonymous set public minio/${WORKFLOW_S3_BUCKET}
mc anonymous set public minio/${FILE_API_S3_BUCKET}

echo "MinIO setup completed!"
EOF

    # Elasticsearch setup脚本
    cat > infrastructure/elasticsearch/scripts/init-elasticsearch.sh << 'EOF'
#!/bin/bash

echo "=== Elasticsearch Setup ==="

# 等待启动
until curl -s http://localhost:9200/_cluster/health; do
    echo "等待 Elasticsearch 启动..."
    sleep 10
done

# 创建索引模板
curl -X PUT "localhost:9200/_index_template/workflow_run_log_template" -H 'Content-Type: application/json' -d'
{
  "index_patterns": ["workflow_run_log_*"],
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0
    },
    "mappings": {
      "properties": {
        "timestamp": {"type": "date"},
        "level": {"type": "keyword"},
        "message": {"type": "text", "analyzer": "standard"},
        "workflow_id": {"type": "keyword"},
        "node_id": {"type": "keyword"},
        "execution_id": {"type": "keyword"}
      }
    }
  }
}'

echo "Elasticsearch setup completed!"
EOF

    # 设置脚本权限
    chmod +x infrastructure/kafka/scripts/setup-topics.sh
    chmod +x infrastructure/minio/scripts/init-buckets.sh  
    chmod +x infrastructure/elasticsearch/scripts/init-elasticsearch.sh
    
    # 设置bella-workflow日志目录权限
    chmod 777 ../bella-workflow/api/logs
    
    log_info "初始化脚本准备完成"
}

# 创建docker-compose文件
create_docker_compose() {
    log_info "创建Docker Compose配置文件..."
    
    # 这里需要创建完整的docker-compose.infrastructure.yml文件
    # 由于文件较长，建议从之前提供的配置中复制
    
    if [ ! -f "docker-compose.infrastructure.yml" ]; then
        log_warn "docker-compose.infrastructure.yml 文件不存在"
        log_warn "请手动创建该文件，参考中间件部署指南"
        log_warn "注意：Kafka服务需要添加volume映射: ../bella-workflow/api/logs:/bella-workflow/api/logs"
    fi
}

# 启动基础设施
deploy_infrastructure() {
    log_info "启动基础设施服务..."
    
    # 创建网络
    docker network create bella-network 2>/dev/null || log_warn "网络已存在"
    
    # 启动服务
    docker-compose --env-file .env -f docker-compose.infrastructure.yml up -d
    
    log_info "等待基础设施初始化完成（约3-5分钟）..."
    sleep 300
    
    # 验证日志文件映射
    verify_log_file_mapping
}

# 验证日志文件映射
verify_log_file_mapping() {
    log_info "验证日志文件映射..."
    
    # 检查宿主机日志文件是否存在
    if [ ! -f "../bella-workflow/api/logs/workflow-run.log" ]; then
        log_error "宿主机日志文件不存在: ../bella-workflow/api/logs/workflow-run.log"
        return 1
    fi
    
    # 检查Kafka容器内是否能访问日志文件
    if docker exec bella-kafka test -f /bella-workflow/api/logs/workflow-run.log; then
        log_info "Kafka容器可以访问日志文件"
        
        # 测试写入权限
        if docker exec bella-kafka sh -c "echo 'test log entry' >> /bella-workflow/api/logs/workflow-run.log"; then
            log_info "日志文件写入权限正常"
        else
            log_error "日志文件写入权限异常"
            return 1
        fi
    else
        log_error "Kafka容器无法访问日志文件，请检查Docker Compose volume映射"
        log_error "需要添加: ../bella-workflow/api/logs:/bella-workflow/api/logs"
        return 1
    fi
    
    log_info "日志文件映射验证通过"
}

# 验证部署
verify_deployment() {
    log_info "验证基础设施部署..."
    
    local all_good=true
    
    # 检查容器状态
    log_info "检查容器状态..."
    if ! docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q "bella-"; then
        log_error "没有找到bella相关容器"
        all_good=false
    fi
    
    # 检查MySQL
    log_info "检查MySQL..."
    if ! docker exec bella-mysql mysql -u root -proot -e "SELECT 1;" &>/dev/null; then
        log_error "MySQL连接失败"
        all_good=false
    else
        local db_count=$(docker exec bella-mysql mysql -u root -proot -e "SHOW DATABASES;" | grep -c "bella_")
        if [ "$db_count" -lt 2 ]; then
            log_error "数据库创建不完整"
            all_good=false
        fi
    fi
    
    # 检查Redis
    log_info "检查Redis..."
    if ! docker exec bella-redis redis-cli -a bella123 ping &>/dev/null; then
        log_error "Redis连接失败"
        all_good=false
    fi
    
    # 检查Kafka
    log_info "检查Kafka..."
    local topic_count=$(docker exec bella-kafka kafka-topics.sh --bootstrap-server localhost:9092 --list 2>/dev/null | grep -c -E "(workflow_run_log|bella_file_api)")
    if [ "$topic_count" -lt 2 ]; then
        log_error "Kafka topics创建不完整"
        all_good=false
    fi
    
    # 检查日志采集器
    if docker exec bella-kafka pgrep -f "log-collector.sh" > /dev/null; then
        log_info "日志采集器运行正常"
    else
        log_error "日志采集器未运行"
        all_good=false
    fi
    
    # 检查Elasticsearch
    log_info "检查Elasticsearch..."
    if ! curl -s http://localhost:9200/_cluster/health | grep -q '"status":"green\|yellow"'; then
        log_error "Elasticsearch健康检查失败"
        all_good=false
    fi
    
    # 检查MinIO
    log_info "检查MinIO..."
    if ! curl -s http://localhost:9000/minio/health/live &>/dev/null; then
        log_error "MinIO健康检查失败"
        all_good=false
    fi
    
    if [ "$all_good" = true ]; then
        log_info "所有基础设施验证通过!"
        echo ""
        echo "=== 部署完成 ==="
        echo "MySQL: localhost:3306 (root/root)"
        echo "  - bella_workflow DB: bella_workflow/bella123"
        echo "  - bella_file_api DB: bella_user/123456"
        echo "Redis: localhost:6379 (password: bella123)"
        echo "Kafka: localhost:9092"
        echo "Elasticsearch: http://localhost:9200"
        echo "MinIO Console: http://localhost:9001 (bella_admin/bella123456)"
        echo ""
        echo "下一步: 部署网关和业务服务"
    else
        log_error "部署验证失败，请检查上述错误"
        exit 1
    fi
}

# 主执行流程
main() {
    check_dependencies
    check_env_files
    prepare_init_scripts
    create_docker_compose
    deploy_infrastructure
    verify_deployment
}

# 执行主流程
main "$@"