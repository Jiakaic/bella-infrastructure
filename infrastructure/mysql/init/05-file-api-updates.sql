USE bella_file_api;

-- 02-update.20250109.sql
alter table file
    add column extension varchar(512) not null default '' comment 'extension' after filename;

alter table file_0
    add column extension varchar(512) not null default '' comment 'extension' after filename;

alter table file_1
    add column extension varchar(512) not null default '' comment 'extension' after filename;

alter table file_2
    add column extension varchar(512) not null default '' comment 'extension' after filename;

alter table file_3
    add column extension varchar(512) not null default '' comment 'extension' after filename;

alter table file_4
    add column extension varchar(512) not null default '' comment 'extension' after filename;

alter table file_5
    add column extension varchar(512) not null default '' comment 'extension' after filename;

alter table file_6
    add column extension varchar(512) not null default '' comment 'extension' after filename;

alter table file_7
    add column extension varchar(512) not null default '' comment 'extension' after filename;

alter table file_8
    add column extension varchar(512) not null default '' comment 'extension' after filename;

alter table file_9
    add column extension varchar(512) not null default '' comment 'extension' after filename;

alter table file_10
    add column extension varchar(512) not null default '' comment 'extension' after filename;

alter table file_11
    add column extension varchar(512) not null default '' comment 'extension' after filename;

alter table file_12
    add column extension varchar(512) not null default '' comment 'extension' after filename;

alter table file_13
    add column extension varchar(512) not null default '' comment 'extension' after filename;

alter table file_14
    add column extension varchar(512) not null default '' comment 'extension' after filename;

alter table file_15
    add column extension varchar(512) not null default '' comment 'extension' after filename;

-- 03-update.20250121.sql
alter table file
    add column mime_type varchar(512) not null default '' comment 'mime type' after filename,
    add column `type` varchar(512) not null default '' comment 'subtype of mime type, also known as file type' after mime_type;

alter table file_0
    add column mime_type varchar(512) not null default '' comment 'mime type' after filename,
    add column `type` varchar(512) not null default '' comment 'subtype of mime type, also known as file type' after mime_type;

alter table file_1
    add column mime_type varchar(512) not null default '' comment 'mime type' after filename,
    add column `type` varchar(512) not null default '' comment 'subtype of mime type, also known as file type' after mime_type;

alter table file_2
    add column mime_type varchar(512) not null default '' comment 'mime type' after filename,
    add column `type` varchar(512) not null default '' comment 'subtype of mime type, also known as file type' after mime_type;

alter table file_3
    add column mime_type varchar(512) not null default '' comment 'mime type' after filename,
    add column `type` varchar(512) not null default '' comment 'subtype of mime type, also known as file type' after mime_type;

alter table file_4
    add column mime_type varchar(512) not null default '' comment 'mime type' after filename,
    add column `type` varchar(512) not null default '' comment 'subtype of mime type, also known as file type' after mime_type;

alter table file_5
    add column mime_type varchar(512) not null default '' comment 'mime type' after filename,
    add column `type` varchar(512) not null default '' comment 'subtype of mime type, also known as file type' after mime_type;

alter table file_6
    add column mime_type varchar(512) not null default '' comment 'mime type' after filename,
    add column `type` varchar(512) not null default '' comment 'subtype of mime type, also known as file type' after mime_type;

alter table file_7
    add column mime_type varchar(512) not null default '' comment 'mime type' after filename,
    add column `type` varchar(512) not null default '' comment 'subtype of mime type, also known as file type' after mime_type;

alter table file_8
    add column mime_type varchar(512) not null default '' comment 'mime type' after filename,
    add column `type` varchar(512) not null default '' comment 'subtype of mime type, also known as file type' after mime_type;

alter table file_9
    add column mime_type varchar(512) not null default '' comment 'mime type' after filename,
    add column `type` varchar(512) not null default '' comment 'subtype of mime type, also known as file type' after mime_type;

alter table file_10
    add column mime_type varchar(512) not null default '' comment 'mime type' after filename,
    add column `type` varchar(512) not null default '' comment 'subtype of mime type, also known as file type' after mime_type;

alter table file_11
    add column mime_type varchar(512) not null default '' comment 'mime type' after filename,
    add column `type` varchar(512) not null default '' comment 'subtype of mime type, also known as file type' after mime_type;

alter table file_12
    add column mime_type varchar(512) not null default '' comment 'mime type' after filename,
    add column `type` varchar(512) not null default '' comment 'subtype of mime type, also known as file type' after mime_type;

alter table file_13
    add column mime_type varchar(512) not null default '' comment 'mime type' after filename,
    add column `type` varchar(512) not null default '' comment 'subtype of mime type, also known as file type' after mime_type;

