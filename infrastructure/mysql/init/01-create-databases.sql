-- 创建数据库和用户
CREATE DATABASE IF NOT EXISTS bella_workflow CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS bella_file_api CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

-- 创建用户
CREATE USER IF NOT EXISTS 'bella_workflow'@'%' IDENTIFIED BY 'bella123';
CREATE USER IF NOT EXISTS 'bella_file_api'@'%' IDENTIFIED BY 'bella123';
CREATE USER IF NOT EXISTS 'bella_user'@'%' IDENTIFIED BY '123456';

-- 授权
GRANT ALL PRIVILEGES ON bella_workflow.* TO 'bella_workflow'@'%';
GRANT ALL PRIVILEGES ON bella_file_api.* TO 'bella_file_api'@'%';
GRANT ALL PRIVILEGES ON bella_file_api.* TO 'bella_user'@'%';

FLUSH PRIVILEGES;
