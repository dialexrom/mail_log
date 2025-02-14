CREATE DATABASE IF NOT EXISTS mail_log;
USE mail_logs;
CREATE TABLE message (
	`created` TIMESTAMP NOT NULL,
	`id` VARCHAR(16) NOT NULL,
	`int_id` CHAR(16) NOT NULL,
	`str` TEXT,
	`status` BOOL, CONSTRAINT message_id_pk PRIMARY KEY(id)
);
CREATE INDEX message_created_idx ON message (`created`);
CREATE INDEX message_int_id_idx ON message (`int_id`);
CREATE TABLE log (
	`created` TIMESTAMP NOT NULL,
	`int_id` CHAR(16) NOT NULL,
	`str` TEXT,
	`address` VARCHAR(256)
);
CREATE INDEX log_address_idx USING hash ON `log` (`address`);