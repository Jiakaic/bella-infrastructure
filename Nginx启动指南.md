# Bella Nginx 启动指南

## 🎯 概述

这个指南将帮助你启动Bella项目的Nginx反向代理服务，支持两种模式：
- **HTTP模式** - 开发环境使用，简单快速
- **HTTPS模式** - 生产环境使用，需要SSL证书

---

## 📋 前提条件

1. **基础设施服务已启动**
   ```bash
   docker-compose -f docker-compose.infrastructure.yml up -d
   ```

2. **业务服务容器运行中** (需要这些服务才能代理)
   - `bella-workflow-api:8080`
   - `bella-workflow-web:3000`
   - `bella-file-api:8081`
   - `bella-file-web:3000`

---

## 🟢 方式一：HTTP模式启动 (推荐开发环境)

### 步骤1：设置域名 (可选)
```bash
export WORKFLOW_DOMAIN=workflow.bella.top
export KNOWLEDGE_DOMAIN=knowledge.bella.top
```

### 步骤2：启动HTTP模式
```bash
# 使用启动脚本 (推荐)
./start-nginx-http.sh
```

**或者手动启动：**
```bash
# 1. 备份原配置
cp shared-nginx/conf.d/bella-services.conf shared-nginx/conf.d/bella-services-ssl.conf.bak

# 2. 使用HTTP配置
cp shared-nginx/conf.d/bella-services-http-only.conf shared-nginx/conf.d/bella-services.conf

# 3. 启动服务
docker-compose -f docker-compose.shared-nginx.yml up -d
```

### 步骤3：验证服务
```bash
# 检查容器状态
docker-compose -f docker-compose.shared-nginx.yml ps

# 测试访问
curl -I http://localhost/health
# 应该返回 200 OK
```

### 步骤4：访问服务
- **Workflow服务**: http://localhost
- **Knowledge服务**: http://localhost (需要在hosts中配置不同域名)

---

## 🔐 方式二：HTTPS模式启动 (推荐生产环境)

### 步骤1：准备SSL证书

#### 选项A：自签名证书 (开发测试)
```bash
# 创建SSL目录
mkdir -p shared-nginx/ssl

# 进入SSL目录
cd shared-nginx/ssl

# 生成私钥
openssl genrsa -out privkey.pem 2048

# 生成证书 (替换yourdomain.com为实际域名)
openssl req -new -x509 -key privkey.pem -out fullchain.pem -days 365 \
  -subj "/C=CN/ST=Beijing/L=Beijing/O=Bella/CN=*.yourdomain.com"

# 回到项目根目录
cd ../..
```

#### 选项B：Let's Encrypt证书 (生产环境)
```bash
# 安装certbot
sudo apt-get update && sudo apt-get install certbot

# 获取证书 (替换为实际域名)
sudo certbot certonly --standalone \
  -d workflow.yourdomain.com \
  -d knowledge.yourdomain.com

# 复制证书到项目
sudo cp /etc/letsencrypt/live/workflow.yourdomain.com/fullchain.pem shared-nginx/ssl/
sudo cp /etc/letsencrypt/live/workflow.yourdomain.com/privkey.pem shared-nginx/ssl/
sudo chown $(whoami):$(whoami) shared-nginx/ssl/*.pem
```

#### 选项C：已有证书
```bash
# 直接复制你的证书文件到
cp your-fullchain.pem shared-nginx/ssl/fullchain.pem
cp your-privkey.pem shared-nginx/ssl/privkey.pem
```

### 步骤2：验证证书文件
```bash
# 检查证书文件是否存在
ls -la shared-nginx/ssl/
# 应该看到: fullchain.pem 和 privkey.pem

# 验证证书有效性
openssl x509 -in shared-nginx/ssl/fullchain.pem -text -noout | grep "Not After"
```

### 步骤3：设置域名
```bash
# 设置真实域名
export WORKFLOW_DOMAIN=workflow.yourdomain.com
export KNOWLEDGE_DOMAIN=knowledge.yourdomain.com
```

