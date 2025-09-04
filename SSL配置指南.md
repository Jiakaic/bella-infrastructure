# SSL 配置指南

## 🎯 目标
为 `${WORKFLOW_DOMAIN}` 和 `${KNOWLEDGE_DOMAIN}` 配置 HTTPS 和真正域名

## 📋 步骤

### 1. 获取 SSL 证书
```bash
# 使用 Let's Encrypt (推荐)
sudo certbot certonly --standalone -d ${WORKFLOW_DOMAIN} -d ${KNOWLEDGE_DOMAIN}

# 或上传现有证书，确保文件名为：
# - fullchain.pem (完整证书链)
# - privkey.pem (私钥)
```

### 2. 放置证书文件
```bash
# 在项目根目录执行 (/Users/jiakaic/dev_tools/IdeaProjects/opensource/)
mkdir -p shared-nginx/ssl
cp /path/to/your/fullchain.pem shared-nginx/ssl/
cp /path/to/your/privkey.pem shared-nginx/ssl/
```

### 3. 配置 DNS 解析
- 将两个域名的 A 记录指向服务器 IP：
  - `${WORKFLOW_DOMAIN}` → `你的服务器IP`
  - `${KNOWLEDGE_DOMAIN}` → `你的服务器IP`

### 4. 重启服务
```bash
# 在项目根目录执行
docker compose -f docker-compose.shared-nginx.yml restart
```

### 5. 验证配置
```bash
# 测试 nginx 配置
docker exec bella-shared-nginx nginx -t

# 检查 HTTPS
curl https://${WORKFLOW_DOMAIN}/health
curl https://${KNOWLEDGE_DOMAIN}/health
```

## ✅ 配置特性
- ✅ HTTP 自动重定向到 HTTPS
- ✅ 现代 SSL/TLS 安全设置
- ✅ HTTP/2 支持
- ✅ 双域名证书支持

## 🔧 已完成的代码修改
- Docker Compose SSL 挂载已启用
- Nginx 配置已添加 HTTPS 支持
- HTTP→HTTPS 重定向已配置