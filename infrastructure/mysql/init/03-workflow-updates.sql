USE bella_workflow;

-- update.20240711.sql

alter table `workflow_node_run`
    add column `node_run_id` varchar(128) NOT NULL DEFAULT '' after `workflow_run_id`;
-- update.20240718.sql

alter table `workflow`
    add column `mode` varchar(64) NOT NULL DEFAULT 'workflow' after `title`;

alter table `workflow_aggregate`
    add column `mode` varchar(64) NOT NULL DEFAULT 'workflow' after `title`;
    
alter table `workflow_run`
    add column `query` TEXT after `trigger_from`;
alter table `workflow_run`
    add column `files` TEXT after `query`;
-- update.20240730.sql
alter table `tenant`
    add column `openapi_key` varchar(64) NOT NULL DEFAULT '' after `tenant_name`;

-- update.20240814.sql
ALTER TABLE workflow
    MODIFY graph LONGTEXT NOT NULL COMMENT '工作流DAG配置';

ALTER TABLE workflow_aggregate
    MODIFY graph LONGTEXT NOT NULL COMMENT '工作流DAG配置';

-- update.20240815.sql
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE `wecom_group_info`
(
    `id`          BIGINT ( 20 ) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
    `tenant_id`   VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '租户ID',
    `space_code`  VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '空间编码，默认：personal，.......',
    `group_code`  VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '群编码-暗号',
    `group_name`  VARCHAR(128) NOT NULL DEFAULT '' COMMENT '群名字',
    `group_alias` VARCHAR(128) NOT NULL DEFAULT '' COMMENT '群备注',
    `group_id`    VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '企微中台ID-虚拟号指定群发消息',
    `chat_id`     VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '会话Id-群Id-机器人指定群发消息',
    `cuid`        BIGINT ( 20 ) NOT NULL DEFAULT '0' COMMENT '创建人ucid',
    `cu_name`     VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '创建人名字',
    `muid`        BIGINT ( 20 ) NOT NULL DEFAULT '0' COMMENT '修改人ucid',
    `mu_name`     VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '修改人名字',
    `status`      TINYINT ( 4 ) NOT NULL DEFAULT '0' COMMENT '记录状态（0:正常, -1:已删除）',
    `ctime`       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `mtime`       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_group_code` ( `group_code` ),
    KEY           `idx_tenant_id_space_code_cuid` ( `tenant_id`, `space_code`, `cuid` )
) ENGINE = INNODB AUTO_INCREMENT = 0 DEFAULT CHARSET = utf8mb4 COMMENT = '企业微信群信息管理';

CREATE TABLE `wecom_group_member`
(
    `id`             BIGINT ( 20 ) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
    `tenant_id`      VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '租户ID',
    `space_code`     VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '空间编码，默认：personal，.......',
    `group_code`     VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '群编码-暗号',
    `user_code`      VARCHAR(32)  NOT NULL DEFAULT '' COMMENT '群成员系统号',
    `robot_id`       VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '机器人ID',
    `robot_outer_id` varchar(32)  NOT NULL DEFAULT '' COMMENT '机器人外部id',
    `name`           VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '名称',
    `robot_webhook`  VARCHAR(128) NOT NULL DEFAULT '' COMMENT '机器人钩子地址',
    `type`           TINYINT ( 4 ) NOT NULL DEFAULT '0' COMMENT '成员类型（0:未知,1:虚拟账号,2:机器人,3:真实用户）',
    `cuid`           BIGINT ( 20 ) NOT NULL DEFAULT '0' COMMENT '创建人ucid',
    `cu_name`        VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '创建人名字',
    `muid`           BIGINT ( 20 ) NOT NULL DEFAULT '0' COMMENT '修改人ucid',
    `mu_name`        VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '修改人名字',
    `status`         TINYINT ( 4 ) NOT NULL DEFAULT '0' COMMENT '记录状态（0:正常, -1:已删除）',
    `ctime`          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `mtime`          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY              `idx_tenant_id_space_code_cuid_group_code` ( `tenant_id`, `space_code`, `group_code` )
) ENGINE = INNODB AUTO_INCREMENT = 0 DEFAULT CHARSET = utf8mb4 COMMENT = '企业微信群成员信息';


CREATE TABLE `kafka_datasource` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '租户ID',
  `datasource_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `space_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'PERSONNAL',
  `server` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'kafka服务地址\nhost:port',
  `topic` varchar(255) NOT NULL COMMENT 'Kafka topic',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '数据源名称',
  `msg_schema` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '消息体的json schema',
  `status` int NOT NULL DEFAULT '0' COMMENT '数据源状态\n-1: 无效\n0: 生效',
  `cuid` bigint NOT NULL DEFAULT '0',
  `muid` bigint NOT NULL DEFAULT '0',
  `ctime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `mtime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cu_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `mu_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_id` (`datasource_id`),
  KEY `idx_t_space_topic` (`tenant_id`,`topic`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `workflow_kafka_trigger` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `trigger_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'KFKA',
  `trigger_id` varchar(128) NOT NULL,
  `datasource_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `expression` text NOT NULL,
  `workflow_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `inputs` text NOT NULL,
  `inputKey` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调用工作流的时候作为inputs的一个字段',
  `status` int NOT NULL DEFAULT '0',
  `cuid` bigint NOT NULL DEFAULT '0',
  `muid` bigint NOT NULL,
  `cu_name` varchar(32) NOT NULL DEFAULT '',
  `mu_name` varchar(32) NOT NULL DEFAULT '',
  `ctime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `mtime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_id` (`trigger_id`),
  KEY `idx_dsid` (`datasource_id`),
  KEY `idx_tenantid` (`tenant_id`,`cuid`,`ctime`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `workflow_webot_trigger` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `trigger_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'WBOT',
  `trigger_id` varchar(128) NOT NULL,
  `chat_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `robot_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `expression` text NOT NULL,
  `workflow_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `inputs` text NOT NULL,
  `inputKey` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调用工作流的时候作为inputs的一个字段',
  `status` int NOT NULL DEFAULT '0',
  `cuid` bigint NOT NULL DEFAULT '0',
  `muid` bigint NOT NULL,
  `cu_name` varchar(32) NOT NULL DEFAULT '',
  `mu_name` varchar(32) NOT NULL DEFAULT '',
  `ctime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `mtime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_id` (`trigger_id`),
  KEY `idx_tenantid` (`tenant_id`,`cuid`,`ctime`),
  KEY `idx_robotid` (`robot_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


ALTER TABLE `workflow_run` ADD COLUMN `trigger_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' AFTER `workflow_scheduling_id`;

UPDATE `workflow_run` set `trigger_id` = `workflow_scheduling_id`;

ALTER TABLE `workflow_scheduling` ADD COLUMN `trigger_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' AFTER `tenant_id`;
ALTER TABLE `workflow_scheduling` ADD COLUMN `trigger_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'SCHD' AFTER `trigger_id`;

UPDATE `workflow_scheduling` set `trigger_id` = `workflow_scheduling_id`;

ALTER TABLE `workflow_scheduling` DROP INDEX `idx_workflow_scheduling_id`;

SET FOREIGN_KEY_CHECKS = 1;

-- update.20240827.sql
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE workflow_run
    MODIFY inputs LONGTEXT NOT NULL COMMENT '',
    MODIFY outputs LONGTEXT NOT NULL COMMENT '';

ALTER TABLE workflow_node_run
    MODIFY inputs LONGTEXT NOT NULL COMMENT '',
    MODIFY outputs LONGTEXT NOT NULL COMMENT '';

ALTER TABLE workflow_scheduling
    MODIFY inputs LONGTEXT NOT NULL COMMENT '';

ALTER TABLE workflow_webot_trigger
    MODIFY inputs LONGTEXT NOT NULL COMMENT '';

ALTER TABLE workflow_kafka_trigger
    MODIFY inputs LONGTEXT NOT NULL COMMENT '';

SET FOREIGN_KEY_CHECKS = 1;

-- update.20240829.sql
SET FOREIGN_KEY_CHECKS=0;

ALTER TABLE `workflow_kafka_trigger` ADD COLUMN `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' AFTER `trigger_id`;

ALTER TABLE `workflow_kafka_trigger` ADD COLUMN `desc` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' AFTER `name`;

ALTER TABLE `workflow_kafka_trigger` MODIFY COLUMN `tenant_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' AFTER `id`;

ALTER TABLE `workflow_kafka_trigger` MODIFY COLUMN `inputKey` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'event' COMMENT '调用工作流的时候作为inputs的一个字段' AFTER `inputs`;

ALTER TABLE `workflow_kafka_trigger` ADD INDEX `idx_workflow_id`(`workflow_id` ASC) USING BTREE;

ALTER TABLE `workflow_scheduling` DROP INDEX `idx_status_trigger_next_time`;

ALTER TABLE `workflow_scheduling` ADD COLUMN `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' AFTER `trigger_type`;

ALTER TABLE `workflow_scheduling` ADD COLUMN `desc` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' AFTER `name`;

ALTER TABLE `workflow_scheduling` ADD COLUMN `running_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'init' COMMENT '调度任务状态；\ninit:待执行\npending:已有线程在处理,等待提交workflow_run\nrunning:workflow_run进行中\nfinished:已完成\nerror:出现异常\n:canceled:取消' AFTER `inputs`;

ALTER TABLE `workflow_scheduling` MODIFY COLUMN `trigger_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' AFTER `tenant_id`;

UPDATE `workflow_scheduling` set `running_status` = `status`;
UPDATE `workflow_scheduling` set `status` = '0';
ALTER TABLE `workflow_scheduling` MODIFY COLUMN `status` int NOT NULL DEFAULT 0 AFTER `running_status`;

ALTER TABLE `workflow_scheduling` ADD INDEX `idx_status_trigger_next_time`(`trigger_next_time` ASC, `running_status` ASC, `status` ASC) USING BTREE;

ALTER TABLE `workflow_scheduling` ADD INDEX `idx_workflow_id`(`workflow_id` ASC) USING BTREE;

ALTER TABLE `workflow_webot_trigger` ADD COLUMN `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' AFTER `trigger_id`;

ALTER TABLE `workflow_webot_trigger` ADD COLUMN `desc` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' AFTER `name`;

ALTER TABLE `workflow_webot_trigger` ADD INDEX `idx_workflow_id`(`workflow_id` ASC) USING BTREE;

ALTER TABLE `workflow_aggregate` ADD COLUMN `status` TINYINT(4) NOT NULL DEFAULT 0 COMMENT '状态（0:正常, -1:已删除）' AFTER `latest_publish_version`;

SET FOREIGN_KEY_CHECKS=1;

-- update.20240903.sql
SET FOREIGN_KEY_CHECKS=0;

ALTER TABLE workflow_run
    MODIFY `query` LONGTEXT COMMENT '';

ALTER TABLE workflow_node_run
    MODIFY `process_data` LONGTEXT NOT NULL COMMENT '';

SET FOREIGN_KEY_CHECKS=1;

-- update.20240905.sql
ALTER TABLE `workflow_run` ADD COLUMN `metadata` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' AFTER `response_mode`;

ALTER TABLE `workflow_run` ADD COLUMN `thread_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT 'thread_id' AFTER `metadata`;

ALTER TABLE `workflow_run` ADD COLUMN `elapsed_time` bigint NOT NULL DEFAULT '0' COMMENT '运行耗时' AFTER `thread_id`;
-- update.20240912.sql
ALTER TABLE `workflow_run`
    ADD COLUMN `flash_mode` int NOT NULL DEFAULT '0' COMMENT '极速模式' AFTER `elapsed_time`;
ALTER TABLE `workflow_run`
    ADD COLUMN `trace_id` varchar(255) default '' not null AFTER `flash_mode`;
ALTER TABLE `workflow_run`
    ADD COLUMN `span_lev` int unsigned default '0' not null AFTER `trace_id`;
ALTER TABLE `workflow_run`
    ADD COLUMN `stateful` tinyint(1) NOT NULL DEFAULT 0 AFTER `span_lev`;

CREATE TABLE `workflow_as_api` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'workflow配置自增主键',
  `host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '绑定的域名',
  `path` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '绑定的api路径',
  `hash` varchar(128) NOT NULL COMMENT 'host+path的hash',
  `operation_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '生成openapi schema的时候使用的operationId',
  `tenant_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '租户id',
  `workflow_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '工作流id',
  `summary` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `desc` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `version` bigint NOT NULL DEFAULT '-1' COMMENT '工作流版本，0: draft, >0 正式版时间戳',
  `status` int NOT NULL DEFAULT '0',
  `cuid` bigint NOT NULL DEFAULT '0',
  `cu_name` varchar(32) NOT NULL DEFAULT '',
  `ctime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `muid` bigint NOT NULL DEFAULT '0',
  `mu_name` varchar(32) NOT NULL DEFAULT '',
  `mtime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_host_path` (`hash`) USING BTREE,
  KEY `idx_host` (`host`) USING BTREE,
  KEY `idx_wfid` (`tenant_id`,`workflow_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


ALTER TABLE `wecom_group_info`
    ADD COLUMN `scene` VARCHAR(128) NOT NULL DEFAULT '' COMMENT 'exclusive_ai_assistant：专属AI助理群' AFTER `chat_id`;

ALTER TABLE wecom_group_info
    ADD INDEX idx_tenant_id_space_code_cuid_scene ( `tenant_id`, `space_code`, `cuid`, `scene` );

ALTER TABLE wecom_group_info DROP INDEX idx_tenant_id_space_code_cuid;

-- update.20240924.sql
ALTER TABLE `wecom_group_info`
    ADD COLUMN `thread_id` varchar(64) NOT NULL DEFAULT '' COMMENT '会话id' AFTER `chat_id`;

-- update.20241015.sql
ALTER TABLE `workflow_aggregate`
    ADD COLUMN default_publish_version BIGINT NOT NULL DEFAULT -1  comment '默认生效版本号 -1 使用最新 ' AFTER `latest_publish_version`;

-- update.20241016.sql
alter table workflow_node_run modify column notify_data longtext;

-- update.20241102.sql
alter table `workflow_aggregate`
    add column `space_code` varchar(64) not null default '' after workflow_id;

update `workflow_aggregate`
set `space_code` = cuid;

-- update.20241105.sql

DROP TABLE IF EXISTS `domain`;
CREATE TABLE `domain` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '租户ID',
  `space_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'PERSONNAL',
  `domain` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '域名',
  `custom` int unsigned NOT NULL DEFAULT '1' COMMENT '是否自定义域名',
  `desc` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '描述',
  `cuid` bigint NOT NULL DEFAULT '0',
  `muid` bigint NOT NULL DEFAULT '0',
  `ctime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `mtime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cu_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `mu_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `idx_t_space_topic` (`tenant_id`,`space_code`,`domain`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS `rdb_datasource`;
CREATE TABLE `rdb_datasource` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '租户ID',
  `datasource_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `space_code` varchar(255) NOT NULL,
  `db_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'mysql, postgresql',
  `host` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主机\nhost:port',
  `port` int unsigned NOT NULL COMMENT '端口',
  `db` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '默认数据库',
  `user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `password` varchar(255) NOT NULL COMMENT '密码',
  `params` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '其他参数',
  `status` int NOT NULL DEFAULT '0' COMMENT '数据源状态\n-1: 无效\n0: 生效',
  `cuid` bigint NOT NULL DEFAULT '0',
  `muid` bigint NOT NULL DEFAULT '0',
  `ctime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `mtime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cu_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `mu_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_id` (`datasource_id`),
  KEY `idx_t_space_topic` (`tenant_id`,`space_code`(128),`host`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

ALTER TABLE workflow add column `env_vars` text NOT NULL;

-- update.20241127.sql
DROP TABLE IF EXISTS `redis_datasource`;
CREATE TABLE `redis_datasource` (
                                  `id` bigint NOT NULL AUTO_INCREMENT,
                                  `tenant_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '租户ID',
                                  `datasource_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                                  `space_code` varchar(255) NOT NULL,
                                  `host` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '主机',
                                  `port` int unsigned NOT NULL COMMENT '端口',
                                  `db` int unsigned NOT NULL DEFAULT '0' COMMENT '默认数据库',
                                  `user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '用户名',
                                  `password` varchar(255) NOT NULL DEFAULT '' COMMENT '密码',
                                  `status` int NOT NULL DEFAULT '0' COMMENT '数据源状态\n-1: 无效\n0: 生效',
                                  `cuid` bigint NOT NULL DEFAULT '0',
                                  `muid` bigint NOT NULL DEFAULT '0',
                                  `ctime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                  `mtime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                  `cu_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
                                  `mu_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
                                  PRIMARY KEY (`id`),
                                  UNIQUE KEY `idx_id` (`datasource_id`),
                                  KEY `idx_t_space_topic` (`tenant_id`,`space_code`(128),`host`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- update.20241201.sql
alter table `kafka_datasource`
    add column `type` varchar(16) not null default 'consumer' comment 'kafka数据源类型\producer, consumer' after space_code;

-- update.20241210.sql
ALTER TABLE `workflow_run` 
    ADD COLUMN `context` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' AFTER `stateful`;
-- update.20241229.sql
DROP TABLE IF EXISTS `workflow_template`;
CREATE TABLE `workflow_template`
(
    `id`          bigint unsigned NOT NULL AUTO_INCREMENT,
    `tenant_id`   varchar(64)                             not null comment '租户id',
    `space_code`  varchar(64)   default ''                not null comment '',
    `template_id` varchar(128)                            not null comment '',
    `workflow_id` varchar(128)                            not null,
    `version`     bigint unsigned default 0 not null,
    `title`       varchar(255)  default ''                not null,
    `mode`        varchar(64)   default 'workflow'        not null,
    `desc`        varchar(1024) default ''                not null,
    `tags`        text                                    not null comment '标签',
    `status`      int           default 0                 not null,
    `copies`      bigint        default 0                 not null comment '复制次数',
    `cuid`        bigint        default 0                 not null,
    `cu_name`     varchar(32)   default ''                not null,
    `ctime`       datetime      default CURRENT_TIMESTAMP not null,
    `muid`        bigint        default 0                 not null,
    `mu_name`     varchar(32)   default ''                not null,
    `mtime`       datetime      default CURRENT_TIMESTAMP not null,
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_tenant_id_space_code_template_id` (`tenant_id`, `space_code`, `template_id`) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 1;

-- update.20250102.sql
alter table `workflow_kafka_trigger` add column `expression_type` varchar(16) not null default '' comment '表达式脚本语言类型' after `expression`;
alter table `workflow_webot_trigger` add column `expression_type` varchar(16) not null default '' comment '表达式脚本语言类型' after `expression`;

update workflow_kafka_trigger set `expression_type` = 'Aviator' where expression is not null and expression != '';
update workflow_webot_trigger set `expression_type` = 'Aviator' where expression is not null and expression != '';

-- update.20250221.sql
alter table `workflow`
    add release_description varchar(1024) default '' not null after version;
alter table `workflow_aggregate`
    add release_description varchar(1024) default '' not null after version;

-- update.20250306.sql
ALTER TABLE `kafka_datasource`
    ADD COLUMN `auto_offset_reset` VARCHAR(50) NOT NULL DEFAULT 'latest' COMMENT '偏移量重置策略：latest, earliest，默认为latest' AFTER `msg_schema`,
    ADD COLUMN `props_config` TEXT COMMENT 'Kafka属性配置信息，存储为JSON格式，例如：认证、超时等参数' AFTER `auto_offset_reset`;

-- update.20250513.sql
alter table workflow_run_sharding modify column max_count bigint unsigned not null default 20000000 comment '分表的最大记录数\n如果count>max_count， 创建新表';

-- update.20250605.sql
ALTER TABLE `kafka_datasource`
    ADD COLUMN `group_id` varchar(255) NOT NULL DEFAULT '' COMMENT '消费者组id' AFTER `name`;

-- update.20250827.sql
ALTER TABLE workflow_run
    ADD INDEX idx_workflow_trigger (`workflow_id`, `workflow_run_id`, `trigger_from`),
    ALGORITHM INPLACE,
    LOCK = NONE;
