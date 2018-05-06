CREATE DATABASE IF NOT EXISTS webnet DEFAULT CHARSET utf8 COLLATE utf8_general_ci;

DROP TABLE IF EXISTS webapplication;
CREATE TABLE `webapplication` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `webname` varchar(100) NOT NULL,
    `weburl` varchar(255) NOT NULL,
    `img` longtext,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

insert into englishwords(chinesekey,englishvalue) values("你好","hello");
select * from englishwords where chinesekey="你好";


drop table if EXISTS webapplicationstate;
CREATE TABLE `webapplicationstate` (
    `Id` int(11) NOT NULL AUTO_INCREMENT,
    `state` int(11) DEFAULT NULL COMMENT '表状态',
    `username` varchar(100) NOT NULL,
    PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='状态表';

insert into webapplicationstate(state,username) values(0,"hello");

drop trigger if EXISTS webapplication_state_insert;
CREATE TRIGGER webapplication_state_insert AFTER INSERT ON webapplication FOR EACH ROW
BEGIN
update webapplicationstate set state=1;
END #$
#DELIMITER ;

drop trigger if EXISTS webapplication_state_update;
CREATE TRIGGER webapplication_state_update AFTER UPDATE ON webapplication FOR EACH ROW
BEGIN
update webapplicationstate set state=1 ;
END #$
#DELIMITER ;

drop trigger if EXISTS webapplication_state_delete;
CREATE TRIGGER webapplication_state_delete AFTER DELETE ON webapplication FOR EACH ROW
BEGIN
update webapplicationstate set state=1 ;
END #$
#DELIMITER ;

SELECT * FROM information_schema.triggers;
insert into webapplication(name,add_time) values('周伯通2',12);
select *from webapplication;

select * from logs;
select * from webapplicationstate;

insert into webapplication(webname,weburl,img) values("myweb","http://www.baidu.com","+AOvEnOjFdUtotBu27GAXMQsLdh1L6wvsIpYLl9Wso/oGa8D2Jm6JHfV62PlsP9IN4+HcC2vAUpGK/XsqsaWc/HOmsGasFKm8bnVMYB2ZhlWahp5tQ9WL9gFrxjQYietlgFoE1pmtVbnKo1QM66HLwJqyuno5GVf7Bb0fpWDns32g1S226IfAurJ6cxe8hmWPPGAdmSs1K/gcHew6lucpq16w/qyMtmmf/TYsWBtWP/Qr2zw/Blg/Vr8YnatG8uH9Kexsxt8hYDAYDPY37A4TakBydL2KgAAAAABJRU5ErkJggg==");


