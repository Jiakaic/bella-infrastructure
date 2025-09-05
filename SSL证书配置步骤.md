# SSL 证书配置步骤指南

## 前提条件
确保您已经有了以下SSL证书文件：
- `workflow.bella.top` 域名的证书文件
- `knowledge.bella.top` 域名的证书文件

## 步骤 1: 创建SSL证书存放目录

```bash
# 创建SSL证书目录（如果不存在）
mkdir -p shared-nginx/ssl
```

## 步骤 2: 放置SSL证书文件

将您的SSL证书文件放置到 `shared-nginx/ssl/` 目录中，需要以下两个文件：

```bash
# 复制证书文件到指定位置
cp /path/to/your/fullchain.pem shared-nginx/ssl/fullchain.pem
cp /path/to/your/privkey.pem shared-nginx/ssl/privkey.pem
```

### 证书文件说明：
- `fullchain.pem` - 完整证书链文件（包含域名证书和中间证书）
- `privkey.pem` - 私钥文件

### 如果您的证书文件名不同，请重命名：
```bash
# 示例：如果您的文件名为其他格式
cp your-certificate.crt shared-nginx/ssl/fullchain.pem
cp your-private.key shared-nginx/ssl/privkey.pem
```

## 步骤 3: 验证证书文件

```bash
# 验证证书文件是否正确
openssl x509 -in shared-nginx/ssl/fullchain.pem -text -noout | grep -E "Subject:|DNS:"

# 检查证书和私钥是否匹配
openssl rsa -in shared-nginx/ssl/privkey.pem -pubout -outform pem | sha256sum
openssl x509 -in shared-nginx/ssl/fullchain.pem -pubkey -noout -outform pem | sha256sum
# 上述两个命令的输出应该相同
```

## 步骤 4: 设置文件权限

```bash
# 设置合适的文件权限
chmod 644 shared-nginx/ssl/fullchain.pem
chmod 600 shared-nginx/ssl/privkey.pem
```

## 步骤 5: 配置环境变量

```bash
# 设置域名环境变量
export WORKFLOW_DOMAIN=workflow.bella.top
export KNOWLEDGE_DOMAIN=knowledge.bella.top
```

或者创建 `.env` 文件：
```bash
# 创建.env文件
cat > .env << EOF
WORKFLOW_DOMAIN=workflow.bella.top
KNOWLEDGE_DOMAIN=knowledge.bella.top
TZ=Asia/Shanghai
EOF
```

## 步骤 6: 验证nginx配置文件

```bash
# 检查nginx配置是否使用HTTPS模式
ls shared-nginx/conf.d/

# 确保使用的是 bella-services.conf (HTTPS模式)
# 如果当前使用的是 bella-services-http-only.conf，需要切换
```

## 步骤 7: 启动shared-nginx服务

### 方式一：使用docker-compose直接启动
```bash
# 启动nginx服务
docker-compose -f docker-compose.shared-nginx.yml up -d
```

### 方式二：使用启动脚本
```bash
# 使用HTTPS启动脚本
./start-nginx-https.sh
```

## 步骤 8: 验证服务状态

```bash
# 检查容器状态
docker ps | grep bella-shared-nginx

# 查看nginx日志
docker logs bella-shared-nginx

# 测试nginx配置
docker exec bella-shared-nginx nginx -t

# 检查SSL证书加载情况
docker exec bella-shared-nginx ls -la /etc/nginx/ssl/
```

## 步骤 9: 测试HTTPS访问

```bash
# 测试HTTPS连接
curl -k https://workflow.bella.top/health
curl -k https://knowledge.bella.top/health

# 检查证书信息
openssl s_client -connect workflow.bella.top:443 -servername workflow.bella.top < /dev/null 2>/dev/null | openssl x509 -text -noout | grep -E "Subject:|DNS:"
```

## 故障排查

### 1. 如果nginx启动失败
```bash
# 查看详细错误信息
docker logs bella-shared-nginx

# 测试配置文件语法
docker exec bella-shared-nginx nginx -t
```

### 2. 如果证书文件权限问题
```bash
# 检查文件权限
ls -la shared-nginx/ssl/

# 重新设置权限
sudo chown $(whoami):$(whoami) shared-nginx/ssl/*
chmod 644 shared-nginx/ssl/fullchain.pem
chmod 600 shared-nginx/ssl/privkey.pem
```

### 3. 如果域名访问不通
```bash
# 检查DNS解析
nslookup workflow.bella.top
nslookup knowledge.bella.top

# 检查防火墙端口
sudo netstat -tlnp | grep :443
```

### 4. 如果需要重启服务
```bash
# 重启nginx容器
docker restart bella-shared-nginx

# 或重新部署
docker-compose -f docker-compose.shared-nginx.yml down
docker-compose -f docker-compose.shared-nginx.yml up -d
```

## 完整检查清单

- [ ] SSL证书文件已放置在 `shared-nginx/ssl/` 目录
- [ ] 证书文件权限设置正确 (fullchain.pem: 644, privkey.pem: 600)
- [ ] 环境变量或.env文件已配置域名
- [ ] nginx配置使用HTTPS模式 (bella-services.conf)
- [ ] shared-nginx容器成功启动
- [ ] nginx配置测试通过 (`nginx -t`)
- [ ] HTTPS健康检查通过
- [ ] 域名可以正常访问

## 备注

- 当前配置支持 `workflow.bella.top` 和 `knowledge.bella.top` 两个域名
- 两个域名使用相同的SSL证书文件
- nginx会自动将HTTP请求重定向到HTTPS
- 如果需要修改域名，请更新环境变量和DNS解析