alter table file_14
    add column mime_type varchar(512) not null default '' comment 'mime type' after filename,
    add column `type` varchar(512) not null default '' comment 'subtype of mime type, also known as file type' after mime_type;

alter table file_15
    add column mime_type varchar(512) not null default '' comment 'mime type' after filename,
    add column `type` varchar(512) not null default '' comment 'subtype of mime type, also known as file type' after mime_type;

-- 04-update.20250616.sql
CREATE TABLE `bella_file_api`.`dataset`
(
    `id`         bigint       NOT NULL AUTO_INCREMENT,
    `space_code` varchar(128) NOT NULL DEFAULT '' COMMENT '组织编码；对标OpenAI organization',
    `dataset_id` varchar(256) NOT NULL DEFAULT '' COMMENT '数据集ID',
    `name`       varchar(128) NOT NULL DEFAULT '' COMMENT '数据集名称',
    `type`       varchar(32)  NOT NULL DEFAULT '' COMMENT '类型；QA：QA类型',
    `remark`     varchar(128) NOT NULL DEFAULT '' COMMENT '备注',
    `count`      bigint       NOT NULL DEFAULT 0 COMMENT '数量',
    `cuid`       bigint       NOT NULL DEFAULT 0,
    `cu_name`    varchar(32)  NOT NULL DEFAULT '',
    `ctime`      datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `muid`       bigint       NOT NULL DEFAULT 0,
    `mu_name`    varchar(32)  NOT NULL DEFAULT '',
    `mtime`      datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `status`     tinyint(1)   NOT NULL DEFAULT 0 COMMENT '数据集是否被删除，0表示未删除，-1表示已删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_dataset_id` (`dataset_id`) USING BTREE,
    INDEX `idx_space_code` (`space_code`) USING BTREE,
    INDEX `idx_ctime` (`ctime`) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4
    COMMENT ='数据集';

CREATE TABLE `bella_file_api`.`dataset_qa`
(
    `id`                   bigint       NOT NULL AUTO_INCREMENT,
    `item_id`              varchar(256) NOT NULL DEFAULT '' COMMENT 'QA的ID',
    `dataset_sharding_key` varchar(256) NOT NULL DEFAULT '' COMMENT '数据集分片的key',
    `dataset_id`           varchar(256) NOT NULL DEFAULT '' COMMENT '数据集ID',
    `question`             longtext COMMENT '问题',
    `similar_q1`           longtext COMMENT '相似问1',
    `similar_q2`           longtext COMMENT '相似问2',
    `similar_q3`           longtext COMMENT '相似问3',
    `answer`               longtext COMMENT '答案',
    `cuid`                 bigint       NOT NULL DEFAULT 0,
    `cu_name`              varchar(32)  NOT NULL DEFAULT '',
    `ctime`                datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `muid`                 bigint       NOT NULL DEFAULT 0,
    `mu_name`              varchar(32)  NOT NULL DEFAULT '',
    `mtime`                datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `status`               tinyint(1)   NOT NULL DEFAULT 0 COMMENT '数据集是否被删除，0表示未删除，-1表示已删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_item_id` (`item_id`) USING BTREE,
    INDEX `idx_dataset_item` (`dataset_id`, `item_id`) USING BTREE,
    INDEX `idx_ctime` (`ctime`) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4
    COMMENT ='问答数据集表';

CREATE TABLE `bella_file_api`.`dataset_qa_reference`
(
    `id`           bigint       NOT NULL AUTO_INCREMENT,
    `reference_id` varchar(256) NOT NULL DEFAULT '' COMMENT '引用ID；由item_id/file_id/path确定',
    `item_id`      varchar(256) NOT NULL DEFAULT '' COMMENT '问答对ID',
    `dataset_id`   varchar(256) NOT NULL COMMENT '数据集ID',
    `file_id`      varchar(256) NOT NULL DEFAULT '' COMMENT '文件ID',
    `path`         varchar(512) NOT NULL DEFAULT '' COMMENT '位置信息',
    `cuid`         bigint       NOT NULL DEFAULT 0,
    `cu_name`      varchar(32)  NOT NULL DEFAULT '',
    `ctime`        datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `muid`         bigint       NOT NULL DEFAULT 0,
    `mu_name`      varchar(32)  NOT NULL DEFAULT '',
    `mtime`        datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `status`       tinyint(1)   NOT NULL DEFAULT 0 COMMENT '引用是否被删除，0表示未删除，-1表示已删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_reference_id` (`reference_id`) USING BTREE,
    INDEX `idx_dataset_id` (`dataset_id`) USING BTREE,
    INDEX `idx_item_id` (`item_id`) USING BTREE,
    INDEX `idx_ctime` (`ctime`) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4
    COMMENT ='数据集问答对引用关系表';

ALTER TABLE `bella_file_api`.`file`
    ADD COLUMN `dom_tree_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'DOM tree的文件ID';

ALTER TABLE `bella_file_api`.`file_0`
    ADD COLUMN `dom_tree_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'DOM tree的文件ID';

ALTER TABLE `bella_file_api`.`file_1`
    ADD COLUMN `dom_tree_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'DOM tree的文件ID';

ALTER TABLE `bella_file_api`.`file_2`
    ADD COLUMN `dom_tree_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'DOM tree的文件ID';

ALTER TABLE `bella_file_api`.`file_3`
    ADD COLUMN `dom_tree_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'DOM tree的文件ID';

ALTER TABLE `bella_file_api`.`file_4`
    ADD COLUMN `dom_tree_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'DOM tree的文件ID';

ALTER TABLE `bella_file_api`.`file_5`
    ADD COLUMN `dom_tree_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'DOM tree的文件ID';

ALTER TABLE `bella_file_api`.`file_6`
    ADD COLUMN `dom_tree_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'DOM tree的文件ID';

ALTER TABLE `bella_file_api`.`file_7`
    ADD COLUMN `dom_tree_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'DOM tree的文件ID';

ALTER TABLE `bella_file_api`.`file_8`
    ADD COLUMN `dom_tree_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'DOM tree的文件ID';

ALTER TABLE `bella_file_api`.`file_9`
    ADD COLUMN `dom_tree_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'DOM tree的文件ID';

ALTER TABLE `bella_file_api`.`file_10`
    ADD COLUMN `dom_tree_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'DOM tree的文件ID';

ALTER TABLE `bella_file_api`.`file_11`
    ADD COLUMN `dom_tree_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'DOM tree的文件ID';

ALTER TABLE `bella_file_api`.`file_12`
    ADD COLUMN `dom_tree_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'DOM tree的文件ID';

ALTER TABLE `bella_file_api`.`file_13`
    ADD COLUMN `dom_tree_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'DOM tree的文件ID';

ALTER TABLE `bella_file_api`.`file_14`
    ADD COLUMN `dom_tree_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'DOM tree的文件ID';

ALTER TABLE `bella_file_api`.`file_15`
    ADD COLUMN `dom_tree_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'DOM tree的文件ID';

CREATE TABLE `dataset_sharding`
(
    `id`        bigint unsigned NOT NULL AUTO_INCREMENT,
    `key`       varchar(255)    NOT NULL DEFAULT '' COMMENT '分表的标识，\n对应的表+’_’+key即是实际读写的表',
    `key_time`  datetime        NOT NULL COMMENT '当前分片第一条数据的时间，用于索引分片',
    `last_key`  varchar(255)    NOT NULL DEFAULT '' COMMENT '上一次分表的标识，用于分表创建并发控制',
    `count`     bigint unsigned NOT NULL DEFAULT '0' COMMENT '分表的记录数量',
    `max_count` bigint unsigned NOT NULL DEFAULT '20000000' COMMENT '分表的最大记录数\n如果count>max_count， 创建新表',
    `ctime`     datetime        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `cu_name`   varchar(64)     NOT NULL DEFAULT '',
    `cuid`      bigint          NOT NULL DEFAULT '0',
    `mtime`     datetime        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `mu_name`   varchar(255)    NOT NULL DEFAULT '',
    `muid`      bigint          NOT NULL DEFAULT '0',
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE KEY `idx_key` (`key`),
    KEY `idx_last_key` (`last_key`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4;

insert into `dataset_sharding` (`key`, `key_time`, `last_key`, `count`, `max_count`, `cu_name`, `cuid`, `mu_name`,
                                `muid`)
values ('', '2025-06-18 00:00:00', 'NO', 0, 20000000, '', 0, '', 0);

-- 05-update.20250626.sql
ALTER TABLE `bella_file_api`.`dataset`
    ADD INDEX `idx_mtime` (`mtime`) USING BTREE;

ALTER TABLE `bella_file_api`.`dataset_qa`
    ADD INDEX `idx_mtime` (`mtime`) USING BTREE;

ALTER TABLE `bella_file_api`.`dataset_qa_reference`
    ADD INDEX `idx_mtime` (`mtime`) USING BTREE;

-- 05-update.20250703.sql
ALTER TABLE `bella_file_api`.`file`
    ADD COLUMN `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '文件版本号, 每次变更+1' AFTER file_id;

ALTER TABLE `bella_file_api`.`file_0`
    ADD COLUMN `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '文件版本号, 每次变更+1' AFTER file_id;

ALTER TABLE `bella_file_api`.`file_1`
    ADD COLUMN `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '文件版本号, 每次变更+1' AFTER file_id;

ALTER TABLE `bella_file_api`.`file_2`
    ADD COLUMN `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '文件版本号, 每次变更+1' AFTER file_id;

ALTER TABLE `bella_file_api`.`file_3`
    ADD COLUMN `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '文件版本号, 每次变更+1' AFTER file_id;

ALTER TABLE `bella_file_api`.`file_4`
    ADD COLUMN `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '文件版本号, 每次变更+1' AFTER file_id;

ALTER TABLE `bella_file_api`.`file_5`
    ADD COLUMN `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '文件版本号, 每次变更+1' AFTER file_id;

ALTER TABLE `bella_file_api`.`file_6`
    ADD COLUMN `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '文件版本号, 每次变更+1' AFTER file_id;

ALTER TABLE `bella_file_api`.`file_7`
    ADD COLUMN `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '文件版本号, 每次变更+1' AFTER file_id;

ALTER TABLE `bella_file_api`.`file_8`
    ADD COLUMN `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '文件版本号, 每次变更+1' AFTER file_id;

ALTER TABLE `bella_file_api`.`file_9`
    ADD COLUMN `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '文件版本号, 每次变更+1' AFTER file_id;

ALTER TABLE `bella_file_api`.`file_10`
    ADD COLUMN `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '文件版本号, 每次变更+1' AFTER file_id;

ALTER TABLE `bella_file_api`.`file_11`
    ADD COLUMN `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '文件版本号, 每次变更+1' AFTER file_id;

ALTER TABLE `bella_file_api`.`file_12`
    ADD COLUMN `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '文件版本号, 每次变更+1' AFTER file_id;

ALTER TABLE `bella_file_api`.`file_13`
    ADD COLUMN `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '文件版本号, 每次变更+1' AFTER file_id;

ALTER TABLE `bella_file_api`.`file_14`
    ADD COLUMN `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '文件版本号, 每次变更+1' AFTER file_id;

ALTER TABLE `bella_file_api`.`file_15`
    ADD COLUMN `version` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '文件版本号, 每次变更+1' AFTER file_id;

-- 07-update.20250710.sql
CREATE TABLE `bella_file_api`.`dataset_document`
(
    `id`                   bigint       NOT NULL AUTO_INCREMENT,
    `dataset_sharding_key` varchar(256) NOT NULL DEFAULT '' COMMENT '数据集分片的key',
    `dataset_id`           varchar(256) NOT NULL DEFAULT '' COMMENT '数据集ID',
    `file_id`              varchar(256) NOT NULL DEFAULT '' COMMENT '文件ID，作为document的主键',
    `cuid`                 bigint       NOT NULL DEFAULT 0,
    `cu_name`              varchar(32)  NOT NULL DEFAULT '',
    `ctime`                datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `muid`                 bigint       NOT NULL DEFAULT 0,
    `mu_name`              varchar(32)  NOT NULL DEFAULT '',
    `mtime`                datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `status`               tinyint(1)   NOT NULL DEFAULT 0 COMMENT '文档是否被删除，0表示未删除，-1表示已删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_dataset_file` (`dataset_id`, `file_id`) USING BTREE,
    INDEX `idx_dataset_id` (`dataset_id`) USING BTREE,
    INDEX `idx_file_id` (`file_id`) USING BTREE,
    INDEX `idx_ctime` (`ctime`) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4
    COMMENT ='文档数据集表';

-- 08-update.20250715.sql
ALTER TABLE `bella_file_api`.`dataset`
    ADD COLUMN
        `latest_export_time`           datetime     NOT NULL DEFAULT '1970-01-01 00:00:00' COMMENT '数据集最新导出时间',
    ADD COLUMN `latest_export_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT '数据集最新导出文件ID';

-- 09-update.20250717.sql
ALTER TABLE `bella_file_api`.`file`
    ADD COLUMN `pdf_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'PDF的文件ID' AFTER `dom_tree_file_id`;

ALTER TABLE `bella_file_api`.`file_0`
    ADD COLUMN `pdf_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'PDF的文件ID' AFTER `dom_tree_file_id`;

ALTER TABLE `bella_file_api`.`file_1`
    ADD COLUMN `pdf_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'PDF的文件ID' AFTER `dom_tree_file_id`;

ALTER TABLE `bella_file_api`.`file_2`
    ADD COLUMN `pdf_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'PDF的文件ID' AFTER `dom_tree_file_id`;

ALTER TABLE `bella_file_api`.`file_3`
    ADD COLUMN `pdf_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'PDF的文件ID' AFTER `dom_tree_file_id`;

ALTER TABLE `bella_file_api`.`file_4`
    ADD COLUMN `pdf_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'PDF的文件ID' AFTER `dom_tree_file_id`;

ALTER TABLE `bella_file_api`.`file_5`
    ADD COLUMN `pdf_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'PDF的文件ID' AFTER `dom_tree_file_id`;

ALTER TABLE `bella_file_api`.`file_6`
    ADD COLUMN `pdf_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'PDF的文件ID' AFTER `dom_tree_file_id`;

ALTER TABLE `bella_file_api`.`file_7`
    ADD COLUMN `pdf_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'PDF的文件ID' AFTER `dom_tree_file_id`;

ALTER TABLE `bella_file_api`.`file_8`
    ADD COLUMN `pdf_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'PDF的文件ID' AFTER `dom_tree_file_id`;

ALTER TABLE `bella_file_api`.`file_9`
    ADD COLUMN `pdf_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'PDF的文件ID' AFTER `dom_tree_file_id`;

ALTER TABLE `bella_file_api`.`file_10`
    ADD COLUMN `pdf_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'PDF的文件ID' AFTER `dom_tree_file_id`;

ALTER TABLE `bella_file_api`.`file_11`
    ADD COLUMN `pdf_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'PDF的文件ID' AFTER `dom_tree_file_id`;

ALTER TABLE `bella_file_api`.`file_12`
    ADD COLUMN `pdf_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'PDF的文件ID' AFTER `dom_tree_file_id`;

ALTER TABLE `bella_file_api`.`file_13`
    ADD COLUMN `pdf_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'PDF的文件ID' AFTER `dom_tree_file_id`;

ALTER TABLE `bella_file_api`.`file_14`
    ADD COLUMN `pdf_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'PDF的文件ID' AFTER `dom_tree_file_id`;

ALTER TABLE `bella_file_api`.`file_15`
    ADD COLUMN `pdf_file_id` varchar(256) NOT NULL DEFAULT '' COMMENT 'PDF的文件ID' AFTER `dom_tree_file_id`;

-- 09-update.20250722.sql
-- 简化的Dataset分片升级方案：单表+type字段
-- 使用事务保证数据一致性

START TRANSACTION;

-- 1. 删除原有的约束和索引（因为现在需要支持type字段）
ALTER TABLE `dataset_sharding`
    DROP INDEX `idx_key`;
ALTER TABLE `dataset_sharding`
    DROP INDEX `idx_last_key`;

-- 2. 添加type字段，默认为'qa'以兼容现有数据
ALTER TABLE `dataset_sharding`
    ADD COLUMN `type` varchar(32) NOT NULL DEFAULT 'qa' COMMENT '分片类型：qa-问答数据，document-文档数据' AFTER `id`;

-- 3. 重新创建索引（加上type字段支持）
CREATE UNIQUE INDEX `idx_type_key` ON `dataset_sharding` (`type`, `key`);
CREATE INDEX `idx_type_last_key` ON `dataset_sharding` (`type`, `last_key`);

-- 4. 创建document类型的分片记录
INSERT INTO `dataset_sharding` (`key`, `key_time`, `last_key`, `count`, `max_count`, `cu_name`, `cuid`, `mu_name`,
                                `muid`, `type`)
VALUES ('', '2025-06-18 00:00:00', 'NO', 0, 20000000, '', 0, '', 0, 'document');

COMMIT;

-- 10-update.20250725.sql
alter table dataset_qa_reference
    add column snippet varchar(64) not null default '' comment 'snippet for dataset qa reference' after path;

-- 11-update.20250728.sql
alter table file add index `idx_space_purpose`(`space_code`,`purpose`,`status`) USING BTREE;
alter table file_0 add index `idx_space_purpose`(`space_code`,`purpose`,`status`) USING BTREE;
alter table file_1 add index `idx_space_purpose`(`space_code`,`purpose`,`status`) USING BTREE;
alter table file_2 add index `idx_space_purpose`(`space_code`,`purpose`,`status`) USING BTREE;
alter table file_3 add index `idx_space_purpose`(`space_code`,`purpose`,`status`) USING BTREE;
alter table file_4 add index `idx_space_purpose`(`space_code`,`purpose`,`status`) USING BTREE;
alter table file_5 add index `idx_space_purpose`(`space_code`,`purpose`,`status`) USING BTREE;
alter table file_6 add index `idx_space_purpose`(`space_code`,`purpose`,`status`) USING BTREE;
alter table file_7 add index `idx_space_purpose`(`space_code`,`purpose`,`status`) USING BTREE;
alter table file_8 add index `idx_space_purpose`(`space_code`,`purpose`,`status`) USING BTREE;
alter table file_9 add index `idx_space_purpose`(`space_code`,`purpose`,`status`) USING BTREE;
alter table file_10 add index `idx_space_purpose`(`space_code`,`purpose`,`status`) USING BTREE;
alter table file_11 add index `idx_space_purpose`(`space_code`,`purpose`,`status`) USING BTREE;
alter table file_12 add index `idx_space_purpose`(`space_code`,`purpose`,`status`) USING BTREE;
alter table file_13 add index `idx_space_purpose`(`space_code`,`purpose`,`status`) USING BTREE;
alter table file_14 add index `idx_space_purpose`(`space_code`,`purpose`,`status`) USING BTREE;
alter table file_15 add index `idx_space_purpose`(`space_code`,`purpose`,`status`) USING BTREE;

-- 12-update.20250731.sql
alter table dataset_qa
    add column reasoning varchar(4096) not null default '' comment '推理过程/解题思路' AFTER answer,
    add column tags      varchar(8192) comment '标签信息冗余存储，格式：["tag1","tag2"]' AFTER reasoning;

-- 创建标签表
CREATE TABLE `bella_file_api`.`tag`
(
    `id`         bigint       NOT NULL AUTO_INCREMENT,
    `space_code` varchar(128) NOT NULL DEFAULT '' COMMENT '空间编码',
    `name`       varchar(100) NOT NULL DEFAULT '' COMMENT '标签名称',
    `cuid`       bigint       NOT NULL DEFAULT 0,
    `cu_name`    varchar(32)  NOT NULL DEFAULT '',
    `ctime`      datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `muid`       bigint       NOT NULL DEFAULT 0,
    `mu_name`    varchar(32)  NOT NULL DEFAULT '',
    `mtime`      datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `status`     tinyint(1)   NOT NULL DEFAULT 0 COMMENT '状态：0正常，-1删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_space_name` (`space_code`, `name`) USING BTREE,
    INDEX `idx_ctime` (`ctime`) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  DEFAULT CHARSET = utf8mb4
    COMMENT ='标签定义表';

-- 13-update.20250805.sql
UPDATE dataset_qa_reference
SET path = CONCAT('/', REPLACE(path, ',', '/'));

-- 14-update.20250807.sql
-- 添加目录相关字段到file表
ALTER TABLE file
    ADD COLUMN is_dir TINYINT(0) NOT NULL DEFAULT 0 COMMENT '是否为目录：1为目录，0为文件' AFTER filename,
    ADD INDEX idx_space_filename_status (`space_code`, `filename`, `status`) USING BTREE;
ALTER TABLE file_0
    ADD COLUMN is_dir TINYINT(0) NOT NULL DEFAULT 0 COMMENT '是否为目录：1为目录，0为文件' AFTER filename,
    ADD INDEX idx_space_filename_status (`space_code`, `filename`, `status`) USING BTREE;
ALTER TABLE file_1
    ADD COLUMN is_dir TINYINT(0) NOT NULL DEFAULT 0 COMMENT '是否为目录：1为目录，0为文件' AFTER filename,
    ADD INDEX idx_space_filename_status (`space_code`, `filename`, `status`) USING BTREE;
ALTER TABLE file_2
    ADD COLUMN is_dir TINYINT(0) NOT NULL DEFAULT 0 COMMENT '是否为目录：1为目录，0为文件' AFTER filename,
    ADD INDEX idx_space_filename_status (`space_code`, `filename`, `status`) USING BTREE;
ALTER TABLE file_3
    ADD COLUMN is_dir TINYINT(0) NOT NULL DEFAULT 0 COMMENT '是否为目录：1为目录，0为文件' AFTER filename,
    ADD INDEX idx_space_filename_status (`space_code`, `filename`, `status`) USING BTREE;
ALTER TABLE file_4
    ADD COLUMN is_dir TINYINT(0) NOT NULL DEFAULT 0 COMMENT '是否为目录：1为目录，0为文件' AFTER filename,
    ADD INDEX idx_space_filename_status (`space_code`, `filename`, `status`) USING BTREE;
ALTER TABLE file_5
    ADD COLUMN is_dir TINYINT(0) NOT NULL DEFAULT 0 COMMENT '是否为目录：1为目录，0为文件' AFTER filename,
    ADD INDEX idx_space_filename_status (`space_code`, `filename`, `status`) USING BTREE;
ALTER TABLE file_6
    ADD COLUMN is_dir TINYINT(0) NOT NULL DEFAULT 0 COMMENT '是否为目录：1为目录，0为文件' AFTER filename,
    ADD INDEX idx_space_filename_status (`space_code`, `filename`, `status`) USING BTREE;
ALTER TABLE file_7
    ADD COLUMN is_dir TINYINT(0) NOT NULL DEFAULT 0 COMMENT '是否为目录：1为目录，0为文件' AFTER filename,
    ADD INDEX idx_space_filename_status (`space_code`, `filename`, `status`) USING BTREE;
ALTER TABLE file_8
    ADD COLUMN is_dir TINYINT(0) NOT NULL DEFAULT 0 COMMENT '是否为目录：1为目录，0为文件' AFTER filename,
    ADD INDEX idx_space_filename_status (`space_code`, `filename`, `status`) USING BTREE;
ALTER TABLE file_9
    ADD COLUMN is_dir TINYINT(0) NOT NULL DEFAULT 0 COMMENT '是否为目录：1为目录，0为文件' AFTER filename,
    ADD INDEX idx_space_filename_status (`space_code`, `filename`, `status`) USING BTREE;
ALTER TABLE file_10
    ADD COLUMN is_dir TINYINT(0) NOT NULL DEFAULT 0 COMMENT '是否为目录：1为目录，0为文件' AFTER filename,
    ADD INDEX idx_space_filename_status (`space_code`, `filename`, `status`) USING BTREE;
ALTER TABLE file_11
    ADD COLUMN is_dir TINYINT(0) NOT NULL DEFAULT 0 COMMENT '是否为目录：1为目录，0为文件' AFTER filename,
    ADD INDEX idx_space_filename_status (`space_code`, `filename`, `status`) USING BTREE;
ALTER TABLE file_12
    ADD COLUMN is_dir TINYINT(0) NOT NULL DEFAULT 0 COMMENT '是否为目录：1为目录，0为文件' AFTER filename,
    ADD INDEX idx_space_filename_status (`space_code`, `filename`, `status`) USING BTREE;
ALTER TABLE file_13
    ADD COLUMN is_dir TINYINT(0) NOT NULL DEFAULT 0 COMMENT '是否为目录：1为目录，0为文件' AFTER filename,
    ADD INDEX idx_space_filename_status (`space_code`, `filename`, `status`) USING BTREE;
ALTER TABLE file_14
    ADD COLUMN is_dir TINYINT(0) NOT NULL DEFAULT 0 COMMENT '是否为目录：1为目录，0为文件' AFTER filename,
    ADD INDEX idx_space_filename_status (`space_code`, `filename`, `status`) USING BTREE;
ALTER TABLE file_15
    ADD COLUMN is_dir TINYINT(0) NOT NULL DEFAULT 0 COMMENT '是否为目录：1为目录，0为文件' AFTER filename,
    ADD INDEX idx_space_filename_status (`space_code`, `filename`, `status`) USING BTREE;

CREATE TABLE `file_closure`
(
    `id`            bigint unsigned NOT NULL AUTO_INCREMENT,
    `ancestor_id`   VARCHAR(255)    NOT NULL COMMENT '祖先 file_id',
    `descendant_id` VARCHAR(255)    NOT NULL COMMENT '后代 file_id',
    `space_code`    varchar(128)    NOT NULL DEFAULT '' COMMENT '组织编码；对标OpenAI organization',
    `depth`         BIGINT          NOT NULL DEFAULT 0 COMMENT '深度',
    `root_depth`    BIGINT          NOT NULL DEFAULT -1 COMMENT '距离根目录的深度：1为根目录，2为第一级子文件...',
    `cuid`          bigint          NOT NULL DEFAULT 0,
    `cu_name`       varchar(32)     NOT NULL DEFAULT '',
    `ctime`         datetime        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `muid`          bigint          NOT NULL DEFAULT 0,
    `mu_name`       varchar(32)     NOT NULL DEFAULT '',
    `mtime`         datetime        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_ancestor_descendant` (`ancestor_id`, `descendant_id`) USING BTREE,
    INDEX idx_ancestor_depth_status (`ancestor_id`, `depth`) USING BTREE,
    INDEX idx_descendant_depth_status (`descendant_id`, `depth`) USING BTREE,
    INDEX idx_space_code_root_depth (`space_code`, `root_depth`) USING BTREE
)
    ENGINE = InnoDB
    AUTO_INCREMENT = 1
    DEFAULT CHARSET = utf8mb4
    COMMENT = '文件闭包表';

CREATE TABLE `file_closure_0` like `file_closure`;
CREATE TABLE `file_closure_1` like `file_closure`;
CREATE TABLE `file_closure_2` like `file_closure`;
CREATE TABLE `file_closure_3` like `file_closure`;
CREATE TABLE `file_closure_4` like `file_closure`;
CREATE TABLE `file_closure_5` like `file_closure`;
CREATE TABLE `file_closure_6` like `file_closure`;
CREATE TABLE `file_closure_7` like `file_closure`;
CREATE TABLE `file_closure_8` like `file_closure`;
CREATE TABLE `file_closure_9` like `file_closure`;
CREATE TABLE `file_closure_10` like `file_closure`;
CREATE TABLE `file_closure_11` like `file_closure`;
CREATE TABLE `file_closure_12` like `file_closure`;
CREATE TABLE `file_closure_13` like `file_closure`;
CREATE TABLE `file_closure_14` like `file_closure`;
CREATE TABLE `file_closure_15` like `file_closure`;

INSERT INTO file_closure_0 (ancestor_id, descendant_id, depth, root_depth, space_code)
SELECT file_id    AS ancestor_id,
       file_id    AS descendant_id,
       0          AS depth,
       1          AS root_depth,
       space_code AS space_code
FROM file_0
WHERE status = 0;
INSERT INTO file_closure_1 (ancestor_id, descendant_id, depth, root_depth, space_code)
SELECT file_id    AS ancestor_id,
       file_id    AS descendant_id,
       0          AS depth,
       1          AS root_depth,
       space_code AS space_code
FROM file_1
WHERE status = 0;
INSERT INTO file_closure_2 (ancestor_id, descendant_id, depth, root_depth, space_code)
SELECT file_id    AS ancestor_id,
       file_id    AS descendant_id,
       0          AS depth,
       1          AS root_depth,
       space_code AS space_code
FROM file_2
WHERE status = 0;
INSERT INTO file_closure_3 (ancestor_id, descendant_id, depth, root_depth, space_code)
SELECT file_id    AS ancestor_id,
       file_id    AS descendant_id,
       0          AS depth,
       1          AS root_depth,
       space_code AS space_code
FROM file_3
WHERE status = 0;
INSERT INTO file_closure_4 (ancestor_id, descendant_id, depth, root_depth, space_code)
SELECT file_id    AS ancestor_id,
       file_id    AS descendant_id,
       0          AS depth,
       1          AS root_depth,
       space_code AS space_code
FROM file_4
WHERE status = 0;
INSERT INTO file_closure_5 (ancestor_id, descendant_id, depth, root_depth, space_code)
SELECT file_id    AS ancestor_id,
       file_id    AS descendant_id,
       0          AS depth,
       1          AS root_depth,
       space_code AS space_code
FROM file_5
WHERE status = 0;
INSERT INTO file_closure_6 (ancestor_id, descendant_id, depth, root_depth, space_code)
SELECT file_id    AS ancestor_id,
       file_id    AS descendant_id,
       0          AS depth,
       1          AS root_depth,
       space_code AS space_code
FROM file_6
WHERE status = 0;
INSERT INTO file_closure_7 (ancestor_id, descendant_id, depth, root_depth, space_code)
SELECT file_id    AS ancestor_id,
       file_id    AS descendant_id,
       0          AS depth,
       1          AS root_depth,
       space_code AS space_code
FROM file_7
WHERE status = 0;
INSERT INTO file_closure_8 (ancestor_id, descendant_id, depth, root_depth, space_code)
SELECT file_id    AS ancestor_id,
       file_id    AS descendant_id,
       0          AS depth,
       1          AS root_depth,
       space_code AS space_code
FROM file_8
WHERE status = 0;
INSERT INTO file_closure_9 (ancestor_id, descendant_id, depth, root_depth, space_code)
SELECT file_id    AS ancestor_id,
       file_id    AS descendant_id,
       0          AS depth,
       1          AS root_depth,
       space_code AS space_code
FROM file_9
WHERE status = 0;
INSERT INTO file_closure_10 (ancestor_id, descendant_id, depth, root_depth, space_code)
SELECT file_id    AS ancestor_id,
       file_id    AS descendant_id,
       0          AS depth,
       1          AS root_depth,
       space_code AS space_code
FROM file_10
WHERE status = 0;
INSERT INTO file_closure_11 (ancestor_id, descendant_id, depth, root_depth, space_code)
SELECT file_id    AS ancestor_id,
       file_id    AS descendant_id,
       0          AS depth,
       1          AS root_depth,
       space_code AS space_code
FROM file_11
WHERE status = 0;
INSERT INTO file_closure_12 (ancestor_id, descendant_id, depth, root_depth, space_code)
SELECT file_id    AS ancestor_id,
       file_id    AS descendant_id,
       0          AS depth,
       1          AS root_depth,
       space_code AS space_code
FROM file_12
WHERE status = 0;
INSERT INTO file_closure_13 (ancestor_id, descendant_id, depth, root_depth, space_code)
SELECT file_id    AS ancestor_id,
       file_id    AS descendant_id,
       0          AS depth,
       1          AS root_depth,
       space_code AS space_code
FROM file_13
WHERE status = 0;
INSERT INTO file_closure_14 (ancestor_id, descendant_id, depth, root_depth, space_code)
SELECT file_id    AS ancestor_id,
       file_id    AS descendant_id,
       0          AS depth,
       1          AS root_depth,
       space_code AS space_code
FROM file_14
WHERE status = 0;
INSERT INTO file_closure_15 (ancestor_id, descendant_id, depth, root_depth, space_code)
SELECT file_id    AS ancestor_id,
       file_id    AS descendant_id,
       0          AS depth,
       1          AS root_depth,
       space_code AS space_code
FROM file_15
WHERE status = 0;

-- 15-update.20250820.sql
-- 添加得分要点字段到dataset_qa表
ALTER TABLE dataset_qa
    ADD COLUMN scoring_criteria varchar(2048) COMMENT '评测集答案的评分依据/得分要点' AFTER reasoning;
