# Bella Shared Nginx SSL 配置指南

## SSL证书准备

### 1. 创建SSL证书目录
```bash
mkdir -p shared-nginx/ssl
```

### 2. SSL证书获取方式

#### 方式一：使用Let's Encrypt (推荐用于生产环境)
```bash
# 安装certbot
sudo apt-get update
sudo apt-get install certbot

# 获取证书 (需要先停止nginx或使用standalone模式)
sudo certbot certonly --standalone -d workflow.yourdomain.com -d knowledge.yourdomain.com

# 证书文件位置
sudo cp /etc/letsencrypt/live/workflow.yourdomain.com/fullchain.pem shared-nginx/ssl/
sudo cp /etc/letsencrypt/live/workflow.yourdomain.com/privkey.pem shared-nginx/ssl/
sudo chown $(whoami):$(whoami) shared-nginx/ssl/*.pem
```

#### 方式二：自签名证书 (开发环境)
```bash
cd shared-nginx/ssl

# 生成私钥
openssl genrsa -out privkey.pem 2048

# 生成证书签名请求
openssl req -new -key privkey.pem -out cert.csr \
  -subj "/C=CN/ST=Beijing/L=Beijing/O=Bella/CN=*.example.com"

# 生成自签名证书
openssl x509 -req -days 365 -in cert.csr -signkey privkey.pem -out fullchain.pem

# 清理临时文件
rm cert.csr
```

#### 方式三：通配符证书 (推荐)
```bash
# 如果你有通配符证书 (*.yourdomain.com)
# 直接将证书文件复制到 shared-nginx/ssl/ 目录
cp your-wildcard-fullchain.pem shared-nginx/ssl/fullchain.pem
cp your-wildcard-privkey.pem shared-nginx/ssl/privkey.pem
```

## 配置文件说明

### 当前配置支持两种模式：

1. **HTTPS模式** (bella-services.conf)
   - 自动HTTP到HTTPS重定向
   - 需要SSL证书文件
   - 生产环境推荐

2. **HTTP模式** (bella-services-http-only.conf)  
   - 纯HTTP访问
   - 无需SSL证书
   - 开发环境使用

### 切换配置方式：

#### 使用HTTPS配置：
```bash
# 确保有SSL证书
ls shared-nginx/ssl/
# 应该看到: fullchain.pem  privkey.pem

# 使用默认配置 (bella-services.conf)
docker-compose -f docker-compose.shared-nginx.yml up -d
```

#### 使用HTTP配置：
```bash
# 临时重命名原配置
mv shared-nginx/conf.d/bella-services.conf shared-nginx/conf.d/bella-services.conf.bak

# 使用HTTP版本
mv shared-nginx/conf.d/bella-services-http-only.conf shared-nginx/conf.d/bella-services.conf

# 启动服务
docker-compose -f docker-compose.shared-nginx.yml up -d

# 恢复时再改回来
mv shared-nginx/conf.d/bella-services.conf shared-nginx/conf.d/bella-services-http-only.conf
mv shared-nginx/conf.d/bella-services.conf.bak shared-nginx/conf.d/bella-services.conf
```

## 域名配置

### 环境变量设置：
```bash
# 创建 .env 文件或设置环境变量
export WORKFLOW_DOMAIN=workflow.yourdomain.com
export KNOWLEDGE_DOMAIN=knowledge.yourdomain.com

# 或者在docker-compose.yml中设置
environment:
  - WORKFLOW_DOMAIN=workflow.yourdomain.com
  - KNOWLEDGE_DOMAIN=knowledge.yourdomain.com
```

### DNS配置：
```
# 确保域名解析到服务器IP
workflow.yourdomain.com.    A    YOUR_SERVER_IP
knowledge.yourdomain.com.   A    YOUR_SERVER_IP

# 或使用通配符
*.yourdomain.com.           A    YOUR_SERVER_IP
```

## 服务依赖

Nginx配置中定义了以下上游服务，需要确保这些服务容器在同一网络中：

- `bella-workflow-api:8080` - Workflow API服务
- `bella-workflow-web:3000` - Workflow Web服务  
- `bella-file-api:8081` - File API服务
- `bella-file-web:3000` - File Web服务

## 启动顺序

1. 先启动基础设施服务
```bash
docker-compose -f docker-compose.infrastructure.yml up -d
```

2. 启动业务服务 (workflow, file-api等)
```bash
# 这需要你的业务服务docker-compose文件
docker-compose -f docker-compose.services.yml up -d
```

3. 最后启动Nginx
```bash
docker-compose -f docker-compose.shared-nginx.yml up -d
```

## 故障排查

### 1. 检查SSL证书
```bash
# 验证证书文件
openssl x509 -in shared-nginx/ssl/fullchain.pem -text -noout

# 检查证书和私钥匹配
openssl rsa -in shared-nginx/ssl/privkey.pem -pubout -outform pem | sha256sum
openssl x509 -in shared-nginx/ssl/fullchain.pem -pubkey -noout -outform pem | sha256sum
```

### 2. 检查Nginx配置
```bash
# 测试配置文件语法
docker exec bella-shared-nginx nginx -t

# 查看错误日志
docker logs bella-shared-nginx
```

### 3. 网络连通性
```bash
# 检查容器网络
docker network ls
docker network inspect bella-infrastructure_bella-network

# 测试服务连通性
docker exec bella-shared-nginx nslookup bella-workflow-api
docker exec bella-shared-nginx wget -O- http://bella-workflow-api:8080/health
```