### 步骤4：启动HTTPS模式
```bash
# 使用启动脚本 (推荐)
./start-nginx-https.sh
```

**或者手动启动：**
```bash
# 1. 确保使用SSL配置 (默认的bella-services.conf就是SSL版本)
# 如果之前用过HTTP模式，需要恢复
if [ -f "shared-nginx/conf.d/bella-services-ssl.conf.bak" ]; then
    cp shared-nginx/conf.d/bella-services-ssl.conf.bak shared-nginx/conf.d/bella-services.conf
fi

# 2. 启动服务
docker-compose -f docker-compose.shared-nginx.yml up -d
```

### 步骤5：验证HTTPS服务
```bash
# 检查容器状态
docker-compose -f docker-compose.shared-nginx.yml ps

# 测试HTTPS访问
curl -k -I https://workflow.yourdomain.com/health
# 应该返回 200 OK

# 检查SSL配置
docker exec bella-shared-nginx nginx -t
```

### 步骤6：配置DNS解析
```bash
# 在你的DNS提供商处添加A记录
# 或者本地测试时修改 /etc/hosts
echo "YOUR_SERVER_IP workflow.yourdomain.com" | sudo tee -a /etc/hosts
echo "YOUR_SERVER_IP knowledge.yourdomain.com" | sudo tee -a /etc/hosts
```

### 步骤7：访问服务
- **Workflow服务**: https://workflow.yourdomain.com
- **Knowledge服务**: https://knowledge.yourdomain.com

---

## 🔧 常用管理命令

### 查看日志
```bash
# 查看nginx日志
docker logs bella-shared-nginx

# 实时查看日志
docker logs -f bella-shared-nginx
```

### 停止服务
```bash
docker-compose -f docker-compose.shared-nginx.yml down
```

### 重启服务
```bash
docker-compose -f docker-compose.shared-nginx.yml restart
```

### 重新加载配置 (不重启)
```bash
docker exec bella-shared-nginx nginx -s reload
```

### 测试配置文件
```bash
docker exec bella-shared-nginx nginx -t
```

---

## 🚨 故障排查

### 问题1：容器启动失败
```bash
# 查看详细错误
docker-compose -f docker-compose.shared-nginx.yml logs

# 检查端口占用
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443
```

### 问题2：SSL证书错误
```bash
# 验证证书和私钥匹配
openssl rsa -in shared-nginx/ssl/privkey.pem -pubout -outform pem | sha256sum
openssl x509 -in shared-nginx/ssl/fullchain.pem -pubkey -noout -outform pem | sha256sum
# 两个输出应该相同
```

### 问题3：网络连接失败
```bash
# 检查网络
docker network ls | grep bella
docker network inspect bella-infrastructure_bella-network

# 测试后端服务连通性
docker exec bella-shared-nginx wget -O- http://bella-workflow-api:8080/health
```

### 问题4：域名无法访问
```bash
# 检查DNS解析
nslookup workflow.yourdomain.com

# 本地测试可以修改hosts文件
echo "127.0.0.1 workflow.yourdomain.com knowledge.yourdomain.com" | sudo tee -a /etc/hosts
```

---

## ✨ 快速切换模式

### 从HTTP切换到HTTPS
```bash
# 1. 准备SSL证书 (见上面步骤)
# 2. 停止当前服务
docker-compose -f docker-compose.shared-nginx.yml down
# 3. 启动HTTPS模式
./start-nginx-https.sh
```

### 从HTTPS切换到HTTP
```bash
# 1. 停止当前服务
docker-compose -f docker-compose.shared-nginx.yml down
# 2. 启动HTTP模式
./start-nginx-http.sh
```

---

## 📝 注意事项

1. **生产环境建议使用HTTPS模式**
2. **开发环境可以使用HTTP模式，更简单**
3. **确保域名DNS解析正确指向服务器**
4. **SSL证书需要定期续期 (Let's Encrypt 90天)**
5. **定期检查nginx配置和日志**